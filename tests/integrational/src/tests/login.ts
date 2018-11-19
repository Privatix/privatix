import { expect } from 'chai';
import 'mocha';

import { WS } from './../utils/ws';

import { Account } from './../typings/accounts';
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
    let agentPwd: string;
    let agent: WS;

    before('generate agent password', () => {
      agentPwd = Math.random().toString(36).substring(5);
    });

    before('initialize websocket connection', async () => {
      agent = new WS(configs['agentWsEndpoint']);

      // wait for ws ready
      return agent.whenReady();
    });

    it('should set agent password', async () => {
      return await agent.setPassword(agentPwd);
    });

    it('should fail with wrong password', async () => {
      const wrongPwd = agent.setPassword('wrongPasswd');

      return expect(wrongPwd).to.be.rejectedWith();
    });

    describe('generating agent account', () => {
      let accountId: string;

      it('should be zero accounts before generating', async () => {
        const accounts = await agent.getAccounts();
        expect(accounts.length).to.equal(0);
      });

      it('should generate new agent account', async () => {
        accountId = await agent.generateAccount({
          isDefault: true,
          inUse: true,
          name: 'main'
        }) as string;
      });

      it('should contain already generated account', async () => {
        const accounts: Account[] = await agent.getAccounts();

        expect(accounts.length).to.equal(1);
        expect(accounts[0].id).to.equal(accountId);
      })
    });
  });
});
