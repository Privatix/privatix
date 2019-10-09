import { LocalSettings } from './settings';
import { WS } from '../utils/ws';

export enum TestScope {
  NONE = 'NONE',
  AGENT = 'AGENT',
  CLIENT = 'CLIENT',
  BOTH = 'BOTH',
  UNI= 'UNI'
}

export interface TestInputSettings {
  agentWs?: WS; // agent websocket connection
  clientWs?: WS; // client websocket connection
  ws?: WS; //  websocket connection for UNI tests
  configs?: LocalSettings; // configs from file
  allowedScope?: TestScope; // scope to run
}

export interface TestModel {
  name: string;
  testFn: (settings: TestInputSettings) => void;
  scope: TestScope;
}
