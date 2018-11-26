import * as uuidv4 from 'uuid/v4';
import {TemplateType} from '../typings/templates';
import {OfferStatus, Offering} from '../typings/offerings';
import {Account} from '../typings/accounts';
import {Transaction} from '../typings/transactions';
import {Product} from '../typings/products';
import {Session} from '../typings/session';
import {Channel} from '../typings/channels';
import {Template} from '../typings/templates';
import { PaginatedResponse} from '../typings/paginatedResponse';

type OfferingResponse = PaginatedResponse<Offering[]>;
type ChannelResponse  = PaginatedResponse<Channel[]>;
type TransactionResponse = PaginatedResponse<Transaction[]>;

const WebSocket = require('ws');

export class WS {

    static listeners = {}; // uuid -> listener
    static handlers = {}; // uuid -> handler

    static byUUID = {}; // uuid -> subscribeID
    static bySubscription = {}; // subscribeId -> uuid

    private socket: WebSocket;
    private pwd: string;
    private ready: Promise<boolean>;
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
            if (event.wasClean) {
                console.log('Connection closed.');
            } else {
                console.log('Connection interrupted.');
            }
            console.log('Code: ' + event.code + ' reason: ' + event.reason);
        });

        socket.on('message',  function(event: any) {
            const msg = JSON.parse(event);
            if('id' in msg && 'string' === typeof msg.id){
                if(msg.id in WS.handlers){
                    WS.handlers[msg.id](msg);
                    delete WS.handlers[msg.id];
                }else {
                    if('result' in msg && 'string' === typeof msg.result){
                        WS.byUUID[msg.id] = msg.result;
                        WS.bySubscription[msg.result] = msg.id;
                    }
                }
            }else if('method' in msg && msg.method === 'ui_subscription'){
                if(msg.params.subscription in WS.bySubscription){
                    WS.listeners[WS.bySubscription[msg.params.subscription]](msg.params.result);
                }
           } else {
               // ignore
           }
          // console.log('Data received: ' + event.data);
        });

        socket.on('error', function() {
          // console.log('Error ' + error.message);
        });

        this.socket = socket;
    }

    whenReady(){
        return this.ready;
    }

    subscribe(entityType:string, ids: string[], handler: Function) {
        const uuid = uuidv4();
        const req = {
            jsonrpc: '2.0',
            id: uuid,
            method: 'ui_subscribe',
            params: ['objectChange', this.pwd, entityType, ids]
        };
        WS.listeners[uuid] = handler;
        this.socket.send(JSON.stringify(req));
        return uuid;
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
            this.socket.send(JSON.stringify(req));
            delete WS.listeners[id];
            delete WS.bySubscription[WS.byUUID[id]];
            delete WS.byUUID[id];
        }
    }

    send(method: string, params: any[] = []){

        const uuid = uuidv4();
        params.unshift(this.pwd);
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

    topUp(channelId: string, gasPrice: number, handler: Function){
        const uuid = uuidv4();
        WS.handlers[uuid] = handler;

        const req = {
            jsonrpc: '2.0',
            id: uuid,
            method: 'ui_topUpChannel',
            params: [this.pwd, channelId, gasPrice]
        };

        this.socket.send(JSON.stringify(req));
    }

// auth

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
            const handler = (res: any) => {
                if('error' in res){
                    if(res.error.message.indexOf('password exists') === -1){
                        reject(res.error);
                    }else{
                        this.getProducts()
                            .then(() => {
                                resolve(true);
                            })
                            .catch(err => {
                                reject(err);
                            });
                    }
                }else{
                    resolve(res.result);
                }
            };
            WS.handlers[uuid] = handler;
            this.socket.send(JSON.stringify(req));
        });
    }

    updatePassword(pwd: string){
        return this.send('ui_setPassword', [pwd]);
    }

