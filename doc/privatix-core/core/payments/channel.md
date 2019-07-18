# State channels

Payment is implemented using `state channels`. Client places deposit into smart contract to some temporary account called channel. This prevents double spending. Then Client will send constantly increasing cheque matching total usage directly to Agent. Every cheque includes allowance to withdraw signed using Client's signature. Anytime Agent can send transaction to smart contract presenting signed cheque. Smart contract will verify signature and transfer cheque balance to Agent's account, while remainder will return to Client's balance. After that channel will be deleted.

## Client deposit

Client's deposit is calculated using offering parameters:

```text
Client deposit = Unit price * Min. units
```

Client's deposit is placed in smart contract method:

```text
function createChannel(address _agent_address, bytes32 _offering_hash, uint192 _deposit)
```

Reason, why Client places deposit is to guarantee to an Agent that he always holds tokens for expected deal. Agent always places same expected minimum deposit, when offering is published.

## Channel create

Channel created using smart contract method:

```text
function createChannel(address _agent_address, bytes32 _offering_hash, uint192 _deposit)
```

Channel unique key is comprised of:

```text
function getKey(address _client_address, address _agent_address, uint32 _open_block_number,  bytes32 _offering_hash)
```

where:

`_client_address` - ethereum address of client

`_agent_address` - ethereum address of agent

`_open_block_number` - ethereum block number in which transaction that created channel was mined

`_offering_hash` - hash of offering message

`_deposit` - tokens that placed as deposit to state channel

After Client has created state channel, Agent and Client receive ethereum event:

```text
event LogChannelCreated(address indexed _agent, address indexed _client, bytes32 indexed offering_hash, uint192 _deposit)
```

## Top-up channel deposit

After channel is created and before it was deleted Client can increase state channel deposit calling smart contract method:

```text
function topUpChannel(address _agent_address, uint32 _open_block_number, bytes32 _offering_hash, uint192 _added_deposit)
```

Agent then receives event and can continue to provide the service up to new total deposit value. 

## Close channel

Channel can be closed by Agent \(normally\) or by Client \(dispute\).

### Normal close

Agent closes channel optimally when he have cheque with amount equal to channel deposit. It means that client used at least minimum expected units to be sold. It is done automatically by [Agent billing](agent_billing.md) engine. But he can choose to close channel manually anytime via `UI API`. Smart contract method called:

```text
function cooperativeClose(address _agent_address, uint32 _open_block_number, bytes32 _offering_hash, uint192 _balance, bytes _balance_msg_sig, bytes _closing_sig)
```

during this call Agent sends the greatest cheque received from Client. Transaction must contain both Client's and Agent's signatures to ensure integrity and belonging. Channel will be deleted.

### Dispute close

Client may also want to close channel and return full deposit back. Reasons:

* Agent never provided service, thus never received cheque and doesn't closes channel
* Agent doesn't closes channel for long time, but Client eligible to get part of its deposit back, as he haven't used whole deposit.

Client will need to call two smart contract methods after some period passes between each call.

This period is specified in smart contract and doesn't change. Such period is called `Dispute period` or `Challenge period`.

First Client create calls smart contract method: 

```text
function uncooperativeClose(address _agent_address, uint32 _open_block_number, bytes32 _offering_hash, uint192 _balance)
```

This method generates Ethereum event

```text
event LogChannelCloseRequested(address indexed _agent, address indexed _client, bytes32 indexed _offering_hash, uint32 _open_block_number, uint192 _balance)
```

It notifies an Agent that Client wants to take his whole deposit back from state channel. Than Agent can immediately present cheque, if he already have it from Client and make `normal close`.

But, if Agent doesn't make `normal close` and `dispute period` is passed, Client can call second smart contract method:

```text
function settle(address _agent_address, uint32 _open_block_number, bytes32 _offering_hash)
```

and this call will make full deposit return from channel back to Client's account. Channel will be deleted.

#### Dispute period

`Dispute period` - period counted in Ethereum blocks that need to pass between Client calls `uncooperativeClose` and `settle` methods of smart contract. If period is not passed, `settle` method will fail.

## Status

There are to statuses related to state channel. 

* status of service - responsible for access to service
* state channel status in blockchain

### Service status

Specifies service status for specific state channel

| **Service status** | **Agent description** | **Client description** |
| :--- | :--- | :--- |
| Pending | Service is still not provisioned and cannot be used. | Service is still not provisioned and cannot be used. |
| Activating | Core is waiting for service provisioning | Core is waiting for service activation by adapter |
| Active | Service is ready to be used. | Currently using service. |
| Suspending | Core is waiting for service access blocking. | Core is waiting for service usage pause by adapter |
| Suspended | Service usage is suspended. Only payment receival is allowed, but service usage is restricted. | Service is not used - currently paused |
| Terminating | Core is waiting for service access to be blocked and service deprovisioning | Core is waiting for service to be stopped and deprovisioned by adapter. |
| Terminated | Service is permanently deactivated. | Service is permanently deactivated. |

### Channel status

Channel status is registered in database and specifies last known state channel status in blockchain

| **Blockchain status** | **Description** |
| :--- | :--- |
| Pending | Transaction was sent, but confirmation still not received. |
| Active | State channel is registered and desired confirmation number is reached. |
| Wait for cooperative close | Cooperative close transaction was submitted, but confirmation still not received. |
| Cooperatively closed | Cooperative close transaction is registered and desired confirmation number is reached. |
| Wait to start challenge period | Waiting to start challenge period. |
| In challenge period | Challenge period started for uncooperative close. |
| Wait for uncooperative close | Waiting for settling state channel uncooperatively. |
| Uncooperatively closed | Uncooperative close transaction is registered and desired confirmation number is reached. |

{% hint style="info" %}
In UI known as contract status.
{% endhint %}

