#!/bin/bash
set -xe

function check_files_exists() {
  ls $1 1> /dev/null 2>&1
}

function copy_file() {
  file="$1"; shift
  dir="$1"; shift
  mod="$1"; shift
  if [ -e "$file" ]; then
    cp "$file" $dir/"$file"
    chmod $mod $dir/"$file"
  fi
}

function copy_sshd() {
  dir="/ssh-in"
  if [ ! -d "${dir}" ]; then
    return
  fi
  cd "${dir}"
  if check_files_exists "ssh_host_*"; then
    rsync -u -v ssh_host_* /etc/ssh/
  fi
  if check_files_exists "sshd_config"; then
    rsync -u -v sshd_config /etc/ssh/
  fi
}

function patch_sshd() {
  sed -i -e "s/UsePrivilegeSeparation yes/UsePrivilegeSeparation no/" /etc/ssh/sshd_config
  sed -i -e 's/#\?Port\s*[[:digit:]]*/Port 2222/' /etc/ssh/sshd_config
}

echo "Running as `id`"
copy_sshd
patch_sshd
cd "/home/rsync"
exec /init.sh "$@"
