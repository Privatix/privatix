import { expect } from 'chai';
import 'mocha';

import { client } from 'websocket';
import { WS } from './../utils/ws';

const configs = require('../configs/config.json');

describe('first login', () => {
  let agent: WS;

  before('initialize websocket connection', async () => {
    agent = new WS(configs['wsEndpoint'], client);

    // wait for ws ready
    await agent.whenReady();
  });

  it('should set agent password', async () => {
    await agent.setPassword('hardcodedPasswd');
  });

  it('should be zero accounts before test', async () => {
    const accounts = await agent.getAccounts();
    expect(accounts.length).to.equal(0);
  });
});
