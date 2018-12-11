import { TestScope } from "../typings/test-models";

export const getAllowedScope = (): TestScope => {
  const scope = process.env['npm_config_scope'].slice(1) || 'BOTH';

  return TestScope[scope.toUpperCase()];
};

export const getClientIP = async () =>  {
  return new Promise((resolve, reject) => {
    const http = require('http');

    http.get('http://ident.me/', res => {
      let data = '';

      res.on('data', chumk => data += chumk);
      res.on('end', () => resolve(data))
    }, err => reject(err));
  });
};
