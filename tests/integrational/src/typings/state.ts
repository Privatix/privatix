import {Account} from './accounts';
import {Mode} from './mode';
import {Product} from './products';
import {DbSetting} from './settings';
import { WS } from '../utils/ws';

interface State {
  [s: string]: any;
    accounts: Account[];
    products: Product[];
    settings: DbSetting[];
    channel: string;
    mode: Mode;
    ws: WS;
}

const StateDefault: State = {
    accounts: [],
    products: [],
    settings: [],
    channel: '',
    mode: Mode.CLIENT,
    ws: null
};

export {
    State, StateDefault
};
