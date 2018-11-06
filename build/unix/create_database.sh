#!/usr/bin/env bash

. ${1}

export POSTGRES_PORT

echo create database

"${DAPPCTRL_DIR}"/scripts/create_database.sh

