export enum BillType {
    prepaid = 'prepaid', postpaid = 'postpaid'
}

export enum OfferStatus {
    undef='',
    empty = 'empty',
    registering = 'registering',
    registered = 'registered',
    popping_up = 'popping_up',
    popped_up = 'popped_up',
    removing = 'removing',
    removed = 'removed'
}

export enum UnitType {
    units = 'units', seconds = 'seconds'
}

export interface ClientOffering {
    additionalParams: string;
    agent: string;
    billingInterval: number;
    billingType: BillType
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
    status: OfferStatus;
    product: string;
    rawMsg: string;
    serviceName: string;
    setupPrice: number;
    supply: number;
    currentSupply: number;
    template: string;
    unitName: string;
    unitPrice: number;
    unitType: UnitType;
}
