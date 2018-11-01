#!/usr/bin/env bash

. ${1}

linux/git/git_clone.sh ${1}
linux/git/git_checkout.sh ${1}

linux//build.sh ${1}