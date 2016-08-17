#!/bin/bash

set -e

function config {
  if [ ! -e /config/cloud.yaml && ! -e /config/backup-config.yaml ]; then
    ruby /generate-config.rb
  fi
}

function compose {
  /usr/bin/docker-compose -f /config/cloud.yaml $1
}

function create {
  compose pull
  compose create
}

function start {
  compose start
  docker cp /config/backup-config.yaml b2-backup:/config.yaml
}

function rm {
  compose stop
  compose rm
  rm -f /config/*
}



case "$1" in
  start)
    start
    ;;
         
  stop)
    compose stop
    ;;
         
  create)
    create
    ;;
         
  rm)
    rm
    ;;

  logs)
    compose logs
    ;;

  *)
    echo $"Usage: $0 {create|start|stop|rm|logs}"
    exit 1

esac
