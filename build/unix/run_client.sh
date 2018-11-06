#!/usr/bin/env bash

. ${1}


cd ../../
echo prepare dappctrl config
cp "${DAPPCTRL_DIR}"/dappctrl-dev.config.json \
    ./bin/dappctrl.config.json

echo run dappctrl
dappctrl -config="./bin/dappctrl.config.json" &

echo run dapp-gui
cd ${DAPP_GUI_DIR}
npm start &

sleep 3
jobs -l