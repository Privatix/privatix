#!/usr/bin/env bash

cd `dirname $0`
. ./build.config

export POSTGRES_PORT

echo create database

"${DAPPCTRL_DIR}"/scripts/create_database.sh

