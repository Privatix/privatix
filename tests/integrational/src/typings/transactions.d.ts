export interface Transaction {
    addrFrom: string;
    addrTo: string;
    gas: number;
    gasPrice: number;
    hash: string;
    id: string;
    issued: string;
    jobID: string;
    method: string;
    nonce: string;
    relatedID: string;
    relatedType: string;
    status: string;
    txRaw: string;
}
