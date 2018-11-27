import { expect } from 'chai';
import 'mocha';

import { skipBlocks, getBlockchainTimeouts } from '../../utils/eth';
import {
  TestInputSettings,
  TestModel, TestScope
} from '../../typings/test-models';

export const transferPrix: TestModel = {
  name: 'transfer PRIX: exchange balance → service balance',
  scope: TestScope.AGENT,
  testFn: (settings: TestInputSettings) => {
    const { agentWs, configs } = settings;

    describe('transfer PRIX: exchange balance → service balance', () => {
      it('should send PRIX on Service balance', async function() {
        const accounts = await agentWs.getAccounts();
        const account = accounts[0];

        await agentWs.transferTokens(account.id, 'psc', configs.transferPrix.prixToPsc, configs.transferPrix.gasPrice);

        const bcTimeouts = getBlockchainTimeouts();
        this.timeout(bcTimeouts.testTimeout);
        await skipBlocks(configs.timeouts.getEther.skipBlocks, agentWs, bcTimeouts.getEthTimeout, bcTimeouts.getEthTick);

        const accountsTransferTokens = await agentWs.getAccounts();

        expect(configs.transferPrix.prixToPsc).to.equal(accountsTransferTokens[0].pscBalance);
        expect(account.ptcBalance - configs.transferPrix.prixToPsc).to.equal(accountsTransferTokens[0].ptcBalance);
      });
    });

    describe('transfer PRIX: service balance → exchange balance', () => {
      it('should send PRIX on Exchange balance', async function() {
        const accounts = await agentWs.getAccounts();
        const account = accounts[0];

        await agentWs.transferTokens(account.id, 'ptc', configs.transferPrix.prixToPtc, configs.transferPrix.gasPrice);

        const bcTimeouts = getBlockchainTimeouts();
        this.timeout(bcTimeouts.testTimeout);
        await skipBlocks(configs.timeouts.getEther.skipBlocks, agentWs, bcTimeouts.getEthTimeout, bcTimeouts.getEthTick);

        const accountsTransferTokens = await agentWs.getAccounts();

        expect(account.ptcBalance + configs.transferPrix.prixToPtc).to.equal(accountsTransferTokens[0].ptcBalance);
        expect(account.pscBalance - configs.transferPrix.prixToPtc).to.equal(accountsTransferTokens[0].pscBalance);
      })
    });

  }
};
