#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}

sudo apt update

sudo apt install \
    git curl

./install_go.sh
./install_node.sh
./install_nspawn.sh