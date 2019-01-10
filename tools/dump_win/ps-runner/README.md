# Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

## Prerequisites

Install [Golang](https://golang.org/doc/install). Make sure that `$GOPATH/bin` is added to system path `$PATH`.

## Installation steps

Clone the `privatix` repository using git:

```bash
git clone https://github.com/Privatix/privatix.git
cd privatix/tools/dump-win/ps-runner

go get -d github.com/privatix/privatix/tools/dump-win/ps-runner...
go get -u github.com/josephspurrier/goversioninfo/cmd/goversioninfo
go generate ./...

go build
```

## Usage

Simply run `ps-runner -config filename` or `ps-runner -script filename [args...]`

### Examples

Run powershell script with arguments:

```
ps-runner -script new-dump.ps1 -installDir "C:\Program Files\Privatix"
```

Run powershell script using configuration file:

```
ps-runner -config ps-runner.config.json
```
