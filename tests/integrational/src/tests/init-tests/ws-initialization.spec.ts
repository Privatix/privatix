import { expect } from 'chai';
import 'mocha';
import fetch from 'node-fetch';

import { getAllowedScope } from '../../utils/misc';
import { WS } from '../../utils/ws';
import { TestInputSettings } from '../../typings/test-models';

export async function wsInitialization(settings: TestInputSettings) {
  const { configs } = settings;
  const scopes = getAllowedScope();

      this.timeout = 20000;
      if(scopes.includes('AGENT') || scopes.includes('BOTH') || scopes.includes('UNI')){
          this.agentWs = new WS(configs['agentWsEndpoint']);
          settings.agentWs = this.agentWs;
          // wait for ws ready
          await this.agentWs.whenReady();
      }

      if(scopes.includes('CLIENT') || scopes.includes('BOTH') || scopes.includes('UNI')){
            const res = await fetch(`${configs.clientSupervisorEndpoint}/start`);
            expect(res.status).to.be.equal(200);
            this.clientWs = new WS(configs['clientWsEndpoint']);
            settings.clientWs = this.clientWs;
            // wait for ws ready
            await this.clientWs.whenReady();
      }
}
