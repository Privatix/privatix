#!/usr/bin/env bash

mkdir -p "./bin"

./git/git_checkout.sh ${1}

./build_backend.sh ${1}
./build_gui.sh ${1}

./prepare_openvpn.sh