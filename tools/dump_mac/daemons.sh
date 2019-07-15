#!/usr/bin/env bash

echo
echo launchctl
echo

launchctl list | grep -i privatix

echo
echo sudo launchctl
echo

sudo launchctl list | grep -i privatix

echo
echo LaunchAgents
echo

ls ~/Library/LaunchAgents | grep -i privatix

echo
echo LaunchDaemons
echo

ls /Library/LaunchDaemons | grep -i privatix