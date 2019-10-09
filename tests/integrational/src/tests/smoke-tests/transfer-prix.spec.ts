import { expect } from 'chai';
import 'mocha';

import { skipBlocks, getBlockchainTimeouts } from '../../utils/eth';
import {
    TestInputSettings,
    TestModel, TestScope
} from '../../typings/test-models';

export const transferPrix: TestModel = {
    name: 'transfer PRIX: exchange balance → service balance',
    scope: TestScope.UNI,
    testFn: (settings: TestInputSettings) => {
        const { ws, allowedScope, configs } = settings;

        describe('transfer PRIX: exchange balance → service balance', () => {
            it(`should send PRIX on ${allowedScope} Service balance`, async function() {
                const accounts = await ws.getAccounts();
                const account = accounts[0];

                await ws.transferTokens(account.id, 'psc', configs.transferPrix.prixToPsc, configs.transferPrix.gasPrice);

                const bcTimeouts = getBlockchainTimeouts();
                this.timeout(2*bcTimeouts.testTimeout);
                await skipBlocks(configs.timeouts.getEther.skipBlocks, ws, bcTimeouts.getEthTimeout, bcTimeouts.getEthTick);

                await ws.updateBalance(account.id);
                await skipBlocks(configs.timeouts.getEther.skipBlocks, ws, bcTimeouts.getEthTimeout, bcTimeouts.getEthTick);
                const accountsTransferTokens = await ws.getAccounts();

                expect(accountsTransferTokens[0].pscBalance).to.equal(account.pscBalance + configs.transferPrix.prixToPsc);
                expect(accountsTransferTokens[0].ptcBalance).to.equal(account.ptcBalance - configs.transferPrix.prixToPsc);
            });
        });

        describe('transfer PRIX: service balance → exchange balance', () => {
            it('should send PRIX on Exchange balance', async function() {
                const accounts = await ws.getAccounts();
                const account = accounts[0];

                await ws.transferTokens(account.id, 'ptc', configs.transferPrix.prixToPtc, configs.transferPrix.gasPrice);

                const bcTimeouts = getBlockchainTimeouts();
                this.timeout(bcTimeouts.testTimeout);
                await skipBlocks(configs.timeouts.getEther.skipBlocks, ws, bcTimeouts.getEthTimeout, bcTimeouts.getEthTick);

                const accountsTransferTokens = await ws.getAccounts();

                expect(accountsTransferTokens[0].ptcBalance).to.equal(account.ptcBalance + configs.transferPrix.prixToPtc);
                expect(accountsTransferTokens[0].pscBalance).to.equal(account.pscBalance - configs.transferPrix.prixToPtc);
            })
        });

    }
};
