#!/usr/bin/env bash

cd `dirname $0`


if [[ ! -d "${GOPATH}/bin/" ]]; then
    mkdir "${GOPATH}"/bin/
fi

./git/update.sh

./build_ctrl.sh
./build_openvpn.sh
./build_gui.sh

./create_database.sh 
./create_products.sh 

# in case of agent build
#./run_openvpn.sh