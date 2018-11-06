# How to build privatix application on UNIX-like operating systems

## One-command build

Easy way to build the application is to execute the following
command:

### Build
```bash
./build.sh ../build.config
```

## Recommended way (Step by step)

This is a recommended way to build and run the application.

That provides more transparency and simplicity to the debugging process.

### Build

Please execute step by step the following commands:

```bash
./clear.sh

./git/git_checkout.sh ../build.config

./build_dappctrl.sh ../build.config
./build_dappopenvpn.sh ../build.config
./build_dappgui.sh ../build.config

./cp_binaries.sh ../build.config
./cp_configs.sh.sh ../build.config

./create_database.sh ../build.config
./create_products.sh ../build.config

./start_openvpn.sh ../build.config
```

## Run

### Client

```bash
./run_client.sh ../build.config
```

### Agent

```bash
./run_agent.sh ../build.config
```

## Clear after run

Don't forget to kill all child processes after application work:

```bash
./kill_app.sh
./stop_openvpn.sh
```

## Changing the Role

If you want to change the application role (Agent|Client), we recommend to
perform the building process from the create database step:

```bash
./create_database.sh ../build.config

./start_openvpn.sh ../build.config

./run_client.sh ../build.config
```

instead of:

```bash
./run_client.sh ../build.config
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
