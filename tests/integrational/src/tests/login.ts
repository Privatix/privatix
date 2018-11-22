import { expect } from 'chai';
import 'mocha';

import { WS } from './../utils/ws';

import { Account } from './../typings/accounts';
import { LocalSettings } from './../typings/settings';

import { skipBlocks, getEth } from '../utils/etc';

const configs = require('../configs/config.json') as LocalSettings;

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
/*
    it('should fail with wrong password', async () => {
      const wrongPwd = agent.setPassword('wrongPasswd');

      return expect(wrongPwd).to.be.rejectedWith();
    });
*/
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

  describe('get test ETH and PRIX', () => {

    it('should be read', () => {
      expect(configs).to.not.be.undefined;
    });

    it('should be proper enviroment', () => {
      expect(configs).to.have.property('getPrixEndpoint');
      expect(process.env).to.have.property('TELEGRAM_BOT_USER');
      expect(process.env).to.have.property('TELEGRAM_BOT_PASSWORD');
    });

    it('should get Prixes on the wallet', async function (/* done */){
      const testTimeout = configs.timeouts.blocktime*(configs.timeouts.getEther.skipBlocks+1) + configs.timeouts.getEther.botTimeoutMs;
      const getEthTimeout = configs.timeouts.blocktime*(configs.timeouts.getEther.skipBlocks);
      const getEthTick = configs.timeouts.blocktime/3;

      this.timeout(testTimeout);

      const {TELEGRAM_BOT_USER, TELEGRAM_BOT_PASSWORD} = process.env;
      const accounts = await agent.getAccounts();
      const address = accounts[0].ethAddr;

      await getEth(configs.getPrixEndpoint, TELEGRAM_BOT_USER, TELEGRAM_BOT_PASSWORD, address);
      await skipBlocks(configs.timeouts.getEther.skipBlocks, agent, getEthTimeout, getEthTick);
      const accountsAfterTopup = await agent.getAccounts();

      expect(accountsAfterTopup[0].ethBalance - accounts[0].ethBalance).to.equal(configs.getEth.ethBonus);
      expect(accountsAfterTopup[0].ptcBalance - accounts[0].ptcBalance).to.equal(configs.getEth.prixBonus);
      });

  });

  });

});
