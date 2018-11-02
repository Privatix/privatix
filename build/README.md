# Prerequisites

Install prerequisite software if it's not installed.

* Install [Golang](https://golang.org/doc/install) 1.11+. Make sure that `$GOPATH/bin` is added to system path `$PATH`.

* Install [PostgreSQL](https://www.postgresql.org/download/).

* Install [gcc](https://gcc.gnu.org/install/).

* Install [OpenVPN](https://openvpn.net/get-open-vpn/) 2.4+.

## Linux build

```bash
./build_linux.sh build.config
```

[Documentation](linux/README.md)


## Mac build

```bash
./build_mac.sh build.config
```
[Documentation](mac/README.md)

## Windows build

```bash
./build_win.cmd build.config
```

[Documentation](win/README.md)