# Privatix rating

### Usage

```js
const getCalculator = require('./index.js');
const ITERATIONS = 30;
const calculator = getCalculator(ITERATIONS);

const events = [
    {closed: 'cooperative', cost: 0.005, agent: 'agent1', client: 'client1'},
    {closed: 'cooperative', cost: 0.009, agent: 'agent1', client: 'client2'},
    {closed: 'cooperative', cost: 0.013, agent: 'agent1', client: 'client3'},
    {closed: 'cooperative', cost: 0.011, agent: 'agent2', client: 'client1'},
    {closed: 'cooperative', cost: 0.004, agent: 'agent2', client: 'client2'},
    {closed: 'uncooperative', cost: 0.007, agent: 'agent1', client: 'client2'},
    {closed: 'cooperative', cost: 0.023, agent: 'agent1', client: 'client3'},
    {closed: 'cooperative', cost: 0.017, agent: 'agent1', client: 'client4'},
];

console.log(calculator(events));
/*
[ { reliability: 1.0000000298023224,
    quality: 1.0000000298023224,
    role: 'agent',
    address: 'agent1' },
  { reliability: 0.34709861874580383,
    quality: 0.5581280589103699,
    role: 'client',
    address: 'client1' },
  { reliability: 0.501196950674057,
    quality: 0.8059152960777283,
    role: 'client',
    address: 'client2' },
  { reliability: 0.30819663405418396,
    quality: 0.49557435512542725,
    role: 'client',
    address: 'client3' },
  { reliability: 0.4174830913543701,
    quality: 0.4174831211566925,
    role: 'agent',
    address: 'agent2' } ]
*/
```
