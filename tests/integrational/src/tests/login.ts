import { expect } from 'chai';
import 'mocha';

import { WS } from './../utils/ws';

const configs = require('../configs/config.json');

describe('first login', () => {
  describe('configs file', () => {
    it('should be read', () => {
      expect(configs).to.not.be.undefined;
    });

    it('should contain websocket endpoint property', () => {
      expect(configs).to.have.property('agentWsEndpoint');
    });
  });

  describe('websocket communication', () => {
    let agent: WS;

    before('initialize websocket connection', async () => {
      agent = new WS(configs['agentWsEndpoint'], client);

      // wait for ws ready
      return agent.whenReady();
    });

    it('should set agent password', async () => {
      await agent.setPassword('hardcodedPasswd');
    });

    describe('generating agent account', () => {
      let accountId: string, accountRes: string;

      it('should be zero accounts before generating', async () => {
        const accounts = await agent.getAccounts();
        expect(accounts.length).to.equal(0);
      });

      it('should generate new agent account', async () => {
        const res = await agent.generateAccount({
          isDefault: true,
          inUse: true,
          name: 'main'
        });

        accountId = res.id;
        accountRes = res.result;
      });

      it('should contain already generated account', async () => {
        const accounts = await agent.getAccounts();

        expect(accounts.length).to.equal(1);
      })
    });
  });
});
