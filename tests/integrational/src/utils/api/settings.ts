import {fetch} from '../fetch';
import {LocalSettings, DbSetting} from '../../typings/settings';
import {SaveAnswer} from '../../typings/SaveAnswer';

export const getLocal = function(): Promise<LocalSettings>{
    return fetch('/localSettings') as Promise<LocalSettings>;
};

export const saveLocal = function(settings: LocalSettings): Promise<any> {
    return fetch('/localSettings', {method: 'put', body: settings}) as Promise<any>;
};


export const updateLocal = async function(newSettings: Object): Promise<any> {
    const settings = Object.assign(await getLocal() , newSettings);
    return saveLocal(settings) as Promise<any>;
};


export const get = function(): Promise<DbSetting[]>{
    return fetch('/settings') as Promise<DbSetting[]>;
};

export const save = function(settings:DbSetting[]): Promise<SaveAnswer> {
    return fetch('/settings', {method: 'PUT', body:settings}).then((result:SaveAnswer) => {
        return result;
    });
};
