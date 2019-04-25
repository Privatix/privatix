#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)"
cd "${root_dir}"
cd ..

. ./build.global.config

cd "${root_dir}"
./pull.sh
./checkout.sh