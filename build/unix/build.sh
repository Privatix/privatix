#!/usr/bin/env bash

cd `dirname $0`

./clear.sh

git/checkout.sh

./build_dappctrl.sh
./build_dappopenvpn.sh 
./build_dappgui.sh

./create_database.sh 
./create_products.sh 

./start_openvpn.sh 
