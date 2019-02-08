import * as uuidv4 from 'uuid/v4';
import {TemplateType} from '../typings/templates';
import {OfferStatus, Offering} from '../typings/offerings';
import {Account} from '../typings/accounts';
import {Transaction} from '../typings/transactions';
import {Product} from '../typings/products';
import {Session} from '../typings/session';
import {Channel, ClientChannel} from '../typings/channels';
// import {Template} from '../typings/templates';
import { Log } from '../typings/logs';
import { Role } from '../typings/role';
import { PaginatedResponse} from '../typings/paginatedResponse';

type OfferingResponse = PaginatedResponse<Offering[]>;
type ChannelResponse  = PaginatedResponse<Channel[]>;
type ClientChannelResponse  = PaginatedResponse<ClientChannel[]>;
type TransactionResponse = PaginatedResponse<Transaction[]>;
type LogResponse = PaginatedResponse<Log[]>;

const WebSocket = require('ws');

export class WS {

    static listeners = {}; // uuid -> listener
    static handlers = {}; // uuid -> handler

    static byUUID = {}; // uuid -> subscribeID
    static bySubscription = {}; // subscribeId -> uuid
    static subscriptions = {};

    private socket: WebSocket;
    private pwd: string;
    private token: string;
    private ready: Promise<boolean>;
    authorized: boolean = false;
//    private reject: Function = null;
    private resolve: Function = null;

    constructor(endpoint: string) {

        const socket = new WebSocket(endpoint, {perMessageDeflate: false});
        this.ready = new Promise((resolve: Function) => {
            // this.reject = reject;
            this.resolve = resolve;
        });
        socket.on('open', () => {
          // console.log('Connection established.');
          this.resolve(true);
        });

        socket.on('close', function(event: any) {
            if (event === 1000) {
                console.log('Connection closed.');
            } else {
                console.log('Connection interrupted.');
            }
        });

        socket.on('message',  function(event: any) {
            const msg = JSON.parse(event);
            if('id' in msg && 'string' === typeof msg.id){
                if(msg.id in WS.handlers){
                    const handler = WS.handlers[msg.id];
                    delete WS.handlers[msg.id];
                    handler(msg);
                }else {
                    if('result' in msg && 'string' === typeof msg.result){
                        WS.byUUID[msg.id] = msg.result;
                        WS.bySubscription[msg.result] = msg.id;
                        WS.subscriptions[msg.id](msg.result);
                        delete WS.subscriptions[msg.id];
                    }
                }
            }else if('method' in msg && msg.method === 'ui_subscription'){
                if(msg.params.subscription in WS.bySubscription){
                    WS.listeners[WS.bySubscription[msg.params.subscription]](msg.params.result);
                }
           } else {
               // ignore
           }
        });

        socket.on('error', function() {
          // console.log('Error ' + error.message);
        });

        this.socket = socket;
    }

    closeWsConnection() {
        this.socket.close();
    }

    whenReady(){
        return this.ready;
    }

    subscribe(entityType:string, ids: string[], handler: Function): Promise<string>{
        return new Promise((resolve: Function, reject: Function) => {
            const uuid = uuidv4();
            const req = {
                jsonrpc: '2.0',
                id: uuid,
                method: 'ui_subscribe',
                params: ['objectChange', this.token, entityType, ids]
            };
            WS.subscriptions[uuid] = () => {
                WS.listeners[uuid] = handler;
                resolve(uuid);
            };
            this.socket.send(JSON.stringify(req));
        }) as Promise<string>;
    }

    unsubscribe(id: string){

        const uuid = uuidv4();

        if(WS.listeners[id]){
            const req = {
                jsonrpc: '2.0',
	            id: uuid,
	            method: 'ui_unsubscribe',
	            params: [ WS.byUUID[id] ]
            };

            return new Promise((resolve: Function, reject: Function) => {
                const handler = function(res: any){
                    if('error' in res){
                        reject(res.error);
                    }else{
                        resolve(res.result);
                    }
                };

                WS.handlers[uuid] = handler;
                this.socket.send(JSON.stringify(req));
                delete WS.listeners[id];
                delete WS.bySubscription[WS.byUUID[id]];
                delete WS.byUUID[id];
            });
        } else {
            throw Error('not existed subscribe');
        }
    }

