#!/bin/bash

CMD="docker run -it --name cloud-server -v /var/run/docker.sock:/var/run/docker.sock janstenpickle/cloud-server"

$CMD create
