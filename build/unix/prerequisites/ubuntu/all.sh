#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}

sudo apt update

sudo apt install \
    git gcc curl openvpn easy-rsa openssl tor

./install_go.sh
./install_node.sh
./install_nspawn.sh

sudo ./install_postgress.sh