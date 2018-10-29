#!/usr/bin/env bash

DAPP_GUI_DIR=~/Projects/github.com/Privatix/dapp-gui
DAPP_CTRL_DIR=~/go/src/github.com/privatix/dappctrl

update_dapp_gui(){
    cd ${DAPP_GUI_DIR}
    release_branch=$(git branch | grep release | sort | tail -1)
    git checkout ${release_branch}
    npm run update_versions
}

update_dappctrl(){
    cd ${DAPP_CTRL_DIR}
    release_branch=$(git branch | grep release | sort | tail -1)
    git checkout ${release_branch}
    python ~/go/src/github.com/privatix/dappctrl/scripts/update_versions/update_versions.py
}

push_changes(){
    cd ${DAPP_GUI_DIR}
    git push origin HEAD

    cd ${DAPP_CTRL_DIR}
    git push origin HEAD
}

update_dapp_gui
update_dappctrl

echo  "Press any key to push changes to origin..."
read

push_changes