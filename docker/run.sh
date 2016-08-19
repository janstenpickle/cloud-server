#!/bin/bash

set -e

function copy_backup_config {
  docker cp /config/backup-config.yaml b2-backup:/config.yaml
}

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
    copy_backup_config
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

if [ ! -e /config/cloud.yaml ] && [ ! -e /config/backup-config.yaml ]; then
  echo "Please enter your configuration"
  ruby /generate-config.rb

  if [ $(is_running) = "true" ]; then
    copy_backup_config
  fi
fi

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
