import { expect } from 'chai';
import 'mocha';

import {/* skipBlocks, */ getEth, getBlockchainTimeouts} from '../../utils/eth';
import { Until } from '../../utils/until';

import {
  TestInputSettings,
  TestModel, TestScope
} from '../../typings/test-models';


export const getEthPrix: TestModel = {
    name: 'get testFn ETH and PRIX',
    scope: TestScope.UNI,
    testFn: (settings: TestInputSettings) => {
        const { ws, allowedScope, configs } = settings;

        describe('get testFn-models ETH and PRIX', () => {
            it(`should get Prixes on the ${allowedScope}  wallet`, async function () {

                const until = Until(ws);

                const bcTimeouts = getBlockchainTimeouts();
                this.timeout(bcTimeouts.testTimeout);

                const {TELEGRAM_BOT_USER, TELEGRAM_BOT_PASSWORD} = process.env;
                const accounts = await ws.getAccounts();
                const address = accounts[0].ethAddr;

                await getEth(configs.getPrixEndpoint, TELEGRAM_BOT_USER, TELEGRAM_BOT_PASSWORD, address);
                // await skipBlocks(configs.timeouts.getEther.skipBlocks, ws, bcTimeouts.getEthTimeout, bcTimeouts.getEthTick);
                await until
                    .object('account')
                    .withId(accounts[0].id)
                    .prop('ethBalance')
                    .becomes(balance => balance !== 0);

                const accountsAfterTopup = await ws.getAccounts();

                expect(accountsAfterTopup[0].ethBalance - accounts[0].ethBalance).to.equal(configs.getEth.ethBonus);
                expect(accountsAfterTopup[0].ptcBalance - accounts[0].ptcBalance).to.equal(configs.getEth.prixBonus);
            });

        });
    }
};
