## RINKEBY

### Average time estimation:

5 blocks -> 4 block per minute -> 1,25 minutes

### Experimental

#### Periods

|Period's name|Value in blocks|
|-|-|
|remove_period|5|
|popup_period|10|
|challenge_period|20|

#### Addresses

|Contract's Name|Address|
|-|-|
|[Sale](https://rinkeby.etherscan.io/address/0x4d15c86c78128a6e216615f4345dfe32fb43181d)|0x4d15c86c78128a6e216615f4345dfe32fb43181d|
|[Token](https://rinkeby.etherscan.io/token/0x0d825eb81b996c67a55f7da350b6e73bab3cb0ec)|0x0d825eb81b996c67a55f7da350b6e73bab3cb0ec|
|[PSC](https://rinkeby.etherscan.io/address/0x7ee4f7c659c1c58050d70af278e8901fc315a11e)|0x7ee4f7c659c1c58050d70af278e8901fc315a11e|

#### Changes

```
event LogOfferingPopedUp(
    address indexed _agent,
    bytes32 indexed _offering_hash,
    uint256 indexed _min_deposit,
    uint16 _current_supply,
    uint8 _source_type,
    string _source);
```

signature is the same as in LogOfferingCreated. Affects ```function popupServiceOffering```


```
event LogOfferingCreated(
    address indexed _agent,
    bytes32 indexed _offering_hash,
    uint256 indexed _min_deposit,
    uint16 _current_supply,
    uint8 _source_type,
    string _source);
```
new fields - ```_source_type``` and ```_source```. Affects ```function registerServiceOffering```
