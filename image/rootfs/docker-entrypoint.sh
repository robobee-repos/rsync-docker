#!/bin/bash
set -xe

function create_config() {
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
cd "${RSYNC_ROOT}"
create_config
exec "$@"
