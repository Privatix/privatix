# Offering template

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

## Offering template schema

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

