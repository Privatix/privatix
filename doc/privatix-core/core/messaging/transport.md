# Transport

## Transports

Currently supported transports:

* Tor - used to keep Agent's and Client's IP address in secret during offering download and access setup.
* Direct IP - communicates directly with Agent. IP addresses is publicly known.

Clients and Agent have a choice of transport to use.

### Tor transport

Client and Agent both can communicate anonymously, without revealing their IP addresses.

Tor is running as daemon. Tor hidden service is brought up on Agent's side. On Agent's side it will expose `somc server` via hidden service. Hidden service URL placed in `_source` parameter when offering is published to smart contract:

```text
function registerServiceOffering (bytes32 _offering_hash, uint192 _min_deposit, uint16 _max_supply, uint8 _source_type, string _source)
```

Client will send request to `somc server` via Tor \(local proxy\).

### DirectIP transport

Web service is brought up on Agent's side that can be queried exactly same way as Tor, but using hostname of Agent. Its URL placed in `_source` parameter when offering is published to smart contract:

```text
function registerServiceOffering (bytes32 _offering_hash, uint192 _min_deposit, uint16 _max_supply, uint8 _source_type, string _source)
```

