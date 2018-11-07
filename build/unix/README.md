# How to build privatix application on UNIX-like operating systems

Ensure that all [prerequisites software](https://github.com/Privatix/privatix/tree/develop/build#install-prerequisites)
has been installed.

## Prepare Build Config

Config is located here: [build.config](build.config)
Check that all variables in the config are correct.

All build scripts use this config.

## Clone repositories

To clone all required repositories, execute the following script:

```bash
./git/clone.sh
```

## Update Repositories

To update all required repositories, execute the following script:

```bash
./git/pull.sh
```

## One-command build

The easy way to build the application is to execute the following
command:

```bash
./build.sh
```

## Recommended way (Step by step)

This is a recommended way to build the application.

That provides more transparency and simplicity to the debugging process.

Please execute step by step the following commands:

```bash
# Clear the bin directory and
# create a folder structure
./clear.sh

# Checkout repositories at ${GIT_BRANCH} branch
./git/checkout.sh

# Build the `dappctrl` by using
# "${DAPPCTRL_DIR}"/scripts/build.sh
./build_dappctrl.sh

# Build the dapp-openvpn by using
# "${DAPP_OPENVPN_DIR}"/scripts/build.sh
./build_dappopenvpn.sh

# Build the dapp-gui by using
# nmp i && npm run build
./build_dappgui.sh

# Copy all binaries to the ./bin folder
./cp_binaries.sh

# Copy all necessary configs to the ./bin folder
# patch configs according to the environment
./cp_configs.sh

# Create the database by using
# "${DAPPCTRL_DIR}"/scripts/create_database.sh
./create_database.sh

# Create products in the database according 
# to the templates from ./bin/dapp_openvpn/
# Copy new dapp-openvpn configs to 
# the ./bin/openvpn_client and the ./bin/openvpn_server
./create_products.sh

# Prepare ./bin/openvpn_client and ./bin/openvpn_server
# create all necessary configs.
# Register ./bin/openvpn_server/bin/openvpn as daemon
# starts ./bin/openvpn_server/bin/openvpn as daemon
./start_openvpn.sh
# to stop and unregister openvpn use:
# ./stop_openvpn.sh ../build.config
```

## Run

After build has been completed successfully, you can run the Application.

All application binaries and configs are located in `.bin` folder.

### Client

To run:

* dappctrl
* dapp-openvpn
* dapp-gui

in Client mode, execute the following script:

```bash
./run_client.sh
```

### Agent
To run:

* dappctrl
* dapp-openvpn
* dapp-gui

in Agent mode, execute the following script:

```bash
./run_agent.sh
```

## Clear after run

Don't forget to kill all child processes after application work:

```bash
./kill_app.sh
./stop_openvpn.sh
```

## Changing the Role

If you want to change the application role (Agent|Client), we recommend to
perform the building process from the "copy binaries" step:

```bash
./cp_binaries.sh
./cp_configs.sh
./create_database.sh
# if openvpn is stopped
# ./start_openvpn.sh
./run_client.sh # or ./run_agent.sh
```

instead of:

```bash
./run_client.sh # or ./run_agent.sh
```

## Manual build

If you want to build all parts of the privatix application manually, 
follow the steps.

### Build dappctrl

[Build instruction](https://github.com/Privatix/dappctrl/blob/master/README.md)

### Build dapp-openvpn installer

[Build instruction](https://github.com/Privatix/dapp-openvpn/tree/master/inst/README.md)

### Build dapp-openvpn

[Build instruction](https://github.com/Privatix/dapp-openvpn/tree/master/README.md)

### Build dapp-gui

[Build instruction](https://github.com/Privatix/dapp-gui/README.md)
