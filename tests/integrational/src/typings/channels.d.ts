import {Job} from './job';

export type ServiceStatus = 'pending' | 'active' | 'suspended' | 'terminanted';
export type ChannelStatus = 'pending' | 'active' | 'wait_coop' | 'closed_coop' | 'wait_challenge' | 'in_challenge' | 'wait_uncoop' | 'closed_uncoop';
export type ChannelActions = 'terminate' | 'pause' | 'resume';

export interface Channel{
    id: string;
    agent: string;
    client: string;
    offering: string;
    block: number;
    channelStatus: string;
    serviceStatus: ServiceStatus;
    serviceChangedTime: string;
    totalDeposit: number;
    receiptBalance: number;
    receiptSignature: string;
}


export interface ClientChannelStatus {
    serviceStatus: ServiceStatus;
    channelStatus: ChannelStatus;
    lastChanged: string;
    maxInactiveTime: number;
}

export interface ClientChannelUsage {
    current: number;
    maxUsage: number;
    unit: string;
    cost: number;
}
// TODO remove
export interface ClientChannel {
    id: string;
    agent: string;
    client: string;
    offering: string;
    deposit: number;
    channelStatus: ClientChannelStatus;
    job: Job;
    usage: ClientChannelUsage;
}

export interface OneChannelStatus {
    code?: number;
    status: ChannelStatus;
}
