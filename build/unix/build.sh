#!/usr/bin/env bash

cd `dirname $0`

./git/checkout.sh

./build_ctrl.sh
./build_openvpn.sh
./build_gui.sh

./create_database.sh 
./create_products.sh 

./start_openvpn.sh