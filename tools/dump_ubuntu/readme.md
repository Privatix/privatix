# Tools

## dump_ubuntu.sh

The script collects information about dapp environment.

It is include:
* logs
* configs
* database dump
* versions of binaries (dappctrl and dappvpn)

## Usage

```
dump_ubuntu.sh [privatix_app_folder_path]
```

### Example of usage:

```
./dump_ubuntu.sh
./dump_ubuntu.sh /opt/Privatix
```

### Result

1. Folder with collected information
1. Archive of given folder

Default dump location: `/opt/Privatix`
