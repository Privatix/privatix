import { expect } from 'chai';
import 'mocha';

import { WS } from './../utils/ws';

import { skipBlocks, getEth } from '../utils/eth';
import {
  generateOffering,
  generateSomeOfferings
} from '../utils/offerings';

import { Account } from './../typings/accounts';
import { LocalSettings } from './../typings/settings';
import { Offering, OfferStatus } from '../typings/offerings';
import { PaginatedResponse} from '../typings/paginatedResponse';

const configs = require('../configs/config.json') as LocalSettings;

describe('first login', () => {
  describe('configs file', () => {
    it('should be read', () => {
      expect(configs).to.not.be.undefined;
    });

    it('should contain required endpoints', () => {
      expect(configs).to.have.property('agentWsEndpoint');
      expect(configs).to.have.property('clientWsEndpoint');
      expect(configs).to.have.property('getPrixEndpoint');
    });

    it('should be valid environment', () => {
      expect(process.env).to.have.property('TELEGRAM_BOT_USER');
      expect(process.env).to.have.property('TELEGRAM_BOT_PASSWORD');
    });
  });

  describe('websocket communication', () => {
    let agent: WS;
    let client: WS;

    it('should initialize agent websocket connection', async () => {
      agent = new WS(configs['agentWsEndpoint']);

      // wait for ws ready
      return agent.whenReady();
    });

    it.skip('should initialize client websocket connection', async () => {
      client = new WS(configs['clientWsEndpoint']);

      // wait for ws ready
      return client.whenReady();
    });

    describe('setting password', () => {
      let agentPwd: string;
      let clientPwd: string;

      it('should generate agent and client passwords', () => {
        agentPwd = Math.random().toString(36).substring(5);
        clientPwd = Math.random().toString(36).substring(5);

        expect(agentPwd.length).to.be.greaterThan(6);
        expect(clientPwd.length).to.be.greaterThan(6);
        expect(agentPwd).to.not.equal(clientPwd);
      });

      it('should set agent password', async () => {
        return await agent.setPassword(agentPwd);
      });

      it.skip('should set client password', async () => {
        return await client.setPassword(clientPwd);
      });

      it.skip('should fail with wrong password', async () => {
        const wrongPwd = agent.setPassword('wrongPasswd');

        return expect(wrongPwd).to.be.rejectedWith();
      });
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

    describe('get test ETH and PRIX', () => {
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

    describe('offering popup', () => {
      const productId = 'ffbe3aaf-ebae-4c7f-b75c-fff305bc45a4';

      let offeringId: string;

      it('should create an offering', async () => {
        const accounts = await agent.getAccounts();
        const agentId = accounts[0].id;

        offeringId = await agent.createOffering(
          generateOffering(productId, agentId, 'Main Service')
        ) as string;

        expect(offeringId).to.not.be.undefined;
      });

      it('should create some additional offerings', async function() {
        const accounts = await agent.getAccounts();
        const agentId = accounts[0].id;

        // TODO: don't know how to fix this in another way yet
        this.timeout(1000 * 4);

        for (let offering of generateSomeOfferings(productId, agentId)) {
          await agent.createOffering(offering);
        }
      });

      it('should contain already created offerings for agent', async () => {
        const offerings = await agent.getAgentOfferings(
          productId,
          OfferStatus.empty,
          0, 10
        ) as PaginatedResponse<Array<Offering>>;

        expect(offerings.totalItems).to.equal(4);
        expect(offerings.items[0].id).to.equal(offeringId);
      });

      it.skip('first offering should be last for client', async () => {
        const accounts = await agent.getAccounts();
        const agentEthAddr = accounts[0].ethAddr;

        const offerings = await client.getClientOfferings(
          agentEthAddr,
          100,
          200,
          ['KG']
        );

        expect(offerings.totalItems).to.equal(4);
        expect(offerings.items[3].id).to.equal(offeringId);
      });

      it('should popup an offering', async function() {
        const testTimeout = configs.timeouts.blocktime*(configs.timeouts.getEther.skipBlocks+1) + configs.timeouts.getEther.botTimeoutMs;
        const getEthTimeout = configs.timeouts.blocktime * (configs.timeouts.getEther.skipBlocks);
        const getEthTick = configs.timeouts.blocktime / 3;

        this.timeout(testTimeout * 10);

        await agent.changeOfferingStatus(
          offeringId,
          'popup',
          10000
        );

        await skipBlocks(3, agent, getEthTimeout, getEthTick);

        const offering = await agent.getOffering(offeringId) as Offering;

        expect(offering.blockNumberUpdated).to.not.equal(1);
      });

      it.skip('after popup the offering should be on top', async () => {
        const accounts = await agent.getAccounts();
        const agentEthAddr = accounts[0].ethAddr;

        const offerings = await client.getClientOfferings(
          agentEthAddr,
          100,
          200,
          ['KG']
        );

        expect(offerings.totalItems).to.equal(4);
        expect(offerings.items[0].id).to.equal(offeringId);
      });
    });
  });
});
