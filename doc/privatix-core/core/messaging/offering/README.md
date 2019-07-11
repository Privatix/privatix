# Offering message

Offering messages \(aka offerings\) are created by Agents according to [`offering template`](offering-template.md). `Offering link` is published to blockchain together with Agent's deposit.

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

