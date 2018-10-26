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
|[PSC](https://rinkeby.etherscan.io/address/0x3efbb281fc51c8da1f76b96acf536f777ec3c3cf)|0x3efbb281fc51c8da1f76b96acf536f777ec3c3cf|

#### Changes

```
event LogOfferingPopedUp(
    address indexed _agent,
    bytes32 indexed _offering_hash,
    uint256 indexed _min_deposit,
    uint16 _current_supply,
    uint8 _source_type,
    bytes _source);
```

signature is the same as in LogOfferingCreated. Affects ```function popupServiceOffering```


```
event LogOfferingCreated(
    address indexed _agent,
    bytes32 indexed _offering_hash,
    uint256 indexed _min_deposit,
    uint16 _current_supply,
    uint8 _source_type,
    bytes _source);
```
new fields - ```_source_type``` and ```_source```. Affects ```function registerServiceOffering```
