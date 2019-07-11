# Service module

## Service module

`Service module` - is a package that includes templates and software that provides or consume a service.

Service module must be registered in `privatix core database`and make use of Privatix core API to benefit from functionality already provided by Privatix core.

### Components

`Templates` - unique [offering ](../core/messaging/offering/)and [access ](../core/messaging/access/)template

`Service module` - software that consumes `Service API` to automate service life-cycle. Can be standalone or communicate with `Privatix core` on one side and with `3rd party software` on another to provide particular service. \(_e.g. adapter for VPN server / adapter for VPN client_\)​. 

## Service API

#### Agent methods

`AuthClient` - verifies password for a given client key.

`SetProductConfig` - sets product configuration for access messages.

`StartSession` - creates client session.

`StopSession` - stops client session.

`UpdateSession` - updates usage for client session

#### Client methods

`GetAccess` - returns an access message for a given client key.

`StartSession` - creates client session.

`StopSession` - stops client session.

`UpdateSession` - updates usage for client session

### Workflows

#### Access service

1. `Privatix Core` Agent generates credentials on new client order.
2. Client receives those credentials in access message.
3. Client's Service adapter authenticates to Agent's Service adapter and provides those credentials.
4. Service adapter pass credentials to Privatix core Agent using `AuthClient` passing credentials.
5. Client gained access to service

#### Update session usage

Call `UpdateSession` to update current usage. In response service status returned. It can be used to control service access.

#### Start session

Agent calls `StartSession` to register start of session

`StartSession`, when service status "activating"

#### Stop session

`StopSession`, when service status "suspending" or "terminating"

#### Get access message

`GetAccess` method used to get access message. This message used to get all data needed by 3rd party software to connect to Agent and start using a service \(incl. credentials, URLs of services, configuration parameters, etc\)

### Set product configuration

Service adapter stores service configuration in `products` database table `config` field. Service adapter may push some data \(usually settings\) to `core`. It will be transferred to Client in access message and get known to client service adapter using `GetAccess` method.

## Conventions

To make service modules easily added to `Privatix core` they should comply with [ Service module conventions](service_plug-in.md#service_plug-in_standards). They include some conventions that should be follow to guarantee compatibility and reuse as much as possible functionality of Privatix core.

