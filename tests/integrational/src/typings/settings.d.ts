export interface BotEndpoint {
    protocol: string;
    host: string;
    port: number;
    path: string;
    method: string;
}

export interface LocalSettings {
    agentWsEndpoint: string;
    clientWsEndpoint: string;
    getPrixEndpoint: BotEndpoint;
    timeouts: {
        blocktime: number;
        getEther: {
            skipBlocks: number;
            botTimeoutMs: number
        }
    };
    getEth: {
        ethBonus: number;
        prixBonus: number;
    },
    "transferPrix": {
        "prixToPsc": number,
        "prixToPtc": number,
        "gasPrice": number
    }
}

export interface DbSetting {
    key: string;
    value: string;
    description: string;
    name: string;
}
