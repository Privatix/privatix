import 'mocha';

import { LocalSettings } from './../typings/settings';
import { TestInputSettings } from '../typings/test-models';

import { getAllowedScope } from '../utils/misc';
import { createSmokeTestFactory } from '../utils/tests-creator';

import { configurationCheckTest } from './init-tests/configuration.spec';
import { wsInitializationTest } from './init-tests/ws-initialization.spec';

import { smokeAutoTests } from './smoke-tests';

describe('integrational tests', () => {
  let testSettings: TestInputSettings = {
    configs: require('../configs/config.json') as LocalSettings
  };

  // check config file and environment
  configurationCheckTest(testSettings);

  // initialize websocket connections
  // TODO: don't know how to separate ws init-tests better =\
  wsInitializationTest.call(testSettings, testSettings);

  // start smoke auto-tests
  describe('smoke auto-tests', () => {
    const allowedScope = getAllowedScope();
    smokeAutoTests.forEach(createSmokeTestFactory(testSettings, allowedScope));

    // smokeAutoTests.forEach((tm: TestModel) => {
    //   const it = getItFunc(tm, allowedScope);
    //
    //   it(tm.name, () => tm.testFn(testSettings));
    // });
  });
});