    send(method: string, params: any[] = []){

        const uuid = uuidv4();
        params.unshift(this.token);
        const req = {
            jsonrpc: '2.0',
            id: uuid,
            method,
            params
        };

        return new Promise((resolve: Function, reject: Function) => {
            const handler = function(res: any){
                if('error' in res){
                    reject(res.error);
                }else{
                    resolve(res.result);
                }
            };

            WS.handlers[uuid] = handler;
            this.socket.send(JSON.stringify(req));
        });
    }

    topUp(channelId: string, deposit: number, gasPrice: number, handler: Function){
        return this.send('ui_topUpChannel', [channelId, deposit, gasPrice]) as Promise<any>;
    }

// auth

    getToken(){
        const uuid = uuidv4();

        const req = {
            jsonrpc: '2.0',
            id: uuid,
            method: 'ui_getToken',
            params: [this.pwd]
        };

        return new Promise((resolve: Function, reject: Function) => {
            const handler = function(res: any){
                if('error' in res){
                    reject(res.error);
                }else{
                    resolve(res.result);
                }
            };

            WS.handlers[uuid] = handler;
            this.socket.send(JSON.stringify(req));
        });
    }

    setPassword(pwd: string){
        const uuid = uuidv4();

        const req = {
            jsonrpc: '2.0',
            id: uuid,
            method: 'ui_setPassword',
            params: [pwd]
        };

        this.pwd = pwd;

        return new Promise((resolve: Function, reject: Function) => {
            const updateToken = () => {
                this.getToken()
                    .then(token => {
                        if(token){
                            this.token = token as any;
                            this.authorized = true;
                            resolve(true);
                        }else{
                            reject(false);
                        }
                    })
                    .catch(err => {
                        reject(err);
                    });
            };

            const handler = (res: any) => {
                if('error' in res && res.error.message.indexOf('password exists') === -1){
                    reject(res.error);
                }else{
                    updateToken();
                }
            };
            WS.handlers[uuid] = handler;
            this.socket.send(JSON.stringify(req));
        });
    }

// accounts

    getAccounts(): Promise<Account[]> {
        return this.send('ui_getAccounts') as Promise<Account[]>;
    }

    generateAccount(payload: any){
        return this.send('ui_generateAccount', [payload]);
    }


    importAccountFromHex(payload: any): Promise<any>{
        return this.send('ui_importAccountFromHex', [payload]) as Promise<any>;
    }

    importAccountFromJSON(payload: any, key: Object, pwd: string, handler: Function){
        const uuid = uuidv4();
        WS.handlers[uuid] = handler;

        const req = {
            jsonrpc: '2.0',
            id: uuid,
            method: 'ui_importAccountFromJSON',
            params: [this.token, payload, key, pwd]
        };

        this.socket.send(JSON.stringify(req));
    }

    exportAccount(accountId: string, handler: Function){
        const uuid = uuidv4();
        WS.handlers[uuid] = handler;

        const req = {
            jsonrpc: '2.0',
            id: uuid,
            method: 'ui_exportPrivateKey',
            params: [this.token, accountId]
        };

        this.socket.send(JSON.stringify(req));
    }

    updateBalance(accountId: string){
        return this.send('ui_updateBalance', [accountId]);
    }

    transferTokens(accountId: string, destination: 'ptc'|'psc', tokenAmount: number, gasPrice: number){
        return this.send('ui_transferTokens', [accountId, destination, tokenAmount, gasPrice]);
    }

// templates

    getTemplates(templateType?: TemplateType){
        const type = templateType ? templateType : '';
        return this.send('ui_getTemplates', [type]);
    }

    getTemplate(id: string){
        return this.getObject('template', id);
    }


// endpoints

    getEndpoints(channelId: string, templateId: string = ''){
        return this.send('ui_getEndpoints', [channelId, templateId]);
    }

// products

    getProduct(id: string): Promise<Product> {
        return this.getObject('product', id) as Promise<Product>;
    }

