import { expect } from 'chai';
import 'mocha';

import { Until } from '../../utils/until';
import {skipBlocks} from '../../utils/eth';

import {
  generateOffering,
} from '../../utils/offerings';


import {
  TestInputSettings,
  TestModel, TestScope
} from '../../typings/test-models';

export const deleteOffering: TestModel = {
  name: 'delete offering',
  scope: TestScope.AGENT,
  testFn: (settings: TestInputSettings) => {

    const { agentWs } = settings;
    const until = Until(agentWs);

    describe('delete offering', () => {

      let offeringId: string;

      it('should create an offering', async () => {
        const productId = (await agentWs.getProducts())[0].id;
        const accounts = await agentWs.getAccounts();
        const agentWsId = accounts[0].id;

        offeringId = await agentWs.createOffering(
          generateOffering(productId, agentWsId, 'Main Service')
        );

        expect(offeringId).to.not.be.undefined;
      });

      it('should publish created offering', async function(){

        const timeouts = settings.configs.timeouts;
        this.timeout(timeouts.blocktime*4);

        const gasPrice = parseInt((await agentWs.getSettings())['eth.default.gasprice'].value, 10);
        await agentWs.changeOfferingStatus(offeringId, 'publish', gasPrice);

        await until.object('offering').withId(offeringId).prop('status').becomes('bchain_published');

        const offering = await agentWs.getOffering(offeringId);
        expect(offering.status).to.equal('bchain_published')

      });

      it('should delete published offering', async function(){

        const timeouts = settings.configs.timeouts;
        this.timeout(timeouts.blocktime*260);

        await skipBlocks(250, agentWs, timeouts.blocktime*250, 10000);

        const gasPrice = parseInt((await agentWs.getSettings())['eth.default.gasprice'].value, 10);
        await agentWs.changeOfferingStatus(offeringId, 'deactivate', gasPrice);

        await until.object('offering').withId(offeringId).prop('offerStatus').becomes('removed');

        const offering = await agentWs.getOffering(offeringId);
        expect(offering.offerStatus).to.equal('removed')

      });
    });
  }
};
