const getQuality = function(user, events){
    // this is the ratio of money spent in normally closed channels to the total amount
    // i.e. normalized 0 - 1
    let total = 0;
    let success = 0;

    for(let i=0; i< events.length; i++){
        const event = events[i];
        if(event === null){
            continue;
        }
        if(event.closed === 'cooperative' || event.closed === 'uncooperative'){
            total += event.cost;
        }
        if(event.closed === 'cooperative'){
            success += event.cost;
        }
    }

    return total ? success/total : 0;
};

const getReliability = function(user, events){
    // it's the count of money spent
    let res = 0;
    for(let i=0; i< events.length; i++){
        const event = events[i];
        res += event.cost;
    }

    return res;
};

const getParticipants = function(events, sortedEvents, totalPrix){

// DONE we have to delete dangling links

    const res = [];
    const counted = [];

    for(let i=0; i< events.length; i++){
        const event = events[i];
        if(event === null){
            return;
        }
        const agent = {address: event.agent, role: 'agent'};
        if(!counted.includes(`a${agent.address}`)){
            const linksCount = sortedEvents[agent.address].length;
            if(linksCount > 1){
                const record = {
                    address: event.agent,
                    role: 'agent',
                    quality: getQuality(agent, sortedEvents[agent.address])/linksCount,
                    reliability: getReliability(agent, sortedEvents[agent.address])/(linksCount*totalPrix),
                    linksCount
                };
                res.push(record);
            }else{
                events[i] = null;
            }
            counted.push(`a${agent.address}`);
        }

        const client = {address: event.client, role: 'client'};
        if(!counted.includes(`c${client.address}`)){
            const linksCount = sortedEvents[client.address].length;
            if(linksCount > 1){
                const record = {
                    address: event.client,
                    role: 'client',
                    quality: getQuality(client, sortedEvents[client.address])/linksCount,
                    reliability: getReliability(client, sortedEvents[client.address])/(linksCount*totalPrix),
                    linksCount
                };
                res.push(record);
            }else{
                events[i] = null;
            }
            counted.push(`c${client.address}`);
        }
    };
    return res;
};

const extractIndexes = function(events, participants){

    const res = {};

    for(let i=0; i<events.length; i++){

        const event = events[i];

        if(!res[event.agent]){
            res[event.agent] = [];
        }
        if(!res[event.client]){
            res[event.client] = [];
        }

        const agentIndex = participants.findIndex(participant => participant.address === event.agent);
        res[event.client].push(agentIndex);

        const clientIndex = participants.findIndex(participant => participant.address === event.client);
        res[event.agent].push(clientIndex);
    };

    return res;
}


const calculateRank = function(data, receiver, participant, index){

    let reliability = 0;
    let quality = 0;
    for (let index of participant.partners){
        reliability += data.reliability[index];
        quality += data.quality[index];
    }

    receiver.reliability[index] = reliability / participant.linksCount;

    receiver.quality[index] = quality / participant.linksCount;

}

const sortEvents = function(events){
    const res = {};
    for(let i=0; i<events.length; i++){
        const event = events[i];
        if(!res[event.agent]){
            res[event.agent] = [];
        }
        if(!res[event.client]){
            res[event.client] = [];
        }

        res[event.agent].push(event);
        res[event.client].push(event);
    }

    return res;
}



module.exports = function(steps){
    return function(events){

        const totalPrix = events.reduce((acc, event) => acc + event.cost, 0);
        const sortedEvents = sortEvents(events);
        let participants = getParticipants(events, sortedEvents, totalPrix);
        events = events.filter(event => event !== null);

        const indexes = extractIndexes(events, participants);

        participants = participants.map(participant => {
            return Object.assign({}, participant, {partners: indexes[participant.address] ? indexes[participant.address] : []});
        });

        let data = {
            reliability: new Float32Array(participants.length),
            quality: new Float32Array(participants.length)
        };

        for(i=0; i<participants.length; i++){
            data.reliability[i] = participants[i].reliability;
            data.quality[i] = participants[i].quality;
        }

        let receiver = {
            reliability: new Float32Array(participants.length),
            quality: new Float32Array(participants.length)
        };

        for(let i=0; i<steps; i++){
            const calculator = calculateRank.bind(null, data, receiver);
            participants.forEach(calculator);

            const tmp = data;
            data = receiver;
            receiver = tmp;

        }

        // normalization
        let maxReliability = 0;
        for(let i=0; i<data.reliability.length; i++){
            if(maxReliability < data.reliability[i]*participants[i].linksCount){
                maxReliability = data.reliability[i]*participants[i].linksCount;
            }
        }
        const kReliability = 1/maxReliability;
        for(let i=0; i<data.reliability.length; i++){
            data.reliability[i] *= kReliability;
        }

        let maxQuality = 0;
        for(let i=0; i<data.quality.length; i++){
            if(maxQuality < data.quality[i]*participants[i].linksCount){
                maxQuality = data.quality[i]*participants[i].linksCount;
            }
        }
        const kQuality = 1/maxQuality;
        for(let i=0; i<data.quality.length; i++){
            data.quality[i] *= kQuality;
        }

        participants = participants.map((participant, index) => (
            {reliability: data.reliability[index]*participant.linksCount
            ,quality: data.quality[index]*participant.linksCount
            ,role: participant.role
            ,address: participant.address
            })
        );

        return participants;
    }
}
