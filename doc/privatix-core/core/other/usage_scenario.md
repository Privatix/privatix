# Basic usage scenario

## Agent basic workflow

* Fill offering template for service
* Publish offering link to blockchain. Place deposit.

**Agent setup workflow**

1. Get some `PRIX tokens` on any token exchange. \(airdropped via `Privatix telegram bot` @PRIXBot in testnet\)
2. Install `Privatix core` software and at least one `service module` \(_currently VPN module is pre-installed_\).
3. Setup account via `Privatix UI`. This includes setting up private key and making token transfer.
4. Fill offering template for the particular service \(template comes with `service module`\). Specify:
   * Max. concurrent users of this offering
   * Price for unit of service
   * Minimum required deposit
   * Max. tolerance for payment lag in units of service
   * Max. time to wait for first service use
   * Max. time to wait, if client stops using the service
   * Any other custom parameters related to particular service.
5. Publish `offering link` to blockchain, while placing _same deposit_, as expected from clients. Deposit prevents from spamming the network with junk offerings. Deposit received back, when `offering link` is deleted. It usually takes about 1 minute to complete.

Agent setup finished. Client can accept offerings and all other essential operations orchestrated by `Privatix core` and automated by `service adapter`.

## Client basic workflow

* Accept offering. Place deposit.
* Start using the service and report usage

**Client setup workflow**

1. Get some `PRIX tokens` on any token exchange. \(Currently airdropped via `Privatix telegram bot` in testnet\)
2. Install Privatix core software and at least one `service module` \(_currently VPN module is pre-installed_\).
3. Setup account via `Privatix GUI`. This includes setting up private key and making token transfer.
4. Accept offering. Deposit required by offering will be placed. Access credentials for service will be retrieved. It usually takes about 1 minute to complete.

Client setup finished. Client can start using a service. All other operations will be orchestrated by `Privatix core` and automated by `service adapter`.

