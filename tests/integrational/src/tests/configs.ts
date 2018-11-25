import { expect } from 'chai';
import 'mocha';

const configs = require('../configs/config.json');

describe('configs file', () => {
  it('should be read', () => {
    expect(configs).to.not.be.undefined;
  });

  it('should contain agent websocket endpoint property', () => {
    expect(configs).to.have.property('agentWsEndpoint');
  });
});
