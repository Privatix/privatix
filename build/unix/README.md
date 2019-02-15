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

## Update Repositories

To update all required repositories, execute the following script:

```bash
./git/update.sh
```

## One-command create package

* Install [Bitrock InstallBuilder](https://installbuilder.bitrock.com/)

Ensure, that you have artifacts (openvpn, pgsql, tor), located at `$ARTEFACTS_ZIP_URL`
(`~/artefacts.zip` by default)

### Mac

To create a package, execute the following script:

```bash
./package/mac.sh
```

The package will be created at `.bin/installbuilder/out` folder.

### Ubuntu

To create a package, execute the following script:

```bash
./package/ubuntu.sh
```

The package will be created at `.bin/installbuilder/out` folder.

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
