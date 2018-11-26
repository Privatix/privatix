import { expect } from 'chai';
import 'mocha';

import { WS } from './../utils/ws';
import { LocalSettings } from './../typings/settings';
// import { TestInputSettings } from '../typings/test-types';

import { configurationCheckTest } from './configuration.spec';
import { firstLoginTest } from './first-login.spec';

describe('integrational tests', () => {
  const configs = require('../configs/config.json') as LocalSettings;

  let agentWs: WS;
  let clientWs: WS;

  configurationCheckTest({ configs });

  describe('websockets initialization', () => {
    it('initialize agent websocket connection', async () => {
      agentWs = new WS(configs['agentWsEndpoint']);

      // wait for ws ready
      await agentWs.whenReady();
    });

    it('initialize client websocket connection', async () => {
      clientWs = new WS(configs['clientWsEndpoint']);

      // wait for ws ready
      await clientWs.whenReady();
    });

    describe('setting passwords', () => {
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
        await agentWs.setPassword(agentPwd);
      });

      it.skip('should set client password', async () => {
        await clientWs.setPassword(clientPwd);
      });

      it.skip('should fail with wrong agent password', async () => {
        const wrongPwd = agentWs.setPassword('wrongPasswd');

        expect(wrongPwd).to.be.rejectedWith();
      });
    });
  });

  describe('smoke auto-tests', () => {
    it('first login', () => firstLoginTest({ agentWs }));
  });
});
