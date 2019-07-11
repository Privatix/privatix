# Access message

Access messages are created by Agents and includes sufficient information to authenticate and start using a service.

Access to service is granted after Agent receives notification of new channel was created for his offering:

```text
event LogChannelCreated(address indexed _agent, address indexed _client, bytes32 indexed offering_hash, uint192 _deposit)
```

When Client receives same Ethereum event, he knows that he should shortly try to contact Agent and get `access message`. Client queries Agent for `access message`, providing `channel key` compliant with smart contract method:

```text
function getKey(address _client_address, address _agent_address, uint32 _open_block_number,  bytes32 _offering_hash)
```

Agent than retrieves `access message` from database and passed it to Client.

`access message` is always encrypted using Client's public key, thus can be decrypted only by intended Client. Client's public key is reconstructed from `createChannel` Ethereum transaction.

Access message \(aka endpoint message\) is created by Agent according to `access template`.

## Access workflow

After Agent receives event `LogChannelCreated` he should process order and give access to Client for a service. This can be handled by adapter making additional work. Finally, `access message` is generated in `Privatix core database` and ready to be passed to Client.

1. Client queries Agent for `access message` via one of `messaging transport`
2. access message received from Agent \(job `ClientAfterChannelCreate`\)
3. Then in job `AgentPreEndpointMsgCreate`

   a. Agent's signature verified

   b. Message payload is decrypted

   c. Matching access template is found in local database

   d. Access message is validated to comply with `access template schema`

Access is granted and maybe consumed by Client. Usually processed by Client's adapter.

## Access message format

| encrypted payload | signature |
| :--- | :--- |


### Access message packaging

1. Fill endpoint template \(JSON\)
2. Encrypt message payload using ECIES Ethereum implementation [ecies.Encrypt\(\)](https://godoc.org/github.com/ethereum/go-ethereum/crypto/ecies#Encrypt)
3. Generate keccak-256 hash of encrypted message payload \(as raw bytes\)
4. Sign hash with private key using Ethereum crypto package `Sign()` function

## Access message hash

Keccak-256 hash of access message is used to uniquely identify access message. Hash is performed on whole offering message \(already encrypted and signed\).

## Access message verification

1. Split message encrypted payload by removing last 64 bytes of message
2. Generate keccak-256 hash of message payload
3. Use Ethereum crypto package `SigToPub()` function to retrieve Agent's public key
4. Compare provided in offering Agent's public key to that from step \(3\)
5. Decrypt encrypted message payload using [ecies.Decrypt\(\)](https://godoc.org/github.com/ethereum/go-ethereum/crypto/ecies#PrivateKey.Decrypt)
6. Validate message payload to corresponding template JSON scheme

