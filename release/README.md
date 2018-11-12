# Release scripts

Ordinary release starts with executing the following scripts:

```bash
start_release.sh
update_versions.sh
push_release.sh
```

##  Example of usage


```bash
./start_release.sh 
./update_versions.sh 
./push_release.sh 
```

## release.config

This file contains all common variables (eg repositories list), that are used in release scripts:

```
RELEASE_VERSION=0.14.0

DAPP_GUI_DIR=~/Projects/github.com/Privatix/dapp-gui
DAPP_CTRL_DIR=~/go/src/github.com/privatix/dappctrl

REPOSITORIES=(
            ~/Projects/github.com/Privatix/dapp-gui
            ~/Projects/github.com/Privatix/dapp-smart-contract
            ~/Projects/github.com/Privatix/dapp-som
            ~/Projects/github.com/Privatix/privatix

            ~/go/src/github.com/privatix/dappctrl
            ~/go/src/github.com/privatix/dapp-installer
            ~/go/src/github.com/privatix/dapp-openvpn
)

```

Make a copy of `relese.config`:

```bash
cp relese.config relese.local.config
```

Modify `relese.local.config` if you need non-default configuration.


## start_release.sh

This script goes through all privatix repositories. 

In repositories, where `master`!=`develop`, it executes:

```bash
git flow release start <release_version>
```

## push_release.sh

This script goes through all privatix repositories.

In repositories, where current release branch exists, it executes:

```bash
git push origin HEAD
```

## update_versions.sh

This script updates version of the specific repositories.

In `dapp-gui` it executes:

```bash
npm run update_versions
```

In `dappctrl` it executes:

```bash
python ~/go/src/github.com/privatix/dappctrl/scripts/update_versions/update_versions.py
```
