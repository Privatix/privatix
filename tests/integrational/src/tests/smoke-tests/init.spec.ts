import { expect } from 'chai';
import 'mocha';
import { TestInputSettings, TestModel, TestScope } from '../../typings/test-models';

export const init: TestModel = {
  name: 'generate and set password',
  scope: TestScope.UNI,
  testFn: (settings: TestInputSettings) => {

      const { ws, allowedScope } = settings;

        describe('setting passwords', () => {
            let pwd: string;

            it(`should generate ${allowedScope} password`, () => {

                pwd = Math.random().toString(36).substring(5);
                expect(pwd.length).to.be.greaterThan(6);

            });

            it('should set agent password', async () => {

                const res = await ws.setPassword(pwd);

                expect(res).to.be.true;

            });

            it(`should fail with wrong ${allowedScope} password`, async () => {
                await ws.setPassword('wrongPasswd')
                    .catch(e => {
                        expect(e.code).to.equal(-32000);
                    });

                // Set right password
                await ws.setPassword(pwd);
            });
        });

         // return settings;
    }
};
