#!/usr/bin/env bash

sudo add-apt-repository ppa:longsleep/golang-backports
sudo apt-get update
sudo apt-get install golang-go

mkdir -p ~/go
mkdir -p ~/go/bin

echo "export GOPATH=$HOME/go" >> ~/.bashrc
echo "export PATH=$PATH:$HOME/go/bin" >> ~/.bashrc

source ~/.bashrc

echo "GOPATH is: $GOPATH"
echo "PATH is: $PATH"
echo "GO version installed: $(go version)"