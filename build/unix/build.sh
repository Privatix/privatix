#!/usr/bin/env bash

./clear.sh

./git/git_checkout.sh ${1}

./build_dappctrl.sh ${1}
./build_dappopenvpn.sh ${1}
./build_dappgui.sh ${1}

./cp_binaries.sh ${1}
./cp_configs.sh.sh ${1}

./create_database.sh ${1}
./create_products.sh ${1}

./start_openvpn.sh ${1}
