# How to build privatix application on UNIX-like operating systems

## Full build scenario

Easy way to build an run the application is to execute following
commands:

Run as a Client:

```bash
./build.sh ../build.config
./run_client.sh ../build.config
```

Run as an Agent:

```bash
./build.sh ../build.config
./run_agent.sh ../build.config
```

## Recommended way (Step by step)

This is a recommended way to build and run the application.

That provides more transparency and simplicity to the debugging process.

```bash
./git/git_checkout.sh ../build.config

./build_backend.sh ../build.config

./build_gui.sh ../build.config

./prepare_openvpn.sh

./run_client.sh ../build.config
# or 
# ./run_agent.sh ../build.config
```

## Clear after run

Don't forget to kill all child processes after application work:

```bash
./kill_app.sh
```
## Changing the Role

If you want to change the application role (Agent|Client), we recommend to
perform the building process from the beginning:

```bash
./build.sh ../build.config
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
