import 'mocha';
import {TestInputSettings, TestModel, TestScope} from "../typings/test-models";

// export type SmokeTestCreator = (tm: TestModel) => it;

export const createSmokeTestFactory =
  (
    testSettings: TestInputSettings,
    allowedScope: TestScope = TestScope.NONE
  ) => {
    return (testModel: TestModel) => {
      const { name, scope, testFn } = testModel;

      let itFunc: Function;
      if (scope !== TestScope.NONE && scope !== allowedScope) {
        itFunc = it.skip;
      } else {
        itFunc = it;
      }

      return itFunc(name, () => testFn(testSettings));
    }
  };

export const getItFunc =
  (testModel: TestModel, allowedScope: TestScope) => {
    const { scope } = testModel;

    let itFunc: Function;
    if (scope !== TestScope.NONE && scope !== allowedScope) {
      itFunc = it.skip;
    } else {
      itFunc = it;
    }

    return itFunc;
  };
