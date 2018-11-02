#!/usr/bin/env bash

. ${1}

build_gui(){
    echo build_gui
}

./build_backend.sh ${1}

build_dapp_gui