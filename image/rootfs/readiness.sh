#!/bin/bash
set -e

SOURCE="$1"; shift

home_dir=/home/rsync/.ssh
if [[ "`id -u`" == "0" ]]; then
  home_dir="/root/.ssh"
fi

cd $home_dir

if [ ! -e known_hosts ]; then
  ssh-keyscan -p 2222 -H localhost > known_hosts
fi

rsync -v $USER@localhost:$SOURCE /tmp/