    getProducts(): Promise<Product[]> {
        return this.send('ui_getProducts')  as Promise<Product[]>;
    }

    updateProduct(product: any){
        return this.send('ui_updateProduct', [product]);
    }

// offerings

    getAgentOfferings(productId: string='', status: OfferStatus = OfferStatus.undef, offset: number = 0, limit: number = 0): Promise<OfferingResponse>{
        return this.send('ui_getAgentOfferings', [productId, status, offset, limit]) as Promise<OfferingResponse>;
    }

    getClientOfferings(agent: string = ''
                      ,minUnitPrice: number = 0
                      ,maxUnitPrice: number = 0
                      ,countries: string[] = []
                      ,offset: number = 0
                      ,limit: number = 0) : Promise<OfferingResponse> {
        return this.send('ui_getClientOfferings', [agent, minUnitPrice, maxUnitPrice, countries, offset, limit]) as Promise<OfferingResponse>;
    }

    getOffering(id: string): Promise<Offering>{
        return this.getObject('offering', id) as Promise<Offering>;
    }

    createOffering(payload: any): Promise<string>{
        return this.send('ui_createOffering', [payload]) as Promise<string>;
    }

    changeOfferingStatus(offeringId: string, action: string, gasPrice: number){
        return this.send('ui_changeOfferingStatus', [offeringId, action, gasPrice]);
    }

    acceptOffering(ethAddress: string, offeringId: string, deposit: number, gasPrice: number) {
        return this.send('ui_acceptOffering', [ethAddress, offeringId, deposit, gasPrice]);
    }

    getClientOfferingsFilterParams() {
        return this.send('ui_getClientOfferingsFilterParams');
    }

// sessions

    getSessions(channelId: string = ''): Promise<Session[]>{
        return this.send('ui_getSessions', [channelId]) as Promise<Session[]>;
    }

// channels

    getClientChannels(channelStatus: string[], serviceStatus: string[], offset: number, limit: number): Promise<ClientChannelResponse>{
        return this.send('ui_getClientChannels', [channelStatus, serviceStatus, offset, limit]) as Promise<ClientChannelResponse>;
    }

    async getNotTerminatedClientChannels(): Promise<ClientChannel[]>{

        const statuses = ['pending', 'activating', 'active', 'suspending', 'suspended', 'terminating'];

        const channels = await this.getClientChannels([], statuses, 0, 10);
        return channels.items;
    }

    getAgentChannels(channelStatus: Array<string>, serviceStatus: Array<string>, offset: number, limit: number): Promise<ChannelResponse>{
        return this.send('ui_getAgentChannels', [channelStatus, serviceStatus, offset, limit]) as Promise<ChannelResponse>;
    }


    getChannelUsage(channelId: string): Promise<number>{
        return this.send('ui_getChannelUsage', [channelId]) as Promise<number>;
    }

    changeChannelStatus(channelId: string, channelStatus: string){
        return this.send('ui_changeChannelStatus', [channelId, channelStatus]) as Promise<any>; // null actually
    }
// common

    getObject(type: string, id: string){
        return this.send('ui_getObject', [type, id]);
    }

    getObjectByHash(type: 'offering', hash: string) {
        return this.send('ui_getObjectByHash', [type, hash]);
    }

    getTransactions(type: string, id: string, offset: number, limit: number) : Promise<TransactionResponse> {
        return this.send('ui_getEthTransactions', [type, id, offset, limit]) as Promise<TransactionResponse>;
    }

    getTotalIncome(): Promise<number> {
        return this.send('ui_getTotalIncome', []) as Promise<number>;
    }
    getUserRole(): Promise<Role>{
        return this.send('ui_getUserRole', []) as Promise<Role>;
    }

// logs
    getLogs(levels: Array<string>, searchText: string, dateFrom: string, dateTo: string, offset:number, limit: number): Promise<LogResponse> {
        return this.send('ui_getLogs', [levels, searchText, dateFrom, dateTo, offset, limit]) as Promise<LogResponse>;
    }


    getSettings() {
        return this.send('ui_getSettings');
    }

}
