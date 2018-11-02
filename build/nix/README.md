# How to build privatix application on UNIX-like operating systems

## Build

To start build, run the following script:

```bash
./build.sh ../build.config
```

### Build only backend

```bash
./build_backend.sh ../build.config
```

### Build only GUI

```bash
./build_gui.sh ../build.config
```

## Run

```bash
./run.sh ../build.config
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
