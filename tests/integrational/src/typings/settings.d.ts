export interface GasConsumption {
    acceptOffering: number;
    createOffering: number;
    transfer: number;
    increaseDeposit: number;
}

export interface LocalSettings {
    firstStart: boolean;
    accountCreated: boolean;
    apiEndpoint: string;
    wsEndpoint: string;
    gas: GasConsumption;
    network: string;
    bugsnagKey: string;
    bugsnagEnable: boolean;
    release: string;
    commit: string;
    logsCountPerPage: number;
    elementsPerPage: number;
    lang: string;
}

export interface DbSetting {
    key: string;
    value: string;
    description: string;
    name: string;
}
