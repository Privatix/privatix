# How to build privatix application on Mac

## Build

To start build, run the following script:

```bash
./git/git_clone.sh ../build.config 
./git/git_checkout.sh ../build.config 

./build.sh ../build.config
```

In case you want to fetch or pull changes to local repositories, run the following script:

```bash
./git/git_fetch.sh ../build.config 

#or

./git/git_pull.sh ../build.config 
```

### Build only backend

#### Build from scratch:

```bash
./git/git_clone.sh ../build.config 
./git/git_checkout.sh ../build.config 

./build_backend.sh ../build.config
```

#### Build from existing sources:

```bash
./git/pull.sh ../build.config 
./git/git_checkout.sh ../build.config 

./build_backend.sh ../build.config
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
