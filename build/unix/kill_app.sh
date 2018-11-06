#!/usr/bin/env bash

echo before:
ps
sudo ps

./stop_openvpn.sh

pkill -9 dappvpn
pkill -9 dappctrl

echo
echo after:
ps
sudo ps