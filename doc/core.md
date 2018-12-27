# Privatix core

Privatix core - software that orchestrates payments, billing, communication with other components for both Agents and Clients.

## Messaging

[Messaging](/doc/messaging.md) - is method of delivery [offering](/doc/offering.md) and [access](/doc/access.md) messages. These two messages are essential for application workflow.

## Offering

[Offering](/doc/offering.md) - is Agent's proposal to Clients for a service.

## Access

[Access](/doc/access.md) - is message provided by Agent to Client that grants access to service.

## Payment

Each order between Client and Agent creates [state channel](/doc/channel.md) (aka channel) - temporary account in blockchain that controls payment flow. Two transactions on blockchain suffice to complete payment flow. Micro-payments for each portion of service are sent peer to peer from Client to Agent using [payment cheques](/doc/payments.md).

## Agent billing

[Agent billing](/doc/agent_billing.md) periodically checks `channels` in local database and create `jobs` to `suspend`, `unsuspend` or `terminate` services.

## Client billing

[Client billing](/doc/client_billing.md) periodically checks `channels` in local database, send payments and creates `jobs`.

## Ethereum

### Ethereum wrapper

[Eth package](https://github.com/Privatix/dappctrl/tree/master/eth) wraps all operation with ethereum and smart contracts.

### Ethereum monitor

[Ethereum monitor](/doc/ethereum_monitor.md) get ethereum events (aka logs) and creates jobs.

## Jobs

[Jobs](/doc/job.md) - are special tasks that make changes to software state. Most operations are done using jobs.
