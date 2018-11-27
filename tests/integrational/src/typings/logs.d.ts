export interface Logs{
    items: Log[];
    current: number;
    pages: number;
}

export interface Log{
    time: string;
    level: string;
    message: string;
    context: string;
    stack: number;
}
