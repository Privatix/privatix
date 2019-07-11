# Payments

Privatix Network uses micro-payments, where Client instead of paying upfront for whole month, would pay only for small portion, such as 10 MegaBytes or 10 Minutes. In decentralized trustless environment such approach eliminate need for 3rd party, that somehow will guarantee chargeback, if service wasn't provided. 

To ensure that Client have enough funds to pay for service and to prevent double spending smart contract will create temporary account for each order/deal made between Client and Agent. These temporary accounts are also known as [State channels](channel.md).

Making transaction in blockchain is costly. If we would create transaction in blockchain for each 10 MegaBytes of traffic it won't work for two reasons:  
 

* each transaction may cost much more than payment for small portion of service
* frequency of billing will be too slow, if we will wait till transaction will be registered in blockchain

For that reasons [Cryptographic cheques](payments-1.md) are sent directly by Client to Agent. Agent can use this cheque anytime in blockchain transaction and withdraw owed amount from Client's blockchain account.

