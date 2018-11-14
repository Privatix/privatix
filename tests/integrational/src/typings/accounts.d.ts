export interface Account {
    id: string;
    name: string;
    ethAddr: string;
    ethBalance: number;
    isDefault: boolean;
    inUse: boolean;
    pscBalance: number;
    ptcBalance: number;
}
