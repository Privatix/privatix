# How to build privatix application on UNIX-like operating systems

## Install Prerequisites

Install prerequisite software if it's not installed.

* [git](https://git-scm.com/downloads)

* [Golang](https://golang.org/doc/install) 1.11+. Make sure that 
`$GOPATH/bin` is added to system path `$PATH`.

* [gcc](https://gcc.gnu.org/install/)

* [node.js](https://nodejs.org/en/) 9.3+

### mac

```bash
./prerequisites/mac/all.sh
```

### ubuntu

```bash
./prerequisites/ubuntu/all.sh
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

# Create package

* Install [Bitrock InstallBuilder](https://installbuilder.bitrock.com/)

## Mac

Ensure, that you have artifacts (openvpn, pgsql, tor), located at `$ARTEFACTS_MAC_ZIP_URL`
(`~/artefacts.zip` by default)

To create a package, execute the following script:

### vpn package

```bash
./vpn_mac.sh
```

### proxy package

```bash
./proxy_mac.sh
```

The package will be created at `.bin/installbuilder/out` folder.

#### Options

You can use key `--keep_common_binaries` for prevent build common binaries.

Example:
```bash
./proxy_mac.sh --keep_common_binaries
```
## Ubuntu

To create a package, execute the following script:

### vpn package

```bash
./vpn_ubuntu.sh
```

### proxy package

```bash
./proxy_ubuntu.sh
```

The package will be created at `.bin/installbuilder/out` folder.