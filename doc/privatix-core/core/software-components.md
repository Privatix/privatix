# Software components

### Core

[Privatix core](./) - software that orchestrates payments, billing, communication with other components for both Agents and Clients.

* `Privatix core database` - used to save state of services and operations.
* `Privatix GUI` - _optional_ graphical user interface for `Privatix core`. All essential operations can be made interactively. Alternatively, one can use `Privatix core UI API` to programmatically operate the software.

### Infrastructure

* `Ethereum node` - Ethereum node, that can send transactions and be queried for events. [Infura.io](https://infura.io/) is used by default, but any local or remote Ethereum node can be used instead.
* [Ethereum smart contracts](ethereum/smart_contract.md) - two smart contracts deployed on Ethereum network. One is used for buying and selling tokens. Second responsible for offering and payments processing.
* `Tor` - component, that is used for anonymous communication between Agent and Client, regarding offering and initial service access bootstrap. It is used to keep IP addresses of Agents and Client in secret. Shipped with Privatix core. Other communication channels maybe added.
* `PostgreSQL` - database engine. Shipped with Privatix core.

### Service module

Service module is not part of core, but always come together with Privatix core. This module responsible to deliver/consume a service. It communicates with Privatix core via Service API.

[Service module](../service/service_module.md) - is set of templates and software for single service that automates:

* service provisioning
* usage reporting
* access to service
* start and stop of service consumption

## API

[UI API](https://github.com/Privatix/dappctrl/blob/master/doc/ui/rpc.md) - user view and control of services, offerings, servers, balances, etc.

[Service API](../service/service_module.md#service-api) - automation of service provisioning/deprovisioning, access and usage monitoring.

