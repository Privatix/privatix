import {expect} from "chai";
import 'mocha';

import {
    TestInputSettings,
    TestModel, TestScope
} from '../../typings/test-models';

export const secondLogin: TestModel = {
    name: 'second login',
    scope: TestScope.UNI,
    testFn: (settings: TestInputSettings) => {
        const { ws } = settings;

        describe('second login', () => {

            it('should be one account', async () => {
    //          console.log(agentWs);
              const accounts = await ws.getAccounts();

              expect(accounts.length).to.equal(1);
            });

        });
    }
};

export const product: TestModel = {
  name: 'product',
  scope: TestScope.AGENT,
  testFn: (settings: TestInputSettings) => {
    const { ws } = settings;

    describe('second login', () => {

        it('should be one Agent product (is_server = true)', async () => {
          const products = await ws.getProducts();

          expect(products.length).to.equal(1);
        });

    });
  }
};
