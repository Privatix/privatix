import 'mocha';
import {TestInputSettings, TestModel, TestScope} from "../typings/test-models";

// export type SmokeTestCreator = (tm: TestModel) => it;

export const createSmokeTestFactory =
  (
    testSettings: TestInputSettings
  ) => {
    return (testModel: TestModel) => {
      const { name, testFn } = testModel;
      const { allowedScope } = testSettings;

      const itFunc = getItFunc(testModel, allowedScope);
      return itFunc(name, () => testFn(testSettings));
    }
  };

export const getItFunc =
  (testModel: {scope: TestScope}, allowedScope: TestScope) => {
    const { scope } = testModel;

    let itFunc: Function;
    if (allowedScope !== TestScope.BOTH && scope !== allowedScope) {
      itFunc = it.skip;
    } else {
      itFunc = it;
    }

    return itFunc;
  };
