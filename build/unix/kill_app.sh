#!/usr/bin/env bash

echo before:
ps
sudo ps

pkill -9 dappvpn
pkill -9 dappctrl

sudo pkill -9 openvpn-inst
sudo pkill -9 openvpn

echo
echo after:
ps
sudo ps