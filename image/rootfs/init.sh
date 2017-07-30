#!/bin/bash
set -ex

function copy_sshd() {
  dir="/ssh-in"
  if [ ! -d "${dir}" ]; then
    return
  fi
  cd "${dir}"
  rsync -u -v /etc/ssh/ssh_host_* ./
}

# First, make sure we have a host key; there are multiple host key
# files, we just check that one of them exists.
if [ ! -e /etc/ssh/ssh_host_rsa_key ]; then
  # See if host keys have been defined in the repositories volume
  HOSTKEY_DIR="/home/rsync/host-keys"
  if [ -e "$HOSTKEY_DIR/ssh_host_rsa_key" ]; then
    echo "Using host key from $HOSTKEY_DIR"
    cp $HOSTKEY_DIR/* /etc/ssh/
  else
    echo "No SSH host keys available. Generating..."
    export LC_ALL=C
    export DEBIAN_FRONTEND=noninteractive
    ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
    ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
    ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa
    ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519
  fi
fi

cd /home/rsync

# If .ssh has been mounted, ensure it has the right permissions
if [ -d ./.ssh ]; then
   chown -R rsync:rsync ./.ssh
else
  CLIENT_DIR="/home/rsync/client"
  # .ssh does not exist; As an alternative, we allow the .ssh/client
  # folder from the repositories volume to be copied.
  if [ -d "$CLIENT_DIR" ]; then
    echo "Copying files from $CLIENT_DIR to /home/rsync/.ssh"
    cp -pr $CLIENT_DIR ./.ssh
  fi
fi

# Always make sure the rsync user has a private key you may
# use for mirroring setups etc.
if [ ! -f ./.ssh/id_rsa ]; then
   ssh-keygen -f /home/rsync/.ssh/id_rsa  -t rsa -N ''
   echo "Here is the public key of the container's 'rsync' user:"
   cat /home/rsync/.ssh/id_rsa.pub
fi

# Support trusting hosts for mirroring setups.
if [ ! -f ./.ssh/known_hosts ]; then
    if [ -n "$TRUST_HOSTS" ]; then
        echo "Generating known_hosts file with $TRUST_HOSTS"
        ssh-keyscan -H $TRUST_HOSTS > /home/rsync/.ssh/known_hosts
    fi
fi

# Allow to specificy "sshd" as a command.
if [ "${1}" = 'sshd' ]; then
  set -- /usr/sbin/sshd -D
fi

copy_sshd
cd "/home/rsync"
echo "Executing $*"
exec $*
