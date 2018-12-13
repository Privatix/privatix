import {expect} from "chai";
import 'mocha';

import { Account } from '../../typings/accounts';
import {
  TestInputSettings,
  TestModel, TestScope
} from '../../typings/test-models';
import {getItFunc} from "../../utils/test-utils";

export const firstLoginTestFn = (scopeName, wsConn) => {
  describe(`generating ${scopeName} account`, () => {
    let accountId: string;

    it(`should be zero ${scopeName} accounts before generating`, async () => {
      const accounts = await wsConn.getAccounts();

      expect(accounts.length).to.equal(0);
    });

    it(`should generate new ${scopeName} account`, async () => {
      accountId = await wsConn.generateAccount({
        isDefault: true,
        inUse: true,
        name: 'main'
      }) as string;
    });

    it(`should contain already generated ${scopeName} account`, async () => {
      const accounts: Account[] = await wsConn.getAccounts();

      expect(accounts.length).to.equal(1);
      expect(accounts[0].id).to.equal(accountId);
    });
  })
};

export const firstLogin: TestModel = {
  name: 'first login',
  scope: TestScope.AGENT,
  testFn: (settings: TestInputSettings) => {
    describe('first login', () => {
      const {
        agentWs, clientWs, allowedScope
      } = settings;

      const agentIt = getItFunc({scope: TestScope.AGENT}, allowedScope);
      agentIt('first agent login', () =>
        firstLoginTestFn('agent', agentWs));

      const clientIt = getItFunc({scope: TestScope.CLIENT}, allowedScope);
      clientIt('first client login', () =>
        firstLoginTestFn('client', clientWs));
    });
  }
};
