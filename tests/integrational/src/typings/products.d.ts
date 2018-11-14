export enum UsageRepType {
    inclemental = 'incremental', total = 'total'
}

export interface Product {
    id: string;
    name: string;
    config: string;
    clientIdent: string;
    isServer: boolean;
    offerAccesID: string;
    offerTplID: string;
    serviceEndpointAddress: string;
    ptcBalance: number;
    usageRepType: UsageRepType;
    country: string;
}
