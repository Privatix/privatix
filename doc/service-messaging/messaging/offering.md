# Offering

Offerings \(aka offering message\) are created by Agents according to `offering template`. `Offering link` is published to blockchain together with Agent's deposit.

## Offering link

`Offering link` - is data published to blockchain, that contains Agent's URL where full offing message can be retrieved.

Agent publishes `offering link` via smart contract method:

```text
function registerServiceOffering (bytes32 _offering_hash, uint192 _min_deposit, uint16 _max_supply, uint8 _source_type, string _source)
```

where

`_source_type` - messaging transports that can be used to get full offering and access message

`_source` - addresses of sources \(usually URLs\), that can be used to retrieve offering and access message

in same step Agent places deposit.

## Agent deposit

Agent's deposit is calculated using offering parameters:

```text
    Agent deposit = Unit price * Min. units * Max. supply
```

Agent deposit is placed in smart contract method:

```text
function registerServiceOffering (bytes32 _offering_hash, uint192 _min_deposit, uint16 _max_supply, uint8 _source_type, string _source)
```

Reason, why Agent places deposit is to make Clients and Agents deposits equal. Meaning that any party locks exactly same deposit. This should make economical attack from both sides less efficient.

## Offering template

`Offering template` maybe seen as standard contract for particular service, where some parameters are variable per Agent. Offering template shipped with `service plug-in`. Each `service plug-in` has unique offering template. Both Agent and Client have identical offering template, when choose to use same `service plug-in`.

`Offering template` - is JSON schema that includes:

* `Offering schema` - offering fields to be filled by Agent
  * `Core fields` - fields that common for any service. They are required for proper `Privatix core` operation. They are generic and doesn't contain any service specifics.
  * `Service custom fields` - \(aka additional parameters\) any fields that needed for particular service operation. They do not processed by `Privatix core`, but passed to `Privatix adapter` for any custom logic.
* `UI schema` - schema that can be used by GUI to display fields for best user experience

Each `Offering template` has unique hash. Any offering always includes in its body hash of corresponding `offering template`. That's how offering is linked to template and related `service plug-in`.

When Client receives offering, he checks that:

* Offering template with noted hash exists in Client's database
* Offering message passes validation according to offering template

Such validation ensures, that Agent and Client both has:

* exactly same offering template
* offering is properly filled according to offering template schema

### Offering template schema

**Schema example**

