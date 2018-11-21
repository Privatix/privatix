#!/usr/bin/env bash

cd `dirname $0`
. ./build.local.config

export POSTGRES_PORT
export POSTGRES_USER
export POSTGRES_PASSWORD

echo create database

"${DAPPCTRL_DIR}"/scripts/create_database.sh

