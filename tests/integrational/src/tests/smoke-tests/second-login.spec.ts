import {expect} from "chai";
import 'mocha';

import {
  TestInputSettings,
  TestModel, TestScope
} from '../../typings/test-models';

export const secondLogin: TestModel = {
  name: 'second login',
  scope: TestScope.AGENT,
  testFn: (settings: TestInputSettings) => {
    const { agentWs } = settings;

    describe('second login', () => {

        it('should be one account', async () => {
          const accounts = await agentWs.getAccounts();

          expect(accounts.length).to.equal(1);
        });

        it('should be two products', async () => {
          const products = await agentWs.getProducts();

          expect(products.length).to.equal(2);
        });

    });
  }
};
