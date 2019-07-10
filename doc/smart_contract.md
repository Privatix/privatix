# Smart contracts

Ethereum smart contracts used during offering discovery and payment processing:

- Privatix token contract (PTC) - holds all PRIX tokens, compliant with ERC20 standard.
- Privatix service contract (PSC) - state channels and offering announcement

## PTC - Privatix token contract

Token exchange between Ethereum accounts is done using standard ERC20 transfer mechanism. PTC balances will be used to buy and sell PRIX only, rather than pay for services. To use Privatix services PRIX tokens will be approved for transfer to PSC contract address effectively delegating all operations to PSC contract.

### Features

- Token exchange
- Upgrade to new service contract
- Approve token transfer to PSC
- Get balance of user

## PSC - Privatix service contract

PSC contract implements state channels features, service offering discovery, helps to negotiate on service setup, incentivize fair usage and controls supply visibility.

### Features

- Local balance storage
- Agent SO registration and deposit placement
- Agent SO deactivation and deposit return
- Retrieving available supply for offering
- Pop up offering
- Create state channel
- Cooperative close of channel (normal)
- Uncooperative close of channel (dispute)
- Top up deposit of state channel
- Get internal balance of user

#### Constructor parameters

`_token_address` - The address of the PTC (Privatix Token Contract)

`_popup_period` - A fixed number of blocks representing the pop-up period.

`_remove_period` - A fixed number of blocks representing the remove period.

`_challenge_period` - A fixed number of blocks representing the challenge period.

`_network_fee_address` - Address where fee from each closed channel transaction goes. This is `Privatix company` help address to support software development.

### Network fee

`Network fee` is a fee that goes in favor of `Privatix company`. It can be changed by `Privatix company` anytime. Fee manipulation is limited by smart contract.

    Network fee percent maybe vary between 0 and 1%

#### Network fee update

```Solidity
/// @notice Change network fee value. It is limited from 0 to 1%.
/// @param  _network_fee Fee that goes to network_fee_address from each closed channel balance.
function setNetworkFee(uint32 _network_fee) external onlyOwner { // test S22
    require(_network_fee <= 1000); // test S23
    network_fee = _network_fee;
}
```

## Contract upgrade

Upgrade to new PSC contract is done by transferring all tokens from old PSC to PTC and then from PTC to new PSC.

# Sybil attack mitigation

- Agents and Clients pay ETH for transaction
- Agent and Client place same deposit during `offering publish` and `offering accept` workflows

## Malicious Agent

To maintain network health and incentivize fair usage, we will require Agents to register their service offering in Ethereum blockchain and place deposit. This deposit can be returned back after some `challenge period` is passed from last operation with offering.

This step should reduce junk offerings and make Sybil attack less efficient. Agent Deposit should be proportional to service supply. If malicious Agent will place useless offering, that he never goes to fulfill, he will be required to place exactly same deposit as Client will place to accept this offering.

When time passes from offering registration, Clients will more likely to consider that this offering is irrelevant. Agent will need to notify Clients from time to time that his offer is still relevant by popping up it. When Agent pop-ups his offering, deposit will be locked once more for the pop-up period. Long running offerings can be rated by comparing number of cooperative channel closes with uncooperative. If Client creates state channel, but does not receive service he will be forced to make uncooperative channel close. In that case, blockchain event will be emitted where Agent address is listed. If Client will see that there is too many uncooperative closes compared to cooperative once, he might not create new state channel with this agent. This will require malicious Agent to create new Agent address, transfer tokens and register new service offering. Such operation is expensive and not effective.

If Agent will try to act both as Agent and Client to increase number of cooperative closes, it will cost him additional transaction fees.

Sybil attack by Agent is limited with Agent token balance, by challenge period and popup period and burns Ether with transaction cost.

## Malicious Client

To harm Agent's reputation malicious Client can create state channel and will not send balance proofs to Agent. When creating channel, Client is required to place deposit, which is locked for challenge period. To return deposit back to his balance he need to close the channel. Both operations burns Ether with transaction cost. Agent can also check blockchain event for uncooperative closes of channel made by Client and rate him accordingly.

# Reputation

Both Client and Agent communication results in cooperative or uncooperative channel close. Each time blockchain event is generated with address of Client and Agent included in it. These events can be used to make decisions about user reputation. User can not only count number of cooperative vs uncooperative closes for another user, but also go deeper and build web of trust.

<details><summary>Example</summary>

If Agent want to decide on Client's reputation he can check Client's good transactions with other Agents and then check, if he had previously communicated with some of those Agent's.

</details>

### Normal to Dispute close

We may analyze reputation of service offering submitters (Agents) by observing number of cooperative and uncooperative closes that corresponds to their Ethereum address. This can be achieved by filtering blockchain events:

- LogCooperativeChannelClose
- LogUnCooperativeChannelClose

### Closing balance of channel

We may analyze delta between min. deposit and closed channel balance. This can make indication of expected deal and its result.

<details><summary>Example</summary>

- Let's offering min. deposit be OMD.
- Let's channel closing balance be CSB.

Then

We can take in account `OMD - CSB` or `OMD/CSB`.

</details>

# Ethereum operations by core

Monitoring and operations on ethereum are done:

- [by ethereum monitor](ethereum_monitor.md) - events retrieval
- [by eth package](https://github.com/Privatix/dappctrl/tree/master/eth) - transactions
