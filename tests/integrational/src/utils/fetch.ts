import {ipcRenderer} from 'electron';

const queue = {};
const listen = function(msg: string) {
    const handler = function(resolve: any, reject: any){
        if(!(msg in queue)){
            queue[msg] = [];
        }
        queue[msg].push({resolve, reject});
    };
    return new Promise(handler);
};

const fetchFactory = function(ipcRenderer: any){

    ipcRenderer.on('api-reply', (event, arg) => {
        // console.log(arg); // prints "pong"
        const response = JSON.parse(arg);
        if(response.req in queue){
            const handler = queue[response.req].pop();
            if(queue[response.req].length === 0){
                delete queue[response.req];
            }
            if(!response.err){
                handler.resolve(response.res);
            }else{
                handler.reject(response.err);
            }
        }else{
                // TODO error handling
        }
    });

    return function(endpoint: string, options?: any){
        const msg = JSON.stringify({endpoint, options});
        const promise = listen(msg);
        ipcRenderer.send('api', JSON.stringify({endpoint, options}));
        return promise;
    };
};

export const fetch = fetchFactory(ipcRenderer);
