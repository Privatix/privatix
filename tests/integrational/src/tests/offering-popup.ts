import { expect } from 'chai';
import 'mocha';

import { WS } from './../utils/ws';

// import { Offering, OfferStatus } from './../typings/offerings';
const configs = require('../configs/config.json');

describe('offering popup', () => {
  it('should pass empty test', () => {
    expect(true).to.be.true;
  });

  describe('websocket communication', () => {
    let agent: WS;

    before('initialize websocket connection', async () => {
      agent = new WS(configs['agentWsEndpoint']);

      // wait for ws ready
      return agent.whenReady();
    });
  });
});
