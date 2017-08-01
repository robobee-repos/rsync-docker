# Rsync-Docker

## What is Rsync?

Home page: https://rsync.samba.org/

> "rsync is an open source utility that provides fast incremental file transfer. 
rsync is freely available under the GNU General Public License and is currently 
being maintained by Wayne Davison."

## Description

The image includes the rsync daemon and configures a separate data directory. 
The rsync daemon can be used to backup the mounted data directory.

## Environment Parameters

| Variable | Default | Description |
| ------------- | ------------- | ----- |
| RSYNC_AUTHORIZED_KEY | | Ssh public key that will be added to the authorized keys. |
| TRUST_HOSTS | | Hosts that will be added to the known hosts. |
| DATA_DIR | /data | Path of the data directory. |

## Exposed Ports

| Port | Description |
| ----- | ----- |
| 2222  | ssh |

## Directories

| Path | Description |
| ------------- | ----- |
| /data | Reserved data directory. |

## Input Configration

| Source | Destination | Description |
| ------------- | ------------- | ----- |
| /keys-in/*pub |  | Keys are added to the authorized keys. |
| /ssh-in/ssh_host_* | /etc/ssh/ |  |
| /ssh-in/sshd_config | /etc/ssh/ | OpenSSH server configuration. |

## Usage

### Basic

OpenSSH server will be started and accepts connections on port 2222. The
user can connect to the server using the specified keys and use rsync
to backup or restore files.

If deployed on Kubernetes, the service can be exposed via NodePort.

```
kubectl expose deploy rsync --type=NodePort --name=rsync-public
rsync -r -v rsync@node:/data/\* /tmp/
```

### Use Tunnel

If the NodePort is blocked or if used behind a firewall a tunnel can be created
to the node. For that the most confortable method is to create a `config` file
for a fake host `rsync-host`. The fake host must be added to the `hosts` file.

* `/etc/hosts`

```
127.1.1.1 rsync-host
```

* `~/.ssh/config`

```
Host rsync-host
Hostname 127.1.1.1
Port 31233
User rsync
IdentityFile rsyncssh_id_rsa
ProxyCommand ssh user@node nc %h %p
```

## Test

The docker-compose file `test.yaml` can be used to startup the ssh daemon 
container. The ssh daemon will be available at `localhost:2222`.

```
docker-compose -f test.yaml up
```

Alternatifly, the `make` utility can be used to start a test container.

```
make up
```

To test the rsync daemon container.

```
rsync -rv rsync@localhost:2222/data/. .
```

## License

rsync is published under the [GPL](https://rsync.samba.org/GPL.html)

Copyright 2017 Erwin Müller

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
