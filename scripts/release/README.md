# Release scripts

Ordinary release starts with executing the following scripts:

```bash
./start.sh <release_version>
./update_versions.sh
``` 

## start.sh

This script goes through all privatix repositories. 

In repositories, where `master`!=`develop`, it executes:

```bash
git flow release start <release_version>
git flow release publish <release_version>
```


### Example of usage

```bash
./start.sh 0.14.0
```

### Result

```
Modified repositories:

~/Projects/github.com/Privatix/dapp-somc(1)
~/go/src/github.com/privatix/dappctrl(44)
~/go/src/github.com/privatix/dapp-installer(2)
~go/src/github.com/privatix/dapp-openvpn(32)

In these repositories release has been started.
Please, review the changes.


Press any key to push the changes to origin...
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