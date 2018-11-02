#!/usr/bin/env bash

echo "Coming soon"

./mac/git/git_clone.sh ${1}
./mac/git/git_checkout.sh ${1}

./mac/build.sh ${1}