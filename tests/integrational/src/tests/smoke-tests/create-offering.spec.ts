import { expect } from 'chai';
import 'mocha';

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

export const createOffering: TestModel = {
  name: 'offering popup',
  scope: TestScope.Agent,
  testFn: (settings: TestInputSettings) => {
    const { agentWs, configs } = settings;

    describe('offering popup', () => {

      it('should create an offering', async () => {
        const accounts = await agentWs.getAccounts();
        const agentWsId = accounts[0].id;

        offeringId = await agentWs.createOffering(
          generateOffering(productId, agentWsId, 'Main Service')
        ) as string;

        expect(offeringId).to.not.be.undefined;
      });

      it('should publish created offering', async () => {
        const gasPrice = (await getSettings()).['eth.default.gasprice'].value;
        await ws.changeOfferingStatus(offeringId, 'publish', gasPrice);
      })
  }
};
