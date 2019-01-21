# Tools

## dump_ubuntu.py
The script collects information about dapp environment.

It is include:
* logs
* configs
* database dump
* versions of binaries (dappctrl and dappvpn)

## Installation steps
1. Install PostgreSQL 10 on Ubuntu: https://gist.github.com/alistairewj/8aaea0261fe4015333ddf8bed5fe91f8

## Usage

```
dump_ubuntu.py [relative_path_to_zip_file]
```

### Example of usage:

```
sudo python dump_ubuntu.py
sudo python dump_ubuntu.py some/dump.zip
```

### Result

1. Folder with collected information:
1. Archive of given folder

![](result.jpg)
