# Service plug-in

`Service plug-in` - are rules and software for automation of service life-cycle

Service plug-in is downloaded and registered in `privatix core database`.

Offering then may be published and accepted. Service can be provisioned, service life-cycle and payments automated.

## Components

`Templates` (_required_) - unique offering and access template

`Service adapter` (_optional_) - software that consumes `adapter API` to automate service life-cycle. Can communicate with `Privatix core` on one side and with `3rd party software` on another. (_e.g. adapter for VPN server / adapter for VPN client_)

`3rd party software` (_optional_) - software that is used to provide or consume service and report its usage. It is usually server and/or client software (_e.g. VPN server / VPN client_)

# Adapter API

`AuthClient` - verifies password for a given client key.

`StartSession` - creates a new client session.

`UpdateSession` - updates and optionally stops the current client session.

`GetAccess` - returns an access message for a given client key.

`SetProductConfig` - sets product configuration for access messages.

## Access service workflow

1. `Privatix Core` generates password for client channel.
2. Client receives password and client key in access message.
3. Client authenticates to 3rd party software and provides those credentials.
4. 3rd party software check authentication using `AuthClient` method and passing credentials.
5. Client gained access to 3rd party software service

## Start session

1. After Client granted access 3rd party software can call `StartSession` to register start of session

## Update session usage

Call `UpdateSession` to update current usage. In response service status returned. It can be used to control service access.

Stop session, when service status "suspending"
Start session, when service status "activating"

## Get access message

`GetAccess` method used to get access message. This message used to get all data needed by 3rd party software (incl. credentials, URLs of services)

## Set service plug-in product configuration

Service plug-ins stores service configuration in `products` table `config` field. 3rd party software server may push some data (usually settings) to `core`. It will be transferred to Client in access message and get known to client service adapter using `GetAccess` method.

# Standards

To make service plug-ins easily added to `Privatix core` they should comply with [ Service plug-in standards](/doc/#service_plug-in_standards)
