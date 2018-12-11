import { expect } from 'chai';
import 'mocha';

import { Until } from '../../utils/until';

import { skipBlocks } from '../../utils/eth';
import {
  generateOffering,
  generateSomeOfferings
} from '../../utils/offerings';

import { Offering, OfferStatus } from '../../typings/offerings';
import { PaginatedResponse } from '../../typings/paginatedResponse';
import {
  TestInputSettings,
  TestModel, TestScope
} from '../../typings/test-models';

import { getItFunc } from "../../utils/test-utils";

export const offerings: TestModel = {
  name: 'offerings',
  scope: TestScope.BOTH,
  testFn: (settings: TestInputSettings) => {
    const {
      agentWs, clientWs,
      allowedScope, configs
    } = settings;

    const until = Until(agentWs);

    const agentIt = getItFunc({scope: TestScope.AGENT}, allowedScope);
    const clientIt = getItFunc({scope: TestScope.CLIENT}, allowedScope);

    describe('offerings', () => {
      let offeringId: string;
      let offeringToDeleteId: string;

      describe('create offering', () => {
        agentIt('should create an offering', async () => {
          const productId = (await agentWs.getProducts())[0].id;
          const accounts = await agentWs.getAccounts();
          const agentWsId = accounts[0].id;

          offeringId = await agentWs.createOffering(
            generateOffering(productId, agentWsId, 'Main Service')
          ) as string;

          expect(offeringId).to.not.be.undefined;
        });

        agentIt('should publish already created offering', async function () {
          const timeouts = settings.configs.timeouts;
          this.timeout(timeouts.blocktime*4);

          const gasPrice = parseInt((await agentWs.getSettings())['eth.default.gasprice'].value, 10);
          await agentWs.changeOfferingStatus(offeringId, 'publish', gasPrice);

          await until
            .object('offering')
            .withId(offeringId)
            .prop('status')
            .becomes('bchain_published');

          const offering = await agentWs.getOffering(offeringId);
          expect(offering.status).to.equal('bchain_published')
        });

        agentIt('should create some additional offerings', async function() {
          const productId = (await agentWs.getProducts())[0].id;
          const gasPrice = parseInt((await agentWs.getSettings())['eth.default.gasprice'].value, 10);
          const accounts = await agentWs.getAccounts();
          const agentWsId = accounts[0].id;

          const timeouts = settings.configs.timeouts;
          this.timeout(timeouts.blocktime * 10);

          for (let offering of generateSomeOfferings(productId, agentWsId)) {
            const tmpOfferingId = await agentWs.createOffering(offering);

            await agentWs.changeOfferingStatus(
              tmpOfferingId, 'publish', gasPrice
            );

            await until
              .object('offering')
              .withId(tmpOfferingId)
              .prop('status')
              .becomes('bchain_published');
          }
        });

        agentIt('should contain already created offerings for agentWs', async () => {
          const productId = (await agentWs.getProducts())[0].id;
          const offerings = await agentWs.getAgentOfferings(
            productId,
            OfferStatus.empty,
            0, 10
          ) as PaginatedResponse<Array<Offering>>;

          expect(offerings.totalItems).to.equal(4);
          expect(offerings.items[0].id).to.equal(offeringId);

          offeringToDeleteId = offerings.items[1].id;
        });
      });

      describe('popup offering', () => {
        clientIt('first offering should be last for client', async () => {
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

        agentIt('should popup an offering', async function() {
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

        clientIt('after popup the offering should be on top', async () => {
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

      describe('delete offering', () => {
        agentIt('should delete an offering', async function(){
          const timeouts = settings.configs.timeouts;
          this.timeout(timeouts.blocktime*260);

          await skipBlocks(250, agentWs, timeouts.blocktime*250, 10000);

          const gasPrice = parseInt((await agentWs.getSettings())['eth.default.gasprice'].value, 10);
          await agentWs.changeOfferingStatus(
            offeringToDeleteId, 'deactivate', gasPrice
          );

          await until
            .object('offering')
            .withId(offeringId)
            .prop('offerStatus')
            .becomes('removed');

          const offering = await agentWs.getOffering(offeringToDeleteId);
          expect(offering.offerStatus).to.equal('removed')

        });
      });
    });
  }
};
