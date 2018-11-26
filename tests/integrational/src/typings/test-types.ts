import { LocalSettings } from './settings';
import { WS } from './../utils/ws';

export interface TestInputSettings {
  agentWs?: WS; // agent websocket connection
  clientWs?: WS; // client websocket connection
  configs?: LocalSettings; // configs from file
}
