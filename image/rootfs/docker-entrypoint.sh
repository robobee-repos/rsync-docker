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

function create_rsync_config() {
  cd "${RSYNC_ROOT}"
  echo "$RSYNC_USERNAME:$RSYNC_PASSWORD" > ${RSYNC_ROOT}/rsyncd.secrets
  chmod 0400 ${RSYNC_ROOT}/rsyncd.secrets
  cat <<EOF > ${RSYNC_ROOT}/rsyncd.conf
pid file = ${RSYNC_ROOT}/rsyncd.pid
log file = /dev/stdout
timeout = 300
max connections = 10
[data]
    hosts deny = *
    hosts allow = ${RSYNC_HOSTS_ALLOW}
    read only = false
    path = ${DATA_DIR}
    comment = data directory
    auth users = $RSYNC_USERNAME
    secrets file = ${RSYNC_ROOT}/rsyncd.secrets
    lock file = ${RSYNC_ROOT}/rsyncd.lock
    use chroot = false
EOF
}

echo "Running as `id`"
copy_sshd
patch_sshd
create_rsync_config
cd "/home/rsync"
exec /init.sh "$@"
