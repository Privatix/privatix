import { expect } from 'chai';
import 'mocha';

import {
  TestInputSettings,
  TestModel, TestScope
} from '../../typings/test-models';
import {Offering} from '../../typings/offerings';
import {Channel} from '../../typings/channels';

import { getItFunc } from '../../utils/test-utils';
import { getClientIP } from '../../utils/misc';
import {Until} from '../../utils/until';

export const startVpn: TestModel = {
  name: 'start vpn',
  scope: TestScope.BOTH,
  testFn: (settings: TestInputSettings) => {
    const {
      agentWs, clientWs,
      allowedScope, configs
    } = settings;

    const clientIt = getItFunc({scope: TestScope.CLIENT}, allowedScope);
    const until = Until(clientWs);

    describe('VPN', () => {
      let channelId: string;

      describe('start using VPN', () => {
        let offering: Offering;
        let clientLocalIP: string;
        let agentEthAddr: string;

        clientIt('should get local client IP', async () => {
          clientLocalIP = await getClientIP(configs['externalClientIpEndpoint']) as string;

          expect(clientLocalIP).to.not.be.undefined;
        });

        clientIt('client should get top offering', async () => {
          const accounts = await agentWs.getAccounts();
          agentEthAddr = accounts[0].ethAddr;

          const offerings = await clientWs.getClientOfferings(
            agentEthAddr,
              100000,
              200000,
              ['KG']
          );

          offering = offerings.items[0];

          expect(offerings.totalItems > 0).to.be.true;
          expect(offering.blockNumberUpdated).to.not.equal(1);
        });

        clientIt('client should accept an offering', async function() {
          const clientAccounts = await clientWs.getAccounts();
          const clientAccount = clientAccounts[0];
          const address = clientAccount.ethAddr;

          const gasPrice = parseInt((await clientWs.getSettings())['eth.default.gasprice'].value, 10);
          const deposit = offering.unitPrice * offering.minUnits;

          const timeouts = settings.configs.timeouts;
          this.timeout(timeouts.blocktime * 10);

          channelId = await clientWs.acceptOffering(
            address,
            offering.id,
            deposit,
            gasPrice
          ) as string;

          await until
            .object('channel')
            .withId(channelId)
            .prop('serviceStatus')
            .becomes('suspended');

          expect(channelId.length).to.equal(36);
        });

        clientIt('client should activate channel', async function() {
          const timeouts = settings.configs.timeouts;
          this.timeout(timeouts.blocktime * 10);

          await clientWs.changeChannelStatus(channelId, 'resume');

          await until
            .object('channel')
            .withId(channelId)
            .prop('serviceStatus')
            .becomes('active');

          const channelStatus = (await clientWs.getObject('channel', channelId) as Channel).serviceStatus;

          expect(channelStatus).to.equal('active');
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

        clientIt('client should terminate active channel', async function() {
          await clientWs.changeChannelStatus(channelId, 'terminate');

          const timeouts = settings.configs.timeouts;
          this.timeout(timeouts.blocktime * 10);

          await until
            .object('channel')
            .withId(channelId)
            .prop('serviceStatus')
            .becomes('terminated');
        });

        clientIt('client IP should change to local', async () => {
          const newClientIP = await getClientIP(configs['externalClientIpEndpoint']) as string;

          expect(newClientIP).to.not.equals(clientRemoteIP);
        })
      });
    });
  }
};
