# Build the Privatix Application

## Install Prerequisites

Install prerequisite software if it's not installed.

* [git](https://git-scm.com/downloads)

* [Golang](https://golang.org/doc/install) 1.11+. Make sure that 
`$GOPATH/bin` is added to system path `$PATH`.

* [PostgreSQL](https://www.postgresql.org/download/)

* [gcc](https://gcc.gnu.org/install/)

* [npm](https://www.npmjs.com/) 5.6+

* [node.js](https://nodejs.org/en/) 9.3+


## Linux/Mac

### Clone required repositories

To clone all required repositories, execute the following script:

```bash
./git/clone.sh
```

Repositories paths are located here: [build.config](unix/build.config)

### Build 

```bash
./unix/build.sh
```

### Run Agent

```bash
./unix/run_agent.sh
```

### Run Client

```bash
./unix/run_client.sh
```

### Documentation

More information about unix build:
[unix/README.md](unix/README.md)

## Windows

### Build

```bash
cd win
publish-dapp
```

### Run 

```bash
```

### Documentation

[win/README.md](win/README.md)
