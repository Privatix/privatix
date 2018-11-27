# Change log

## 21.11.2018

- `event LogOfferingCreated(... uint8 _source_type, string _source);`
- `event LogOfferingPopedUp(... uint8 _source_type, string _source);`
- `function registerServiceOffering (... uint8 _source_type, string _source) external`
- `function popupServiceOffering (... uint8 _source_type, string _source) external`

## 11.10.2018

- `bytes32 _authentication_hash` removed from `createChannel` signature
- function `publishServiceOfferingEndpoint` removed
- event LogOfferingEndpoint removed

## 09.10.2018

- challenge_period was returned, so we have challenge period for channels and remove_period/pop_period for offerings

## 21.09.2018

- Added separate challenge period for PopUP and Remove
- Removed update_block_number from decreaseOfferingSupply
- Removed ServiceOffering.isActive due to save GAS

## 24.08.2018

- getOfferingSupply function removed by getOfferingInfo

- fixed LogUnCooperativeChannelClose event (balance)
- [added](https://github.com/Privatix/dapp-smart-contract/commit/a2b4d9ea9d9735f683dff377a9731037886ff696) `psc.getOfferingSupply(offering_hash)` function
- LogOfferingSupplyChanged event [removed](https://github.com/Privatix/dapp-smart-contract/commit/d557c642359c6ec4cd90132674661b5e00435735)
- sender balance proof signature & receiver closing signature are [changed](https://github.com/Privatix/dapp-smart-contract/commit/b388e015abb40c67aa866ed9024456e14879e9f3)
