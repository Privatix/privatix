import {fetch} from './fetch';
import {LocalSettings} from '../typings/settings';
import {Transaction} from '../typings/transactions';

import * as Settings from './api/settings';
export const settings = Settings;

import * as Offerings from './api/offerings';
export const offerings = Offerings;

import * as UserRole from './api/userrole';
export const userrole = UserRole;

export const getTransactionsByAccount = async function(account: string): Promise<Transaction[]>{
    const endpoint = '/transactions' + (account === 'all' ? '' : `?relatedID=${account}&relatedType=account`);
    return fetch(endpoint, {}) as Promise<Transaction[]>;
};


export const getLocalSettings = function(): Promise<LocalSettings>{
    return Settings.getLocal() as Promise<LocalSettings>;
};


export const getUserRole = async function(): Promise<string> {
    const userRole = await userrole.get();

    return userRole;
};
