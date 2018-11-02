#!/usr/bin/env bash

. ${1}

echo Start dapp-gui build

cd "${DAPP_GUI_DIR}"

npm install
npm run build