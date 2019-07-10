# Privatix core

Privatix core - software that orchestrates payments, billing, communication with other components for both Agents and Clients.

## Messaging

[Messaging](messaging.md) - is method of delivery [offering](offering.md) and [access](access.md) messages. These two messages are essential for application workflow.

## Offering

[Offering](offering.md) - is Agent's proposal to Clients for a service.

## Access

[Access](access.md) - is message provided by Agent to Client that grants access to service.

## Payment

Each order between Client and Agent creates [state channel](channel.md) (aka channel) - temporary account in blockchain that controls payment flow. Two transactions on blockchain suffice to complete payment flow. Micro-payments for each portion of service are sent peer to peer from Client to Agent using [payment cheques](payments.md).

## Agent billing

[Agent billing](agent_billing.md) periodically checks `channels` in local database and create `jobs` to `suspend`, `unsuspend` or `terminate` services.

## Client billing

[Client billing](client_billing.md) periodically checks `channels` in local database, send payments and creates `jobs`.

## Ethereum

### Ethereum wrapper

[Eth package](https://github.com/Privatix/dappctrl/tree/master/eth) wraps all operation with ethereum and smart contracts.

### Ethereum monitor

[Ethereum monitor](ethereum_monitor.md) get ethereum events (aka logs) and creates jobs.

## Jobs

[Jobs](job.md) - are special tasks that make changes to software state. Most operations are done using jobs.
