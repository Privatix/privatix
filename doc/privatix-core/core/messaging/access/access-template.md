# Access template

## Access template

`Access template` is agreed format for message, that contains all data needed to Client for this particular service. Access template shipped with `service plug-in`. Each `service plug-in` has unique access template. Both Agent and Client have identical access template, when choose to use same `service plug-in`.

`Access template` - is JSON schema that includes:

* `Access schema` - access fields to be filled by Agent
  * `Core fields` - fields that common for any service. They are required for proper `Privatix core` operation. They are generic and doesn't contain any service specifics.
  * `Service custom fields` - \(aka additional parameters\) any fields that needed for particular service operation. They do not processed by `Privatix core`, but passed to `Service adapter` for any custom logic.
* `UI schema` - schema that can be used by GUI to display fields for best user experience \(currently not implemented\)

Each `Access template` has unique hash. Any access message always includes in its body hash of corresponding `access template`. That's how access message is linked to template and related `service plug-in`. When Client receives access message, he checks that:

* Access template with noted hash exists in Client's database
* Access message passes validation according to access template

Such validation ensures, that Agent and Client both has:

* exactly same access template
* access message is properly filled according to access template schema

## Access template schema

**Schema example**

```javascript
{
    "title": "Privatix VPN access",
    "type": "object",
    "description": "Privatix VPN access template"
    "definitions": {
        "host": {
            "pattern": "^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])(\\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9]))*:[0-9]{2,5}$",
            "type": "string"
        },
        "simple_url": {
            "pattern": "^(http:\\/\\/www\\.|https:\\/\\/www\\.|http:\\/\\/|https:\\/\\/)?.+",
            "type": "string"
        },
        "uuid": {
            "pattern": "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
            "type": "string"
        }
    },
    "properties": {
        "templateHash": {
                "title": "access tempate hash",
                "type": "string",
                "description": "Hash of this access template"
        },
        "nonce": {
            "title": "nonce",
            "type": "string",
            "description": "uuid v4. Allows same access template to be shipped twice, resulting in unique access template offering hash."
        },
        "username": {
            "$ref": "#/definitions/uuid"
        },
        "password": {
            "type": "string",
            "description": "Can be used to transfer password"
        },
        "paymentReceiverAddress": {
            "$ref": "#/definitions/simple_url",
            "description": "Address and port of agent's payment reciever endpoint"
        },
        "serviceEndpointAddress": {
            "type": "string",
            "description": "(Optional) E.g. address of web service."
        },
        "additionalParams": {
            "additionalProperties": {
                "type": "string"
            },
            "minProperties": 1,
            "type": "object"
        }
    },
    "required": [
        "templateHash",
        "paymentReceiverAddress",
        "serviceEndpointAddress",
        "additionalParams"
    ]
}
```

`additionalProperties` parameter may contain any arbitrary data required to access the service or receive the product.

**Examples**

* `additionalProperties` may contain DNS name and credentials for some web service. It will be received by Client's adapter and used to connect to web-service and consume a service.
* `additionalProperties` may contain geolocation of apartment with direction how to open it. Direction maybe seen via user interface and/or sent to e-mail.

All automation is done by adapter. Adapter gets access message content and can process `additionalProperties` data for authentication, preparing necessary configuration, running additional processes.

