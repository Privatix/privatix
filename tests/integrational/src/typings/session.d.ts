export interface Session {
    id: string,
    channel: string,
    started: string,
    stopped: string,
    unitsUsed: number,
    secondsConsumed: number,
    lastUsageTime: string,
    serverIP: string,
    serverPort: number,
    clientIP: string,
    clientPort: number
 }