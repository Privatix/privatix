import {expect} from "chai";
import 'mocha';

import { Account } from '../../typings/accounts';
import {
  TestInputSettings,
  TestModel, TestScope
} from '../../typings/test-models';

export const firstLogin: TestModel = {
  name: 'first login',
  scope: TestScope.AGENT,
  testFn: (settings: TestInputSettings) => {
    const { agentWs } = settings;

    describe('first login', () => {
      describe('generating agent account', () => {
        let accountId: string;

        it('should be zero accounts before generating', async () => {
          const accounts = await agentWs.getAccounts();

          expect(accounts.length).to.equal(0);
        });

        it('should generate new agent account', async () => {
          accountId = await agentWs.generateAccount({
            isDefault: true,
            inUse: true,
            name: 'main'
          }) as string;
        });

        it('should contain already generated account', async () => {
          const accounts: Account[] = await agentWs.getAccounts();

          expect(accounts.length).to.equal(1);
          expect(accounts[0].id).to.equal(accountId);
        });
      });
    });
  }
};
