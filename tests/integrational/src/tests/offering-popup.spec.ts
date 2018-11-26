import { expect } from 'chai';
import 'mocha';

import { skipBlocks, getEth } from '../utils/eth';
import {
  generateOffering,
  generateSomeOfferings
} from '../utils/offerings';

import { LocalSettings } from './../typings/settings';
import { Offering, OfferStatus } from '../typings/offerings';
import { PaginatedResponse} from '../typings/paginatedResponse';

const configs = require('../configs/config.json') as LocalSettings;

export const offeringPopupTest = (agentWs, clientWs) => {
  describe('offering popup', () => {
    const productId = 'ffbe3aaf-ebae-4c7f-b75c-fff305bc45a4';

    let offeringId: string;

    it('should create an offering', async () => {
      const accounts = await agentWs.getAccounts();
      const agentWsId = accounts[0].id;

      offeringId = await agentWs.createOffering(
        generateOffering(productId, agentWsId, 'Main Service')
      ) as string;

      expect(offeringId).to.not.be.undefined;
    });

    it('should create some additional offerings', async function() {
      const accounts = await agentWs.getAccounts();
      const agentWsId = accounts[0].id;

      // TODO: don't know how to fix this in another way yet
      this.timeout(1000 * 4);

      for (let offering of generateSomeOfferings(productId, agentWsId)) {
        await agentWs.createOffering(offering);
      }
    });

    it('should contain already created offerings for agentWs', async () => {
      const offerings = await agentWs.getAgentOfferings(
        productId,
        OfferStatus.empty,
        0, 10
      ) as PaginatedResponse<Array<Offering>>;

      expect(offerings.totalItems).to.equal(4);
      expect(offerings.items[0].id).to.equal(offeringId);
    });

    it.skip('first offering should be last for clientWs', async () => {
      const accounts = await agentWs.getAccounts();
      const agentEthAddr = accounts[0].ethAddr;

      const offerings = await clientWs.getClientOfferings(
        agentEthAddr,
        100,
        200,
        ['KG']
      );

      expect(offerings.totalItems).to.equal(4);
      expect(offerings.items[3].id).to.equal(offeringId);
    });

    it('should popup an offering', async function() {
      const testTimeout = configs.timeouts.blocktime*(configs.timeouts.getEther.skipBlocks+1) + configs.timeouts.getEther.botTimeoutMs;
      const getEthTimeout = configs.timeouts.blocktime * (configs.timeouts.getEther.skipBlocks);
      const getEthTick = configs.timeouts.blocktime / 3;

      this.timeout(testTimeout * 10);

      await agentWs.changeOfferingStatus(
        offeringId,
        'popup',
        10000
      );

      await skipBlocks(3, agentWs, getEthTimeout, getEthTick);

      const offering = await agentWs.getOffering(offeringId) as Offering;

      expect(offering.blockNumberUpdated).to.not.equal(1);
    });

    it.skip('after popup the offering should be on top', async () => {
      const accounts = await agentWs.getAccounts();
      const agentEthAddr = accounts[0].ethAddr;

      const offerings = await clientWs.getClientOfferings(
        agentEthAddr,
        100,
        200,
        ['KG']
      );

      expect(offerings.totalItems).to.equal(4);
      expect(offerings.items[0].id).to.equal(offeringId);
    });
  });

};
