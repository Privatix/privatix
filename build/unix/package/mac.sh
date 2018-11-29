#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
cd ..

./build_installer.sh
#./build.sh
