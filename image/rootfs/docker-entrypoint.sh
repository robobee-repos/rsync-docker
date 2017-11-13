#!/bin/bash
set -e

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
  sed -i -e "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/" /etc/ssh/sshd_config
  sed -i -e 's/#\?Port.*/Port 2222/' /etc/ssh/sshd_config
  sed -i -e 's|#\?PidFile.*|PidFile /run/sshd.pid|' /etc/ssh/sshd_config
  sed -i -e 's|#\?#PermitRootLogin.*|PermitRootLogin prohibit-password|' /etc/ssh/sshd_config
}

source /docker-entrypoint-utils.sh
set_debug
echo "########################"
echo "Running as: `id`"
echo "User: $USER"
echo "Arguments: ${*}"
echo "########################"

if [[ "x$SET_SU" == "x" ]]; then
  su $USER -c /bin/bash -c "export SET_SU=false; /docker-entrypoint.sh ${*}"
fi
copy_files "/ssh-in" "/etc/ssh" "ssh_host_*"
copy_files "/ssh-in" "/etc/ssh" "sshd_config"
patch_sshd
cd "/home/rsync"
exec -- ${BASH_CMD} /init.sh "${@}"
