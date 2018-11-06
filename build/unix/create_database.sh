#!/usr/bin/env bash

. ${1}

export POSTGRES_PORT

echo create database

"${DAPPCTRL_DIR}"/scripts/create_database.sh

./bin/dapp-openvpn-inst \
 -rootdir=./bin/dapp_openvpn/ \
 -connstr="dbname=dappctrl host=localhost user=postgres \
  sslmode=disable port=${POSTGRES_PORT}" -setauth