import { WS } from './../utils/ws';
import {BotEndpoint, LocalSettings} from '../typings/settings';

const configs = require('../configs/config.json') as LocalSettings;

export const getEth = async function(endpoint: BotEndpoint, user: string, pwd: string, address: string){
    return new Promise(function(resolve, reject){
        const http = require('http');
        const postData = JSON.stringify({address: `0x${address}`});
        const credentials = Buffer.from(user + ':' + pwd).toString('base64');
        const auth = `Basic ${credentials}`;
        const headers = {'Authorization': auth,
          'Content-Type': 'application/json',
          'Content-Length': postData.length
        };
        const options = Object.assign({}, { headers}, endpoint);
        const client = http.request(options, (res) => {
            res.setEncoding('utf8');
            res.on('data', (chunk) => {
                console.log(chunk);
            });
            res.on('end', () => {
              resolve(true);
            });
          });

        client.on('error', (e) => {
            reject(e);
        });
        client.write(postData);
        client.end();
    });
}

export const skipBlocks = async function(blocksNumber: number, instance: WS, timeout: number, tick: number){

    return new Promise(async function(resolve, reject){
        let initialBlock = 0;
        const initialStamp = Date.now();

        try{
            const settings = await instance.getSettings();
            initialBlock = settings['eth.event.lastProcessedBlock'].value;
        } catch (e) {
            reject(e);
        }
        const checker = async () => {
            const settings = await instance.getSettings();
            if(settings['eth.event.lastProcessedBlock'].value - initialBlock >= blocksNumber){
                resolve(true);
            }else{
                if(Date.now() - initialStamp >= timeout){
                    reject('timeout exceeded');
                }else {
                    setTimeout(checker, tick);
                }
            }
        };
        checker();
    });
}

export const getBlockchainTimeouts = function () {
    const testTimeout = configs.timeouts.blocktime * (configs.timeouts.getEther.skipBlocks + 1) + configs.timeouts.getEther.botTimeoutMs;
    const getEthTimeout = configs.timeouts.blocktime * (configs.timeouts.getEther.skipBlocks);
    const getEthTick = configs.timeouts.blocktime / 3;

    return {
        'testTimeout': testTimeout,
        'getEthTimeout': getEthTimeout,
        'getEthTick': getEthTick
    }
}
