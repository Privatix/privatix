import { TestScope } from "../typings/test-models";

export const getAllowedScope = (): TestScope => {
  const scope = process.env['npm_config_scope'].slice(1) || 'BOTH';

  return TestScope[scope.toUpperCase()];
};

export const getClientIP = async (endpoint) =>  {
  return new Promise((resolve, reject) => {
    const http = require('http');

    http.get(endpoint, res => {
      let data = '';

      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(data))
    }, err => reject(err));
  });
};
