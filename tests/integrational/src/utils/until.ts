import { WS } from './ws';

class Observer {

    ws: WS;
    objectType: string;
    objectId: string;
    subscriptionId: string;
    target: string;

    constructor(ws: WS){

        this.ws = ws;

    }

    object(objectType: any){

        this.objectType = objectType;
        return this;

    }

    withId(objectId: string){
        this.objectId = objectId;
        return this;
    }

    prop(propName: string){
        
        this.target = propName;
        return this;

    }

    becomes(goal: any){
        return new Promise(async (resolve, reject) => {
            this.subscriptionId = await this.ws.subscribe(this.objectType, [this.objectId], async () => {
                const object = await this.ws.getObject(this.objectType, this.objectId);
                    if(typeof goal === 'function' ? goal(object[this.target]) : object[this.target] === goal){
                        this.ws.unsubscribe(this.subscriptionId);
                        this.subscriptionId = undefined;
                        resolve(true);
                    }
            });
        });
    }
}

export const Until = function(ws: WS){

    return new Observer(ws);
    
}
