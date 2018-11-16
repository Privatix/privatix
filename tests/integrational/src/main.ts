import { WS } from './utils/ws';
import * as api from './utils/api';

async function login() {
  const settings = await api.settings.getLocal();
  const ws = new WS(settings.wsEndpoint);
  const ready = await ws.whenReady();

  if (ready) {
    // TODO: generate random password?
    const pwd = 'password';
    const body = { pwd };

    await fetch('/login', {method: 'post', body});
    await ws.setPassword(pwd);

    // TODO notice if server returns error (not implemented on dappctrl yet)
    const mode = await api.getUserRole();
  }
}
