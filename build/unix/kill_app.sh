#!/usr/bin/env bash

echo before:
ps

pkill -9 dappvpn
pkill -9 dappctrl

echo
echo after:
ps