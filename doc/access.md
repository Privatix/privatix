# Access

Access to service is granted after Agent receives notification of new channel was created for his offering:

```Solidity
event LogChannelCreated(address indexed _agent, address indexed _client, bytes32 indexed offering_hash, uint192 _deposit)
```

When Client receives same Ethereum event, he knows that he should shortly try to contact Agent and get `access message`. Client queries Agent for `access message`, providing `channel key` compliant with smart contract method:

```Solidity
function getKey(address _client_address, address _agent_address, uint32 _open_block_number,  bytes32 _offering_hash)
```

Agent than retrieves `access message` from database and passed it to Client.

`access message` is always encrypted using Client's public key, thus can be decrypted only by intended Client. Client's public key is reconstructed from `createChannel` Ethereum transaction.

Access message (aka endpoint message) is created by Agent according to `access template`.

`Access template` is agreed format for message, that contains all data needed to Client for this particular service. Access template shipped with `service plug-in`. Each `service plug-in` has unique access template. Both Agent and Client have identical access template, when choose to use same `service plug-in`.

`Access template` - is JSON schema that includes:

- `Access schema` - access fields to be filled by Agent
  - `Core fields` - fields that common for any service. They are required for proper `Privatix core` operation. They are generic and doesn't contain any service specifics.
  - `Service custom fields` - (aka additional parameters) any fields that needed for particular service operation. They do not processed by `Privatix core`, but passed to `Privatix adapter` for any custom logic.
- `UI schema` - schema that can be used by GUI to display fields for best user experience (currently not implemented)

Each `Access template` has unique hash. Any access message always includes in its body hash of corresponding `access template`. That's how access message is linked to template and related `service plug-in`. When Client receives access message, he checks that:

- Access template with noted hash exists in Client's database
- Access message passes validation according to access template

Such validation ensures, that Agent and Client both has:

- exactly same access template
- access message is properly filled according to access template schema

## Access template schema example

```JSON
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

- `additionalProperties` may contain DNS name and credentials for some web service. It will be received by Client's adapter and used to connect to web-service and consume a service.
- `additionalProperties` may contain geolocation of apartment with direction how to open it. Direction maybe seen via user interface and/or sent to e-mail.


All automation is done by adapter. Adapter gets access message content and can process `additionalProperties` data for authentication, preparing necessary configuration, running additional processes.

## Access workflow

After Agent receives event `LogChannelCreated` he should process order and give access to Client for a service. This can be handled by adapter making additional work. Finally, `access message` is generated in `Privatix core database` and ready to be passed to Client.

1. Client queries Agent for `access message` via one of `messaging transport`
2. access message received from Agent (job `ClientAfterChannelCreate`)

3. Then in job `AgentPreEndpointMsgCreate`

   a. Agent's signature verified

   b. Message payload is decrypted

   c. Matching access template is found in local database

   d. Access message is validated to comply with `access template schema`

Access is granted and maybe consumed by Client. Usually processed by Client's adapter.

## Access message format

| encrypted payload | signature |
| ----------------- | --------- |


### Access message packaging

1. Fill endpoint template (JSON)
2. Encrypt message payload using ECIES Ethereum implementation [ecies.Encrypt()](https://godoc.org/github.com/ethereum/go-ethereum/crypto/ecies#Encrypt)
3. Generate keccak-256 hash of encrypted message payload (as raw bytes)
4. Sign hash with private key using Ethereum crypto package `Sign()` function

## Access message hash

Keccak-256 hash of access message is used to uniquely identify access message. Hash is performed on whole offering message (already encrypted and signed).

## Access message verification

1. Split message encrypted payload by removing last 64 bytes of message
2. Generate keccak-256 hash of message payload
3. Use Ethereum crypto package `SigToPub()` function to retrieve Agent's public key
4. Compare provided in offering Agent's public key to that from step (3)
5. Decrypt encrypted message payload using [ecies.Decrypt()](https://godoc.org/github.com/ethereum/go-ethereum/crypto/ecies#PrivateKey.Decrypt)
6. Validate message payload to corresponding template JSON scheme
