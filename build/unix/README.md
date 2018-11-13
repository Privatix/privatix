# How to build privatix application on UNIX-like operating systems

## Install Prerequisites

Install prerequisite software if it's not installed.

* [git](https://git-scm.com/downloads)

* [Golang](https://golang.org/doc/install) 1.11+. Make sure that 
`$GOPATH/bin` is added to system path `$PATH`.

* [PostgreSQL](https://www.postgresql.org/download/)
by default, the Application will try to connect to a postgress
via ```{"dbname": "dappctrl", "user": "postgres", "host": "localhost",
"port": "5432"}```

* [gcc](https://gcc.gnu.org/install/)

* [node.js](https://nodejs.org/en/) 9.3+

* [OpenVPN](https://openvpn.net/)

* [OpenSSL](https://www.openssl.org/)


### mac

```bash
brew install git
brew install go

brew install postgresql
brew services start postgresql

brew install gcc
brew install node

brew install openvpn
brew install openssl
```

### ubuntu

```bash
sudo apt update

sudo apt install git
sudo apt install gcc
sudo apt install curl
sudo apt install openvpn easy-rsa
sudo apt install openssl


cd ./prerequisites/ubuntu/
./install_go.sh
./install_node.sh

sudo ./install_postgress.sh
```

## Prepare Build Config

Config is located here: [build.config](build.config)


Make a copy of `build.config`:

```bash
cp build.config build.local.config
```

Modify `build.local.config` if you need non-default configuration.

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
# Checkout repositories at ${GIT_BRANCH} branch
./git/pull.sh

# Build the `dappctrl` by using
# "${DAPPCTRL_DIR}"/scripts/build.sh
./build_ctrl.sh

# Build the dapp-openvpn by using
# "${DAPP_OPENVPN_DIR}"/scripts/build.sh
./build_openvpn.sh

# Build the dapp-gui by using
# nmp i && npm run build
./build_gui.sh

# Create the database by using
# "${DAPPCTRL_DIR}"/scripts/create_database.sh
./create_database.sh

# Create products in the database according 
# to the templates from ./bin/dapp_openvpn/
# Copy new dapp-openvpn configs to 
# the ./bin/openvpn_client and the ./bin/openvpn_server
./create_products.sh

# Create all necessary configs and run openvpn 
# (only in Agent mode)
# ./run_openvpn.sh
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
```

## Changing the Role

If you want to change the application role (Agent|Client), we recommend to
perform the building process from the create database step:

```bash
./create_database.sh
./create_products.sh

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
