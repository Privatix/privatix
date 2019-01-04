import { expect } from 'chai';
import 'mocha';

import {
  TestInputSettings,
  TestModel, TestScope
} from '../../typings/test-models';
import { Offering } from '../../typings/offerings';

import { getItFunc } from '../../utils/test-utils';
import { getClientIP } from '../../utils/misc';

export const startVpn: TestModel = {
  name: 'start vpn',
  scope: TestScope.BOTH,
  testFn: (settings: TestInputSettings) => {
    const {
      agentWs, clientWs,
      allowedScope, configs
    } = settings;

    const clientIt = getItFunc({scope: TestScope.CLIENT}, allowedScope);

    describe('VPN', () => {
      let channelId: string;

      describe('start using VPN', () => {
        let offering: Offering;
        let clientLocalIP: string;

        clientIt('should get local client IP', async () => {
          clientLocalIP = await getClientIP(configs['externalClientIpEndpoint']) as string;

          expect(clientLocalIP).to.not.be.undefined;
        });

        clientIt('client should get top offering', async () => {
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

        clientIt('client should accept an offering', async function() {
          // TODO: not sure about mining

          const timeouts = settings.configs.timeouts;
          this.timeout(timeouts.blocktime*4);

          const accounts = await agentWs.getAccounts();
          const agentEthAddr = accounts[0].ethAddr;

          channelId = await clientWs.acceptOffering(
            agentEthAddr,
            offering.id,
            1000, 15000
          ) as string;

          expect(channelId).to.not.be.undefined;
        });

        clientIt('client should activate channel', async () => {
          await clientWs.changeChannelStatus(
            channelId, 'resume'
          );
        });

        clientIt('client IP should change', async () => {
          const newClientIP = await getClientIP(configs['externalClientIpEndpoint']) as string;

          expect(clientLocalIP).to.not.equals(newClientIP);
        });
      });

      describe('stop using VPN', () => {
        let clientRemoteIP: string;

        clientIt('should get client VPN IP', async () => {
          clientRemoteIP = await getClientIP(configs['externalClientIpEndpoint']) as string;

          expect(clientRemoteIP).to.not.be.undefined;
        });

        clientIt('client should terminate active channel', async () => {
          // TODO: mb should be 'close' instead of 'terminate'
          await clientWs.changeChannelStatus(
            channelId, 'terminate'
          );
        });

        clientIt('client IP should change to local', async () => {
          const newClientIP = await getClientIP(configs['externalClientIpEndpoint']) as string;

          expect(newClientIP).to.not.equals(clientRemoteIP);
        })
      });
    });
  }
};
