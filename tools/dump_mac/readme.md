# Tools

## dump_mac.py

The script collects information about dapp environment.

It is include:
* logs
* configs
* database dump
* versions of binaries (dappctrl and dappvpn)

## Usage

```
dump_mac.sh [privatix_app_folder_path]
```

### Example of usage:

```
./dump_mac.sh
./dump_mac.sh /Applications/Privatix
```

### Result

1. Folder with collected information
1. Archive of given folder

Default dump location: `/Applications/Privatix/dump`
