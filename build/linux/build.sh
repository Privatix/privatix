#!/usr/bin/env bash

git clone https://github.com/Privatix/dappctrl.git
cd dappctrl
git checkout master

/scripts/build.sh
/scripts/create_database.sh