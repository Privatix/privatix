import { expect } from 'chai';
import 'mocha';
import fetch from 'node-fetch';

import { getAllowedScope } from '../../utils/misc';
import { WS } from '../../utils/ws';
import { TestInputSettings } from '../../typings/test-models';

export async function wsInitialization(settings: TestInputSettings) {
  const { configs } = settings;

    const agentWsEndpoint = process.env['AGENT_WS_ENDPOINT'] ? process.env['AGENT_WS_ENDPOINT'] : configs.agentWsEndpoint;
    const clientWsEndpoint = process.env['CLIENT_WS_ENDPOINT'] ? process.env['CLIENT_WS_ENDPOINT'] : configs.clientWsEndpoint;
    const clientSupervisorEndpoint = process.env['CLIENT_SUPERVISOR_ENDPOINT'] ? process.env['CLIENT_SUPERVISOR_ENDPOINT'] : configs.clientSupervisorEndpoint;

  const scopes = getAllowedScope();

      this.timeout = 20000;
      if(scopes.includes('AGENT') || scopes.includes('BOTH') || scopes.includes('UNI')){
          this.agentWs = new WS(agentWsEndpoint);
          settings.agentWs = this.agentWs;
          // wait for ws ready
          await this.agentWs.whenReady();
      }

      if(scopes.includes('CLIENT') || scopes.includes('BOTH') || scopes.includes('UNI')){
            const res = await fetch(`${clientSupervisorEndpoint}/start`);
            expect(res.status).to.be.equal(200);
            this.clientWs = new WS(clientWsEndpoint);
            settings.clientWs = this.clientWs;
            // wait for ws ready
            await this.clientWs.whenReady();
      }
}
