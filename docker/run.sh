#!/bin/bash

set -e

CONFIG="/config/cloud.yaml"
BACKUP_CONFIG="/config/backup-config.yaml"

function compose {
  /usr/bin/docker-compose -f $CONFIG $@
}

function is_running {
  if [ "$(compose ps -q | wc -l)" != "0" ]; then
    echo "true"
  else
    echo "false"
  fi
}

function copy_backup_config {
  B2_CONF="/config/backup_config.yaml"
  if [ -e $B2_CONF ]; then
    docker cp /config/backup-config.yaml b2-backup:/config.yaml
  fi
}

if [ ! -e $CONFIG ] && [ ! -e $BACKUP_CONFIG ]; then
  echo "Please enter your configuration"
  ruby /generate-config.rb

  if [ $(is_running) = "true" ]; then
    copy_backup_config
  fi
fi

DATA_DIR=$(cat /config/data_dir)

function write_file {
  cat $1 | docker run --rm -v $DATA_DIR:$DATA_DIR -i alpine /bin/sh -c "cat - > ${DATA_DIR}/$2"
}

function update {
  compose pull
}

function copy_nginx_config {
  write_file /nginx.conf "nginx.conf"
}

function copy_rsync_config {
  AUTH_KEYS="/config/rsync_authorized_keys"
  if [ -e $AUTH_KEYS ]; then
    write_file $AUTH_KEYS authorized_keys
  fi
}

function join_zt_network {
  ZT_NET="/config/zerotier_network"
  if [ -e $ZT_NET ]; then
    docker exec zerotier-one /zerotier-cli join $(cat $ZT_NET)
  fi
}

function start {
  if [ $(is_running) = "true" ]; then
    echo "Containers are already running:"
    compose ps
    exit 1
  else
    copy_nginx_config
    copy_rsync_config
    compose up -d
    copy_backup_config
    join_zt_network
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

function show_config {
  for CONFIG_FILE in $(ls /config); do
    echo $CONFIG_FILE:
    cat /config/$CONFIG_FILE
    echo
    echo
  done
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

  show_config)
    show_config
    ;;

  *)
    echo $"Invalid input $@"
    echo $"Usage: $0 {create|start|stop|logs|status|show_config}"
    exit 1

esac
