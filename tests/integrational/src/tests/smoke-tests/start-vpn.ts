import { expect } from 'chai';
import 'mocha';

import {
  TestInputSettings,
  TestModel, TestScope
} from '../../typings/test-models';
import { Offering, OfferStatus } from '../../typings/offerings';
import { PaginatedResponse } from '../../typings/paginatedResponse';

export const startVpn: TestModel = {
  name: 'start vpn',
  scope: TestScope.BOTH,
  testFn: (settings: TestInputSettings) => {
    const {
      agentWs, clientWs,
      allowedScope, configs
    } = settings;

    describe('start vpn', () => {
      let offering: Offering;
      let channelId: string;

      it('agent should publish an offering', async function() {
        const productId = (await agentWs.getProducts())[0].id;
        const offerings = await agentWs.getAgentOfferings(
          productId,
          OfferStatus.empty,
          0, 10
        ) as PaginatedResponse<Array<Offering>>;

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

      it('client should get top offering', async () => {
        const accounts = await agentWs.getAccounts();
        const agentEthAddr = accounts[0].ethAddr;

        const offerings = await clientWs.getClientOfferings(
          agentEthAddr,
          100,
          200,
          ['KG']
        );

        offering = offerings.items[0];

        expect(offerings.totalItems).to.equal(4);
        expect(offering.blockNumberUpdated).should.not.equal(1);
      });

      it('client should accept an offering', async () => {
        const accounts = await agentWs.getAccounts();
        const agentEthAddr = accounts[0].ethAddr;

        channelId = await ws.acceptOffering(
          agentEthAddr,
          offering.id,
          1000, 15000
        );

        expect(channelId).to.not.be.undefined;
      });

      it.skip('client should activate channel', async () => {
        await clientWs.changeChannelStatus(channelId, 'stop');
      })
    });
  }
};
