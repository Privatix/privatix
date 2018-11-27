import { expect } from 'chai';
import 'mocha';

import {skipBlocks, getEth, getBlockchainTimeouts} from '../../utils/eth';
import {
  TestInputSettings,
  TestModel, TestScope
} from '../../typings/test-models';

export const getEthPrix: TestModel = {
  name: 'get testFn ETH and PRIX',
  scope: TestScope.AGENT,
  testFn: (settings: TestInputSettings) => {
    const { agentWs, configs } = settings;

    describe('get testFn-models ETH and PRIX', () => {
      it('should get Prixes on the wallet', async function () {
        const bcTimeouts = getBlockchainTimeouts();
        this.timeout(bcTimeouts.testTimeout);

        const {TELEGRAM_BOT_USER, TELEGRAM_BOT_PASSWORD} = process.env;
        const accounts = await agentWs.getAccounts();
        const address = accounts[0].ethAddr;

        await getEth(configs.getPrixEndpoint, TELEGRAM_BOT_USER, TELEGRAM_BOT_PASSWORD, address);
        await skipBlocks(configs.timeouts.getEther.skipBlocks, agentWs, bcTimeouts.getEthTimeout, bcTimeouts.getEthTick);
        const accountsAfterTopup = await agentWs.getAccounts();

        expect(accountsAfterTopup[0].ethBalance - accounts[0].ethBalance).to.equal(configs.getEth.ethBonus);
        expect(accountsAfterTopup[0].ptcBalance - accounts[0].ptcBalance).to.equal(configs.getEth.prixBonus);
      });
    });
  }
};
