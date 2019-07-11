# Conventions

## Service module conventions

### Requirements

* At minimum service module must contain offering and access template with unique hash
* Usage should be reported using `Adapter API`

## Installation by dapp-installer

Dapp-installer is an installer that can be used to install whole Dapp, including Privatix core and service module.

To make offering template be imported by `dapp-installer`, folder and file naming should comply with `service module naming conventions`.

## Service module naming conventions

### Product id

Each service module should have unique `product id` \(uuid v4\). We expect in future to create mapping between service plug-in maintainer ethereum address and unique product id. This will give ability for a maintainer to reserve `product id` for his service module and sign his service module. User/software will have ability to:

* verify that service module is maintained by somebody that user trusts
* prevent from scammers to have same products \(`product id's`\) as trusted maintainer
* allow service module signature verification and belonging to trusted maintainer

Example of `product id`: `73e17130-2a1d-4f7d-97a8-93a9aaa6f10d`

### Folder structure

-- core folder

--- product

---- &lt;product id&gt;

----- bin

----- config

----- data

----- log

----- template

---- &lt;product id&gt;

----- bin

----- config

----- data

----- log

----- template

#### Folder conventions

`bin` - contains all binary/executable/scripts. Can contain subfolders. Can contain 3rd party software in subfolders. During upgrade, it should be replaced by newer versions.

`config` - adapter config and preferably all other config files. During upgrade, it should be left with or without changes of config files.

`data` - folder to store any data. It remains during upgrade.

`log` - log of adapter. Preferably any other logs goes here.

`template` - offering, access, product template stored here and imported during install of service module.

**Templates**

Templates are located in `template` folder. Following naming and folder structure must be maintained:

-- template

--- products

---- `client.json`

---- `server.json`

--- templates

---- `access.json`

---- `offering.json`

---- `adapter.agent.config.json`

---- `adapter.client.config.json`

`client.json` - client product object that imported to Privatix Core DB to products table. Represents client service module initial configuration/settings.

`server.json` - server product object that imported to Privatix Core DB to products table. Represents server service module initial configuration/settings.

`access.json` - access message template \(see [Access](../core/messaging/access/) for more\)

`offering.json` - offering message template \(see [Offerings](../core/messaging/offering/) for more\)

`adapter.agent.config.json` - service module adapter configuration file for Agent. It is template only for customization during installation. Resulting config file should reside in `config` folder.

`adapter.client.config.json` - service module adapter configuration file for Client. It is template only for customization during installation. Resulting config file should reside in `config` folder.

## Dapp-installer

dapp-installer can install, update, remove service module which is compliant with conventions listed above.

Given `install.agent.config.json` or `install.client.config.json` found in `config` folder by dapp-installer, they would be executed sequentially as part of install, update or remove workflow.

**dapp-installer compatible config**

```javascript
{
    "CoreDapp": false,
    "Install": [
        {"Admin" : true,"Command": "bin/inst install --config ../config/installer.agent.config.json"}
    ],
    "Remove": [
        {"Admin" : true,"Command": "bin/inst remove"}
    ],
    "Update": [
        {"Admin" : true,"Command": "bin/inst update"}
    ]
}
```

For each workflow dapp-installer will execute commands listed in `install.agent.config.json` or `install.client.config.json` files sequentially. `Admin` field specifies, if command will be executed with admin/root privileges.

For more information, please refer to [dapp-installer repository](https://github.com/Privatix/dapp-installer)

