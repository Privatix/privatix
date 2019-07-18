# Payment cheques

Client creates channel and places deposit on it.

After Client starts using service, `Client billing` would identify that current usage lags after [payment](https://github.com/Privatix/dappctrl/tree/master/pay) and will send cheque to Agent.

## Cheque

`Cheque` - is specially crafted message, signed by Client. If signed further by Agent and sent to smart contract it closes channel, while completing transfer of tokens owed by Client to Agent. Signed by Client balance proofs that it permits to Agent to get exact amount of tokens from channel deposit.

**Cheque format**

```text
AgentAddress    data.HexString
OpenBlockNumber uint32
OfferingHash    data.HexString
Balance         uint64
BalanceMsgSig   data.Base64String
ContractAddress data.HexString
```

### Payment web service

Agent has [payment web service](https://github.com/Privatix/dappctrl/tree/master/pay) that receives payments from Client. It will receive cheque, verify that:

* signature is correct
* all fields matching to channel
* cheque balance is greater than last received

If verification succeeded, Agent will store new balance and cheque in database.

If Agent has already terminated service, it responds with error message. Client will also terminate service in such case.

