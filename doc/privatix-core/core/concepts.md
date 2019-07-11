# Concepts

Privatix core - software that orchestrates payments, billing, automates service life-cycle, provides offering discovery and communication between Agents and Clients. These features gives ability to provide different services in decentralized and completely autonomous manner.

To understand how Privatix Network protocol is designed let's get familiar with some concepts.

## User roles

`Agent` - sells services. Service provider \(seller\)

`Client` - buys services. Service consumer \(buyer\)

## Messaging

[Messaging](messaging/) - is method of delivery [offering](messaging/offering/) and [access](messaging/access/) messages. These two types of messages are essential part of Privatix Network protocol. Both messages are passed from Agent to Client.

### Offering

[Offering](messaging/offering/) - is Agent's proposal to Clients for a service. It includes pricing, billing and service specific declarations.

### Access

[Access](messaging/access/) - is message provided by Agent to Client and contains sufficient data to start using a service. It includes credentials, server address, necessary configuration parameters.

## Payment

Each order between Client and Agent creates [state channel](payments/channel.md) \(aka channel\) - temporary account in blockchain that controls payment flow. Two transactions on blockchain suffice to complete payment flow. Micro-payments for each portion of service are sent peer to peer from Client to Agent using [payment cheques](payments/payments-1.md).

### Agent billing

[Agent billing](payments/agent_billing.md) periodically checks `channels` in local database and create `jobs` to `suspend`, `unsuspend` or `terminate` services.

### Client billing

[Client billing](payments/client_billing.md) periodically checks `channels` in local database, send payments and creates `jobs`.

## Blockchain

Privatix network uses Ethereum blockchain to:

* publish and discover offering unique identifiers together with some basic properties
* deliver payments between Agents and Client

#### Ethereum wrapper

[Eth package](https://github.com/Privatix/dappctrl/tree/master/eth) wraps all operation with ethereum and smart contracts.

#### Ethereum monitor

[Ethereum monitor](ethereum/ethereum_monitor.md) get ethereum events \(aka logs\) and creates jobs.

## Jobs

[Jobs](jobs/job.md) - are special tasks that make changes to software state. Most operations are done using jobs.

