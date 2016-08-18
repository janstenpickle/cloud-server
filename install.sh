#!/bin/sh

TARGET="/usr/local/bin/cloud-server"

curl -o $TARGET https://raw.githubusercontent.com/janstenpickle/cloud-server/master/cloud-server

chmod +x $TARGET
