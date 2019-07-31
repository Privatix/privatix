# Transport

Transport is messaging retrieval method. When Agent publishes offering in blockchain he also specifies how Client can retrieve messages and where Client should connect to get these messages. Protocol includes possibility to use several transports and more types of transport maybe added in future.

Transport type and address is stated during offering creation in smart contract.

```text
function registerServiceOffering (bytes32 _offering_hash, uint192 _min_deposit, uint16 _max_supply, uint8 _source_type, string _source)
```

`_source_type` - transport type. Used by Privatix core to properly handle transport protocol.

`_source` - transport address. Any data, that can be used to find resource, where message can be retrieved.

## Transports

Currently supported transports:

* `Tor` - used to keep Agent's and Client's IP address in secret during offering download and access setup. This prevents from easily extracting all Agent's IP addresses.
* `Direct IP` - communicates directly with Agent. IP addresses is publicly known.

Clients and Agent have a choice of transport to use.

{% hint style="warning" %}
Current versions support Tor transport only.
{% endhint %}

| Transport | \_source\_type |
| :--- | :--- |
| Tor | 0 |
| DirectIP | 1 |

### Tor transport

Client and Agent both can communicate anonymously, without revealing their IP addresses.

Tor is running as daemon. Tor hidden service is brought up on Agent's side. On Agent's side it will expose `somc server` \(web service\) via hidden service. Hidden service URL placed in `_source` parameter of smart contract method `registerServiceOffering`. Tor transport identifier is set in `_source_type`

Client will send request to `somc server` via Tor \(local proxy\).

### DirectIP transport

Web service is brought up on Agent's side that can be queried exactly same way as Tor, but using hostname of Agent. Its URL placed in `_source` parameter of smart contract method `registerServiceOffering`. DirectIP transport identifier is set in `_source_type`

