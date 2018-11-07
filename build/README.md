# Build the Privatix Application

## Install Prerequisites

Install prerequisite software if it's not installed.

* [Golang](https://golang.org/doc/install) 1.11+. Make sure that 
`$GOPATH/bin` is added to system path `$PATH`.

* [PostgreSQL](https://www.postgresql.org/download/)

* [gcc](https://gcc.gnu.org/install/)

* [npm](https://www.npmjs.com/) 5.6+

* [node.js](https://nodejs.org/en/) 9.3+

## Prepare Build Config

Config is located here: [build.config](build.config)

## Linux/Mac

### Clone Required Repositories

To clone all required repositories, execute the following script:

```bash
cd unix && ./git/git_clone.sh ../build.config 
```

### Update Repositories

To update all required repositories, execute the following script:

```bash
cd unix && ./git/git_pull.sh ../build.config 
```

### Build 

```bash
cd unix && ./build.sh ../build.config
```

### Run Agent

```bash
cd unix && ./run_agent.sh
```

### Run Client

```bash
cd unix && ./run_client.sh
```

### Documentation

[nix/README.md](unix/README.md)

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
