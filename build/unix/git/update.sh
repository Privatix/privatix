#!/usr/bin/env bash

cd `dirname $0`
. ../build.local.config

./pull.sh
./checkout.sh