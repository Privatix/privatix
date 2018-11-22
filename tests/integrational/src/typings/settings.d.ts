export interface BotEndpoint {
    protocol: string;
    host: string;
    port: number;
    path: string;
    method: string;
}

export interface LocalSettings {
    agentWsEndpoint: string;
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
    }
}

export interface DbSetting {
    key: string;
    value: string;
    description: string;
    name: string;
}
