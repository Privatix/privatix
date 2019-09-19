# Offering message

Offering messages \(aka offerings\) are created by Agents according to [`offering template`](offering-template.md).

Offerings are briefly just JSON object, that contains all offering data. To ensure that offering is immutable and to give ability for Clients to discover them, we want it to be placed in blockchain. But storing extensive amount of data in blockchain is costly. We store only hash of offering message and URL address, where full offering message can be retrieved.

## Offering workflows

### Offering publish workflow

In this workflow Agent creates new offering, that is discovered by Client.

1. Agent chooses offering template
2. Agent fills parameters in template and creates offering message.
   * unit price, min. units, max. supply, etc.
3. Agent publishes `offering message hash` in blockchain together with `Agent's deposit` , `max supply`, `transport types` \(source type\) and `transport address` \(source\), using smart contract method:

   ```text
   function registerServiceOffering (bytes32 _offering_hash, uint192 _min_deposit, uint16 _max_supply, uint8 _source_type, string _source)
   ```

4. Agent's `ethereum monitor` receives Ethereum event which is treated as publish success confirmation:

   ```text
   event LogOfferingCreated(address indexed _agent, bytes32 indexed _offering_hash, uint256 indexed _min_deposit, uint16 _current_supply, uint8 _source_type, string _source);
   ```

   where

`_agent` - Ethereum address of agent

`_offering_hash` - hash of full offering message \(unique\)

`_min_deposit` - min. deposit for Client

`_current_supply` - max. concurrent orders that Agent can deliver. \(limits number of simultaneous state channels that can exists for an offering\)

`_source_type` - messaging transport types that can be used to get full offering and access message

`_source` - addresses of sources \(usually URLs\), that can be used to retrieve offering and access message

1. Client receive same Ethereum event `LogOfferingCreated`. Job `ClientAfterOfferingMsgBCPublish` created in order to get full offering message. 
2. If Client allows to use at least one messaging transport listed in `_source_type`, full offering will be retrieved and validated for compliance with related offering template. If no matching offering template found in Client's database or validation fails, such offering will be ignored.
3. Successfully retrieved and validated offerings are stored in database. They can be viewed, filtered and accepted.

### Offering accept workflow

In this workflow Client accepts offering and get ready to use service. Client will `ping` Agent using preferred `messaging transport` to check, if he is alive, before he places deposit.

1. Offering is accepted by Client - job `clientPreChannelCreate` is created.
2. During job `clientPreChannelCreate` execution:
   * Available supply checked
   * Account balance is checked to have sufficient tokens to create channel
   * Transaction is sent to create channel and place deposit
3. Agent receives event `LogChannelCreated` and setups channel in database during job `AgentAfterChannelCreate`.

After `offering accept workflow` is finished, `access workflow` is started.

## Transport address

`Transport address` - is a string published to blockchain, that contains Agent's URL where offering message can be retrieved.

Agent publishes `transport address` during offering registration:

```text
function registerServiceOffering (bytes32 _offering_hash, uint192 _min_deposit, uint16 _max_supply, uint8 _source_type, string _source)
```

where

`_source_type` - messaging transports that can be used to get full offering and access message

`_source` - addresses of sources \(usually URLs\), that can be used to retrieve offering and access message

in same step Agent places deposit.

Read more about [transport](../transport.md).

## Agent deposit

Agent places deposit to make hold in smart contract same amount of tokens as all Clients would, if they will accept his offering in the same time. Meaning that Agents and Clients lock exactly same deposit. This should make economical attack from both sides less efficient.

Agent's deposit is calculated using offering parameters:

```text
    Agent deposit = Unit price * Min. units * Max. supply
```

Agent deposit is placed in smart contract method:

```text
function registerServiceOffering (bytes32 _offering_hash, uint192 _min_deposit, uint16 _max_supply, uint8 _source_type, string _source)
```

## Offering supply

Each `offering template` has mandatory parameter called `max. supply`. When Agent creates offering he must specify how many simultaneous orders can be processed for that offering. E.g. how many clients can simultaneously consume service. `Max. supply` used mainly for two purposes:

* calculate `Agent's deposit` and require Agent to place it, when offering is published
* make Clients aware of Agent's available capacity.

There are several ethereum events that involved in current supply change notification:

* `LogOfferingCreated` - newly created offering. `_current_supply` argument contains `max. supply` for that offering.
* `LogChannelCreated` - somebody created channel for offering. It means that offering current supply decreased.
* `LogCooperativeChannelClose` - somebody closed channel. Offering supply increased.
* `LogUnCooperativeChannelClose` - somebody closed channel. Offering supply increased.

## Offering message processing

### Format

Offering message is composed from:

* message payload - filled offering template
* signature - Agent's account signature using public key \(same as for offering publishing\)

| message payload | signature |
| :--- | :--- |
| variable length | 64 bytes |

### Offering message packaging

1. Fill offering template \(JSON\)
2. Generate keccak-256 hash of encrypted message payload \(as raw bytes\)
3. Sign hash with private key using Ethereum crypto package `Sign()` function

### Offering signing

Signature is generated using standard Ethereum crypto package `Sign()` function. It takes filled offering template in JSON format \(message payload\) as raw bytes.

#### Offering signature generation

1. Generate keccak-256 hash of message payload \(as raw bytes\)
2. Sign hash with private key using Ethereum crypto package `Sign()` function

### Offering message hash

Keccak-256 hash of offering message \(aka offering hash\) is used to uniquely identify offering. Hash is performed on whole offering message \(already signed\).

#### Offering hash generation

1. Generate keccak-256 hash of offering message

### Offering verification

1. Split message payload by removing last 64 bytes of message
2. Verify that specified in payload template exists
3. Generate keccak-256 hash of message payload
4. Use Ethereum crypto package `SigToPub()` function to retrieve Agent's public key
5. Compare provided in message payload Agent's public key to that from step \(4\)
6. Validate message payload to corresponding template JSON scheme

