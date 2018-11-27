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

        expect(accountsTransferTokens[0].pscBalance).to.equal(configs.transferPrix.prixToPsc);
        expect(accountsTransferTokens[0].ptcBalance).to.equal(account.ptcBalance - configs.transferPrix.prixToPsc);
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

        expect(accountsTransferTokens[0].ptcBalance).to.equal(account.ptcBalance + configs.transferPrix.prixToPtc);
        expect(accountsTransferTokens[0].pscBalance).to.equal(account.pscBalance - configs.transferPrix.prixToPtc);
      })
    });

  }
};