// accounts

    getAccounts(): Promise<Account[]> {
        return this.send('ui_getAccounts') as Promise<Account[]>;
    }

    /*
    generateAccount(payload: any, handler: Function){
        const uuid = uuidv4();
        WS.handlers[uuid] = handler;

        const req = {
            jsonrpc: '2.0',
            id: uuid,
            method: 'ui_generateAccount',
            params: [this.pwd, payload]
        };

        this.socket.send(JSON.stringify(req));
    }
    */

    generateAccount(payload: any){
      return this.send('ui_generateAccount', [payload]);
    }

    importAccountFromHex(payload: any, handler: Function){
        const uuid = uuidv4();
        WS.handlers[uuid] = handler;

        const req = {
            jsonrpc: '2.0',
            id: uuid,
            method: 'ui_importAccountFromHex',
            params: [this.pwd, payload]
        };

        this.socket.send(JSON.stringify(req));
    }

    importAccountFromJSON(payload: any, key: Object, pwd: string, handler: Function){
        const uuid = uuidv4();
        WS.handlers[uuid] = handler;

        const req = {
            jsonrpc: '2.0',
            id: uuid,
            method: 'ui_importAccountFromJSON',
            params: [this.pwd, payload, key, pwd]
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
            params: [this.pwd, accountId]
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
        console.log('getClientOfferings', [agent, minUnitPrice, maxUnitPrice, countries]);
        return this.send('ui_getClientOfferings', [agent, minUnitPrice, maxUnitPrice, countries, offset, limit]) as Promise<OfferingResponse>;
    }

    getOffering(id: string): Promise<Offering>{
        return this.getObject('offering', id) as Promise<Offering>;
    }

    createOffering(payload: any){
        return this.send('ui_createOffering', [payload]);
    }

    changeOfferingStatus(offeringId: string, action: string, gasPrice: number){
        return this.send('ui_changeOfferingStatus', [offeringId, action, gasPrice]);
    }

// sessions

    getSessions(channelId: string = ''): Promise<Session[]>{
        return this.send('ui_getSessions', [channelId]) as Promise<Session[]>;
    }

// channels

    getClientChannels(channelStatus: string, serviceStatus: string, offset: number, limit: number): Promise<ChannelResponse>{
        return this.send('ui_getClientChannels', [channelStatus, serviceStatus, offset, limit]) as Promise<ChannelResponse>;
    }

    getAgentChannels(channelStatus: string, serviceStatus: string, offset: number, limit: number): Promise<ChannelResponse>{
        return this.send('ui_getAgentChannels', [channelStatus, serviceStatus, offset, limit]) as Promise<ChannelResponse>;
    }

    getChannelUsage(channelId: string): Promise<number>{
        return this.send('ui_getChannelUsage', [channelId]) as Promise<number>;
    }

// common
    getObject(type: 'channel', id: string): Promise<Channel>;
    getObject(type: 'template', id: string): Promise<Template>;
    getObject(type: 'offering', id: string): Promise<Offering>;
    getObject(type: string, id: string){
        return this.send('ui_getObject', [type, id]);
    }

    getTransactions(type: string, id: string, offset: number, limit: number) : Promise<TransactionResponse> {
        return this.send('ui_getEthTransactions', [type, id, offset, limit]) as Promise<TransactionResponse>;
    }

    getSettings() {
        return this.send('ui_getSettings');
    }

    getTotalIncome() {
        const uuid = uuidv4();

        const req = {
            jsonrpc: '2.0',
            id: uuid,
            method: 'ui_getTotalIncome',
            params: [this.pwd]
        };

        return new Promise((resolve: Function, reject: Function) => {
            WS.handlers[uuid] = function (res: any) {
                if ('err' in res) {
                    reject(res.err);
                } else {
                    resolve(res.result);
                }
            };

            this.socket.send(JSON.stringify(req));
        });
    }

// logs
    getLogs(levels: Array<string>, searchText: string, dateFrom: string, dateTo: string, offset:number, limit: number) {
        const uuid = uuidv4();

        const req = {
            jsonrpc: '2.0',
            id: uuid,
            method: 'ui_getLogs',
            params: [this.pwd, levels, searchText, dateFrom, dateTo, offset, limit]
        };

        return new Promise((resolve: Function, reject: Function) => {
            WS.handlers[uuid] = function (res: any) {
                if ('err' in res) {
                    reject(res.err);
                } else {
                    resolve(res.result);
                }
            };

            this.socket.send(JSON.stringify(req));
        });
    }

}
