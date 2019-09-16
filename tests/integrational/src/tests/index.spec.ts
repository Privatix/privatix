import 'mocha';

import { LocalSettings } from './../typings/settings';
import { TestInputSettings, TestModel } from '../typings/test-models';

import { getAllowedScope } from '../utils/misc';

import { configurationCheckTest } from './init-tests/configuration.spec';
import { wsInitialization } from './init-tests/ws-initialization.spec';

import { smokeAutoTests } from './smoke-tests';

let testSettings: TestInputSettings = {
    configs: require('../configs/config.json') as LocalSettings
};

// initialize websocket connections
before(async function(){await wsInitialization.call(testSettings, testSettings)});

describe('integrational tests', async () => {

    // check config file and environment
    configurationCheckTest(testSettings);

    // start smoke auto-tests
    describe('smoke auto-tests', async () => {
        const allowedScope = getAllowedScope();

        smokeAutoTests.forEach((tm: TestModel) => {

            if(allowedScope === 'CLIENT' && (tm.scope === 'UNI' || tm.scope === 'CLIENT')){
                it(tm.name, () => tm.testFn({allowedScope, ws: testSettings.clientWs, ...testSettings}));
            }
            if(allowedScope === 'AGENT' && (tm.scope === 'UNI' || tm.scope === 'AGENT')){
                testSettings.ws = testSettings.agentWs;
                it(tm.name, () => tm.testFn({allowedScope, ...testSettings}));
            }
            if(allowedScope === 'UNI' && tm.scope === 'UNI'){
                testSettings.ws = testSettings.clientWs;
                it(tm.name, () => tm.testFn({allowedScope, ...testSettings}));

                testSettings.ws = testSettings.agentWs;
                it(tm.name, () => tm.testFn({allowedScope, ...testSettings}));
            }

            if(allowedScope === 'BOTH'){
                switch(tm.scope){
                    case 'BOTH':
                        it(tm.name, () => tm.testFn({allowedScope, ...testSettings}));
                        break;
                    case 'UNI':
                        testSettings.ws = testSettings.clientWs;
                        it(tm.name, () => tm.testFn({allowedScope, ...testSettings}));

                        testSettings.ws = testSettings.agentWs;
                        it(tm.name, () => tm.testFn({allowedScope, ...testSettings}));
                        break;
                    case 'CLIENT':
                        testSettings.ws = testSettings.clientWs;
                        it(tm.name, () => tm.testFn({allowedScope, ...testSettings}));
                        break;
                    case 'AGENT':
                        testSettings.ws = testSettings.agentWs;
                        it(tm.name, () => tm.testFn({allowedScope, ...testSettings}));
                        break;
                }
            }
        });
    });

});

after(function (done) {

    const { agentWs, clientWs } = testSettings;

    if(agentWs){
        agentWs.closeWsConnection();
    }

    if(clientWs){
        clientWs.closeWsConnection();
    }

    done();

});
