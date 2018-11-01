# How to build privatix application on Linux

Supported OS
* All LTS Desktop Ubuntu from 16.04
* Debian 8 Desktop 
* Debian 9 Desktop

## Build

To start build, run the following script:

```bash
git/git_clone.sh ../build.config 
./build.sh ../build.config
```

In case you want to fetch changes to local repositories, run the following script:

```bash
git/git_fetch.sh ../build.config 
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
