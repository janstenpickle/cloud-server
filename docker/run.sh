#!/bin/bash

set -e

if [ ! -e /config/cloud.yaml ] && [ ! -e /config/backup-config.yaml ]; then
  echo "Please enter your configuration"
  ruby /generate-config.rb
fi

function compose {
  /usr/bin/docker-compose -f /config/cloud.yaml $@
}

function is_running {
  if [ "$(compose ps -q | wc -l)" != "0" ]; then
    echo "true"
  else
    echo "false"
  fi
}

function update {
  compose pull
}

function start {
  if [ $(is_running) = "true" ]; then
    echo "Containers are already running:"
    compose ps
    exit 1
  else
    compose up -d
    docker cp /config/backup-config.yaml b2-backup:/config.yaml
  fi
}

function stop {
  if [ $(is_running) = "true" ]; then
    compose down
  else
    echo "No containers currently running"
    exit 1
  fi
}

case "$1" in
  start)
    start
    ;;

  stop)
    stop
    ;;

  update)
    update 
    ;;

  logs)
    compose logs
    ;;

  status)
    compose ps
    ;;

  *)
    echo $"Invalid input $@"
    echo $"Usage: $0 {create|start|stop|logs|status}"
    exit 1

esac