```javascript
{
    "schema": {
        "title": "Privatix VPN offering",
        "type": "object",
        "properties": {
            "serviceName": {
                "title": "name of service",
                "type": "string",
                "description": "Friendly name of service",
                "const": "Privatix VPN"
            },
            "templateHash": {
                "title": "offering template hash",
                "type": "string",
                "description": "Hash of this offering template"
            },
            "nonce": {
                "title": "nonce",
                "type": "string",
                "description": "uuid v4. Allows same offering to be published twice, resulting in unique offering hash."
            },
            "agentPublicKey": {
                "title": "agent public key",
                "type": "string",
                "description": "Agent's public key"
            },
            "supply": {
                "title": "service supply",
                "type": "number",
                "description": "Maximum Number of concurrent orders that can coexist"
            },
            "unitName": {
                "title": "unit name",
                "type": "string",
                "description": "name of single unit of service",
                "examples": [
                    "MB",
                    "kW",
                    "Lesson"
                ]
            },
            "unitPrice": {
                "title": "unit price",
                "type": "number",
                "description": "Price in PRIX for single unit of service."
            },
            "minUnits": {
                "title": "min units",
                "type": "number",
                "description": "Minimum number of units Agent expect to sell. Deposit must suffice to buy this amount."
            },
            "maxUnits": {
                "title": "max units",
                "type": "number",
                "description": "Maximum number of units Agent will sell."
            },
            "billingType": {
                "title": "billing type",
                "type": "string",
                "enum": [
                    "prepaid",
                    "postpaid"
                ],
                "description": "Model of billing: postapaid or prepaid"
            },
            "billingFrequency": {
                "title": "billing frequency",
                "type": "number",
                "description": "Specified in units of servce. Represent, how often Client MUST send payment cheque to Agent."
            },
            "maxBillingUnitLag": {
                "title": "max billing unit lag",
                "type": "number",
                "description": "Maximum tolerance of Agent to payment lag. If reached, service access is suspended."
            },
            "maxSuspendTime": {
                "title": "max suspend time",
                "type": "number",
                "description": "Maximum time (seconds) Agent will wait for Client to continue using the service, before Agent will terminate service."
            },
            "maxInactiveTime": {
                "title": "max inactive time",
                "type": "number",
                "description": "Maximum time (seconds) Agent will wait for Client to start using the service for the first time, before Agent will terminate service."
            },
            "setupPrice": {
                "title": "setup fee",
                "type": "number",
                "description": "Setup fee is price, that must be paid before starting using a service."
            },
            "freeUnits": {
                "title": "free units",
                "type": "number",
                "description": "Number of first free units. May be used for trial period."
            },
            "country": {
                "title": "country of service",
                "type": "string",
                "description": "Origin of service"
            },
            "additionalParams": {
                "title": "Privatix VPN service parameters",
                "type": "object",
                "description": "Additional service parameters",
                "properties": {
                    "minUploadSpeed": {
                        "title": "min. upload speed",
                        "type": "string",
                        "description": "Minimum upload speed in Mbps"
                    },
                    "maxUploadSpeed": {
                        "title": "max. upload speed",
                        "type": "string",
                        "description": "Maximum upload speed in Mbps"
                    },
                    "minDownloadSpeed": {
                        "title": "min. download speed",
                        "type": "string",
                        "description": "Minimum download speed in Mbps"
                    },
                    "maxDownloadSpeed": {
                        "title": "max. upload speed",
                        "type": "string",
                        "description": "Maximum download speed in Mbps"
                    }
                },
                "required": []
            }
        },
        "required": [
            "serviceName",
            "supply",
            "unitName",
            "billingType",
            "setupPrice",
            "unitPrice",
            "minUnits",
            "maxUnits",
            "billingInterval",
            "maxBillingUnitLag",
            "freeUnits",
            "templateHash",
            "product",
            "agentPublicKey",
            "additionalParams",
            "maxSuspendTime",
            "country"
        ]
    },
    "uiSchema": {
        "agentPublicKey": {
            "ui:widget": "hidden"
        },
        "billingInterval": {
            "ui:help": "Specified in unit_of_service. Represent, how often Client MUST provide payment approval to Agent."
        },
        "billingType": {
            "ui:help": "prepaid/postpaid"
        },
        "country": {
            "ui:help": "Country of service endpoint in ISO 3166-1 alpha-2 format."
        },
        "freeUnits": {
            "ui:help": "Used to give free trial, by specifying how many intervals can be consumed without payment"
        },
        "maxBillingUnitLag": {
            "ui:help": "Maximum payment lag in units after, which Agent will suspend serviceusage."
        },
        "maxSuspendTime": {
            "ui:help": "Maximum time without service usage. Agent will consider, that Client will not use service and stop providing it. Period is specified in minutes."
        },
        "maxInactiveTime": {
            "ui:help": "Maximum time Agent will wait for Client to start using the service for the first time, before Agent will terminate service. Period is specified in minutes."
        },
        "minUnits": {
            "ui:help": "Agent expects to sell at least this amount of service."
        },
        "maxUnits": {
            "ui:help": "Agent will sell at most this amount of service."
        },
        "product": {
            "ui:widget": "hidden"
        },
        "setupPrice": {
            "ui:help": "setup fee"
        },
        "supply": {
            "ui:help": "Maximum supply of services according to service offerings. It represents maximum number of clients that can consume this service offering concurrently."
        },
        "template": {
            "ui:widget": "hidden"
        },
        "unitName": {
            "ui:help": "MB/Minutes"
        },
        "unitPrice": {
            "ui:help": "Price in PRIX for one unit of service."
        },
        "additionalParams": {
            "ui:widget": "hidden"
        }
    }
}
```

## Offering message packaging

Offering message is composed from:

