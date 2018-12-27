# Ethereum monitor

Ethereum monitor get ethereum events (aka logs) and creates jobs. from two smart contracts:

- Privatix token contract (PTC)
- Privatix service contract (PSC)

Each time it queries for events in some blocks range. Received events filtered and corresponding `jobs` produced based on events signatures (`topic[0]`) and user role.

Blocks range - is range of ethereum blocks that retrieved in each monitor iteration. Block influenced by:

- eth.event.lastProcessedBlock (settings)
- eth.min.confirmations (settings)
- eth.event.blocklimit (settings)
- eth.event.freshblocks (settings)
- BlockMonitor.InitialBlocks (config)

Events filtering and job mapping depends on `user role`. E.g. Agent only interested in `LogOfferingCreated`, where his address is found in topic, meaning that his offering succefully included in ethereum block. But Client is interested in all `LogOfferingCreated` events, as that's how he discovers offerings.

Single monitor iteration will produce number of jobs, that will be added to database in single SQL transaction.
