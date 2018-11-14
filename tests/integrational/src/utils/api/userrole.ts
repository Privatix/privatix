import {fetch} from '../fetch';

export const get = function(): Promise<string>{
    return fetch('/userrole') as Promise<string>;
};

