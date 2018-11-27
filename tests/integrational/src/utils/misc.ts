import { TestScope } from "../typings/test-models";

export const getAllowedScope = (): TestScope => {
  const scope = process.env['npm_config_scope'].slice(1) || 'BOTH';

  return TestScope[scope.toUpperCase()];
};
