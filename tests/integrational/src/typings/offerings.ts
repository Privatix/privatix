export enum BillType {
    prepaid = 'prepaid', postpaid = 'postpaid'
}

export enum OfferStatus {
    undef='', empty = 'empty', register = 'register', remove = 'remove'
}

export enum MsgStatus {
    unpublished = 'unpublished'
   ,bchainPublishing = 'bchain_publishing'
   ,bchainPublished = 'bchain_published'
   ,msg_channelPublished = 'msg_channel_published'
}

export enum UnitType {
    units = 'units', seconds = 'seconds'
}

export interface Offering {
    additionalParams: string;
    agent: string;
    billingInterval: number;
    billingType: BillType;
    blockNumberUpdated: number;
    country: string;
    description: string;
    freeUnits: number;
    hash: string;
    id: string;
    is_local: boolean;
    maxBillingUnitLag: number;
    maxInactiveTimeSec: number;
    maxSuspendTime: number;
    maxUnit: number;
    minUnits: number;
    offerStatus: OfferStatus;
    product: string;
    rawMsg: string;
    serviceName: string;
    setupPrice: number;
    status: MsgStatus;
    supply: number;
    template: string;
    unitName: string;
    unitPrice: number;
    unitType: UnitType;
}
