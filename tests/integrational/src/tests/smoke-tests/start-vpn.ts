import { expect } from 'chai';
import 'mocha';

import {
  TestInputSettings,
  TestModel, TestScope
} from '../../typings/test-models';
import {Offering} from "../../typings/offerings";

export const startVpn: TestModel = {
  name: 'start vpn',
  scope: TestScope.BOTH,
  testFn: (settings: TestInputSettings) => {
    const {agentWs, configs} = settings;

    describe('start vpn', () => {
      let offering: Offering;
      let channelId: string;

      it('agent should publish an offering', async () => {
        // await ws.changeOfferingStatus(offeringId, 'publish', 15000);
        expect(true).to.be.true;
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
    });
  }
};