* message payload - filled offering template
* signature - Agent's account signature using public key \(same as for offering publishing\)

Service offering message format:

| message payload | signature |
| :--- | :--- |
| variable length | 64 bytes |

## Offering signing

Signature is generated using standard Ethereum crypto package `Sign()` function. It takes filled offering template in JSON format \(message payload\) as raw bytes.

### Offering signature generation

1. Generate keccak-256 hash of message payload \(as raw bytes\)
2. Sign hash with private key using Ethereum crypto package `Sign()` function

## Offering message hash

Keccak-256 hash of offering message \(aka offering hash\) is used to uniquely identify offering. Hash is performed on whole offering message \(already signed\).

### Offering hash generation

1. Generate keccak-256 hash of offering message

## Offering verification

1. Split message payload by removing last 64 bytes of message
2. Verify that specified in payload template exists
3. Generate keccak-256 hash of message payload
4. Use Ethereum crypto package `SigToPub()` function to retrieve Agent's public key
5. Compare provided in message payload Agent's public key to that from step \(5\)
6. Validate message payload to corresponding template JSON scheme

## Offering supply

Each `offering template` has mandatory parameter called `max. supply`. When Agent creates offering he must specify how many simultaneous orders can be processed for that offering. E.g. how many clients can simultaneously consume service. `Max. supply` used mainly for two purposes:

* calculate `Agent's deposit` and require Agent to place it, when offering is published
* make Clients always aware of Agent's capacity.

There are several ethereum events that involved in current supply change notification:

* `LogOfferingCreated` - newly created offering. `_current_supply` argument contains `max. supply` for that offering.
* `LogChannelCreated` - somebody created channel for offering. It means that offering current supply decreased.
* `LogCooperativeChannelClose` - somebody closed channel. Offering supply increased.
* `LogUnCooperativeChannelClose` - somebody closed channel. Offering supply increased.

## Offering publish workflow

In this workflow Agent creates new offering, that is discovered by Client.

1. Agent chooses offering template
2. Agent fills parameters in template
   * unit price, min. units, max. supply, etc.
3. Agent publishes offering hash in blockchain together with `Agent's deposit` using smart contract method:

   ```text
   function registerServiceOffering (bytes32 _offering_hash, uint192 _min_deposit, uint16 _max_supply, uint8 _source_type, string _source)
   ```

4. Agent's `ethereum monitor` receives ethereum event which is treated as publish success confirmation:

   ```text
   event LogOfferingCreated(address indexed _agent, bytes32 indexed _offering_hash, uint256 indexed _min_deposit, uint16 _current_supply, uint8 _source_type, string _source);
   ```

   where:

   `_agent` - ethreum addres of agent

   `_offering_hash` - hash of full offering message \(unique\)

   `_min_deposit` - min. deposit for Client

   `_current_supply` - max. concurrent orders that Agent can deliver. \(limits number of simultaneous state channels that can exists for an offering\)

   `_source_type` - messaging transports that can be used to get full offering and access message

   `_source` - addresses of sources \(usually URLs\), that can be used to retrieve offering and access message

5\) Client receive same event `LogOfferingCreated`. Job `ClientAfterOfferingMsgBCPublish` created in order to get full offering message. 6\) If Client allows to use at least one messaging transport listed in `_source_type`, full offering will be retrieved and validated for compliance with related offering template. If no matching offering template found in Client's database or validation fails, such offering will be ignored. 7\) Successfully retrieved and validated offerings are stored in database. They can be viewed, filtered and accepted.

## Offering accept workflow

In this workflow Client accepts offering and get ready to use service. Client will `ping` Agent using preferred `messaging transport` to check, if he is alive, before he places deposit.

1. Offering is accepted by Client - job `clientPreChannelCreate` is created.
2. During job `clientPreChannelCreate` execution:
   * Available supply checked
   * Account balance is checked to have sufficient tokens to create channel
   * Transaction is sent to create channel and place deposit
3. Agent receives event `LogChannelCreated` and setups channel in database during job `AgentAfterChannelCreate`.

After `offering accept workflow` is finished, `access workflow` is started.

