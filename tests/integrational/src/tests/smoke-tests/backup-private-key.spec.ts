import {expect} from "chai";
import 'mocha';
import * as atob from 'atob';

import {
  TestInputSettings,
  TestModel, TestScope
} from '../../typings/test-models';

export const backupPrivateKey: TestModel = {
  name: 'backup private key',
  scope: TestScope.AGENT,
  testFn: (settings: TestInputSettings) => {
    const { agentWs } = settings;

    describe('backup private key', () => {

        it('should be one account', async () => {
          const accounts = await agentWs.getAccounts();

          expect(accounts.length).to.equal(1);
        });

        it('should export account', async () => {
          const accounts = await agentWs.getAccounts();
          await agentWs.exportAccount(accounts[0].id, (res: any) => {
              const account = JSON.parse(atob(res.result));

              expect(account.address).to.equal(accounts[0].ethAddr);
          });

        });

    });
  }
};
