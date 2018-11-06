#!/usr/bin/env bash

. ${1}

echo run dappctrl
./bin/dappctrl -config="./bin/dappctrl.client.config.json" &

echo run dapp-gui
cd ${DAPP_GUI_DIR}
npm start &

sleep 3
jobs -l