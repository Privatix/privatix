import 'mocha';

import { LocalSettings } from './../typings/settings';
import { TestInputSettings, TestModel } from '../typings/test-models';

import { getAllowedScope } from '../utils/misc';

import { configurationCheckTest } from './init-tests/configuration.spec';
import { wsInitializationTest } from './init-tests/ws-initialization.spec';

import { smokeAutoTests } from './smoke-tests';

let testSettings: TestInputSettings = {
    configs: require('../configs/config.json') as LocalSettings
};

describe('integrational tests', () => {

  // check config file and environment
  configurationCheckTest(testSettings);

  // initialize websocket connections
  wsInitializationTest.call(testSettings, testSettings);

  // start smoke auto-tests
  describe('smoke auto-tests', () => {
    const allowedScope = getAllowedScope();
    // smokeAutoTests.forEach(createSmokeTestFactory(testSettings, allowedScope));

    smokeAutoTests.forEach((tm: TestModel) => {
      it(tm.name, () => tm.testFn({
        allowedScope,
        ...testSettings
      }));
    });
  });

});

after(function (done) {
    const {
        agentWs, clientWs
    } = testSettings;

    agentWs.closeWsConnection();
    clientWs.closeWsConnection();
    done();
});
