# About this document

This document describes how Privatix Network works.

# General

Privatix Network is a platform for buying and selling various services. Any service that can be measured on seller's and buyer's side, using single parameter, might be bought and sold via Privatix Network without 3rd party. There is no escrow party, that can decide, if service was provided or consumed. Instead service is sold and paid in such small portion, that risk for misbehavior considered neglectable.

# Concept in short

- Sellers and buyers can provide and consume services without any 3rd party evolved.
- Service provisioning and access management can be automated.
- Developers can plug-in their own services using API.
- Custom GUI can be made and distributed with `Privatix core` engine for single service.
- Privatix GUI can be used to show custom service views (_pluggable with service plug-in_). _**not implemented**_

# Uses

- Multi-service centralized/decentralized shop
- Market to meet sellers and buyers
- Engine for DApp development that decrease TTM
- M2M payment, service provisioning and consumption

## Example

VPN provider start selling access to VPN using Privatix Network. He publishes his offering with his own pricing and start to serve clients automatically. Client pays for every 10 MB of traffic. Payment finalized automatically. Service access is granted based on billing results.

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

- Cross-platform (Windows, MacOS, Linux)
- 100% decentralized (P2P)
- Manageable via GUI or API
- Expandable with new services
- Payments via blockchain
- 100% open source and auditable

### Seller features

<details><summary>features</summary>

- Bootstrap access to service for each order
- Control service usage
- Verify payments made in-time
- Suspend access, if payment wasn't received in-time
- Resume access, if payment cleared
- Terminate service, if maximum times without service usage (defined in offering) is reached
- Terminate service, if payment reached maximum deposit, placed by client
- Complete transaction in blockchain, after service termination, taking all earned tokens from deposit
- Respond automatically, if client opens dispute, claiming his deposit back, if some tokens were already earned
- Increase deposit, while using to extend possible service usage
- Monitor and operate several ethereum balances

</details>

### Buyer features

<details><summary>features</summary>

- Start or Pause `3rd party software` service directly from `Privatix GUI`
- Automatic payments for each portion of service usage
- Register usage and show statistics
- Terminate service, if max. deposit is reached
- Terminate service, if was terminated on Agent side
- Monitor and operate several ethereum balances

</details>

# User roles

`Agent` - sells services. Service provider (seller)

`Client` - buys services. Service consumer (buyer)

# Software components

## Core

[Privatix core](/doc/core.md) - software that orchestrates payments, billing, communication with other components for both Agents and Clients.

`Privatix core database` - used to save state of services and operations.

`Privatix GUI` - _optional_ graphical user interface for `Privatix core`. All essential operations can be made interactively. Alternatively, one can use `Privatix core UI API` to programmatically operate the software.

## Infrastructure

`Ethereum node` - Ethereum node, that can send transactions and be queried for events. [Infura.io](https://infura.io/ "Secure, reliable, and scalable access to Ethereum") is used by default, but any local or remote Ethereum node can be used instead.

[Ethereum smart contracts](/doc/smart_contract.md) - two smart contracts deployed on Ethereum network. One is used for buying and selling tokens. Second responsible for offering and payments processing.

`Tor` (_optional_) - component, that is used for anonymous communication between Agent and Client, regarding offering and initial service access bootstrap. It is used to keep IP addresses of Agents and Client in secret. Shipped with Privatix core.

`PostgreSQL` - database engine. Shipped with Privatix core.

## Service plug-in

[Service plug-in](/doc/service_plug-in) - is set of templates and optional software for single service that automates:

- service provisioning
- usage reporting
- access to service
- start and stop of service consumption

# API

[UI API](https://github.com/Privatix/dappctrl/blob/master/doc/ui/rpc.md) - user view and control of services, offerings, servers, balances, etc.

[Adapter API](/doc/service_plug-in.md#Adapter-API) - automation of service provisioning/deprovisioning, access and usage monitoring.

# Basic usage scenarios

## Agent basic workflow

- Fill offering template for service
- Publish offering link to blockchain. Place deposit.

<details><summary>Agent setup workflow</summary>

1. Get some `PRIX tokens` on any token exchange. (Currently airdropped via `Privatix telegram bot` in testnet)
2. Install `Privatix core` software and at least one `service plug-in` (_currently pre-installed_).
3. Setup account via `Privatix UI`. This includes setting up private key and making token transfer.
4. Fill offering template for the particular service (template comes with `service plug-in`). Specify:

   - Max. concurrent users of this offering
   - Price for unit of service
   - Minimum required deposit
   - Max. tolerance for payment lag in units of service
   - Max. time to wait for first service use
   - Max. time to wait, if client stops using the service
   - Any other custom parameters related to particular service (they processed by `Service adapter`)

5. Publish `offering link` to blockchain, while placing _same deposit_, as expected from clients. Deposit prevents from spamming the network with junk offerings. Deposit received back, when `offering link` is deleted. It usually takes about 1 minute to complete.

</details>

Agent setup finished. Client can accept offerings and all other essential operations orchestrated by `Privatix core` and automated by `service adapter`.

## Client basic workflow

- Accept offering. Place deposit.
- Start using the service and report usage

<details><summary>Client setup workflow</summary>

1. Get some `PRIX tokens` on any token exchange. (Currently airdropped via `Privatix telegram bot` in testnet)
2. Install Privatix core software and at least one `service plug-in` (_currently pre-installed_).
3. Setup account via `Privatix GUI`. This includes setting up private key and making token transfer.
4. Accept offering. Deposit required by offering will be placed. Access credentials for service will be retrieved. It usually takes about 1 minute to complete.

</details>

Client setup finished. Client can start using a service. All other operations will be orchestrated by `Privatix core` and automated by `service adapter`.
