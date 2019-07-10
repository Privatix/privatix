# About this document

This document describes how Privatix Network works.

# General

Privatix Network is a platform for buying and selling various services. Any service that can be measured on seller's and buyer's side, using single parameter, might be bought and sold via Privatix Network without 3rd party. There is no escrow party, that can decide, if service was provided or consumed. Instead service is sold and paid in such small portion, that risk for misbehavior considered neglectable.

Privatix Network DApps developer team is focused on developing core engine and protocol that others may use to rapidly make their own implementation of decentralized marketplace, where people or machines sell and buy different services.

Privatix team has developed proof of concept DApps built on the top of this platform that focused on internet bandwidth products.

## Example

VPN provider start selling access to VPN using Privatix Network. He publishes his offering with custom pricing. Service is automatically provisioned and access granted, when Client places deposit. Client pays for every 10 MB of traffic. Payments automated based on consumption. Service access is granted and denied based on billing results. Full service cycle is automated and doesn't require manual operation.

## Benefits for buyer

- One stop shop for various services
- No upfront subscriptions
- No need to trust provider
- No credit card
- Real "pay as you go"
- Anonymous offering browsing

## Benefits for seller

- 100% payment guarantee
- No chargebacks
- Zero software cost
- Low cost of operation
- Built-in and automatic billing
- Anonymous offering publishing
- Support for selling multiple services
- Support for multiple servers serving single service

## Features

- 100% decentralized (P2P)
- Cross-platform (Windows, MacOS, Linux)
- Manageable via GUI or API
- Expandable with new services
- Payments via blockchain
- 100% open source and auditable

### Seller features

- Bootstrap access to service for each order
- Control service usage
- Verify payments made in-time
- Suspend access, if payment wasn't received in-time
- Resume access, if payment cleared
- Terminate service, if no usage for a long time registered
- Terminate service, if payment reached maximum deposit, placed by client
- Make all transaction in blockchain, after service termination, taking all earned funds from deposit
- Respond automatically, if client opens dispute, claiming his deposit back, when some funds were already earned
- Increase deposit, while using to extend possible service usage
- Monitor and operate several blockchain balances

### Buyer features

- Register service usage and show statistics
- Automatic payments for each portion of service usage
- Terminate service, if max. deposit is reached
- Terminate service, if was terminated on Agent side
- Monitor and operate several blockchain balances
- Start or Pause `3rd party software` service directly from `Privatix GUI`
- Show seller rating, that is based on seller's trading history

# User roles

`Agent` - sells services. Service provider (seller)

`Client` - buys services. Service consumer (buyer)



# Software components

## Core

[Privatix core](core.md) - software that orchestrates payments, billing, communication with other components for both Agents and Clients.

`Privatix core database` - used to save state of services and operations.

`Privatix GUI` - _optional_ graphical user interface for `Privatix core`. All essential operations can be made interactively. Alternatively, one can use `Privatix core UI API` to programmatically operate the software.

## Infrastructure

`Ethereum node` - Ethereum node, that can send transactions and be queried for events. [Infura.io](https://infura.io/ "Secure, reliable, and scalable access to Ethereum") is used by default, but any local or remote Ethereum node can be used instead.

[Ethereum smart contracts](smart_contract.md) - two smart contracts deployed on Ethereum network. One is used for buying and selling tokens. Second responsible for offering and payments processing.

`Tor` - component, that is used for anonymous communication between Agent and Client, regarding offering and initial service access bootstrap. It is used to keep IP addresses of Agents and Client in secret. Shipped with Privatix core. Other communication channels maybe added.

`PostgreSQL` - database engine. Shipped with Privatix core.

## Service plug-in

[Service plug-in](service_plug-in.md) - is set of templates and optional software for single service that automates:

- service provisioning
- usage reporting
- access to service
- start and stop of service consumption

# API

[UI API](https://github.com/Privatix/dappctrl/blob/master/doc/ui/rpc.md) - user view and control of services, offerings, servers, balances, etc.

[Adapter API](service_plug-in.md#Adapter-API) - automation of service provisioning/deprovisioning, access and usage monitoring.