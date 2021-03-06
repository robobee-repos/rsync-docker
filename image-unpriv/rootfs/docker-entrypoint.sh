#!/bin/bash
set -e
if [[ "x${DEBUG_SCRIPTS}" == "xtrue" ]]; then
  set -x
fi

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
  sed -i -e "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/" /etc/ssh/sshd_config
  sed -i -e 's/#\?Port.*/Port 2222/' /etc/ssh/sshd_config
  sed -i -e 's|#\?PidFile.*|PidFile /run/ssh/sshd.pid|' /etc/ssh/sshd_config
  sed -i -e 's|#\?#PermitRootLogin.*|PermitRootLogin prohibit-password|' /etc/ssh/sshd_config
}

# Generate passwd file based on current uid
function generate_passwd_file() {
  USER_ID=$(id -u)
  GROUP_ID=$(id -g)

  if [ x"$USER_ID" != x"0" -a x"$USER_ID" != x"200" ]; then

    echo "default:x:${USER_ID}:${GROUP_ID}:Default Application User:${HOME}:/sbin/nologin" >> /etc/passwd

  fi
}

echo "Running as: `id`"
echo "User: $USER : `id $USER`"
echo "Arguments: ${*}"
ls -al /etc/ssh/
ls -al /etc/passwd
if [[ "x$SET_SU" == "x" ]]; then
  su $USER -c /bin/bash -c "export SET_SU=false; /docker-entrypoint.sh ${*}"
fi
copy_sshd
patch_sshd
generate_passwd_file
cd "/home/rsync"
exec /init.sh "${@}"
