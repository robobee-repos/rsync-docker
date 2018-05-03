# Rsync

## What is Rsync?

Home page: https://rsync.samba.org/

> "rsync is an open source utility that provides fast incremental file transfer. rsync is freely available under the GNU General Public License and is currently being maintained by Wayne Davison."

## Description

The image includes the rsync daemon and configures a separate data directory. The rsync daemon can be used to backup the data of volumes in the Kubernetes cluster.

## Environment Parameters

| Variable | Default | Description |
| ------------- | ------------- | ----- |
| `RSYNC_AUTHORIZED_KEY` | | Ssh public key that will be added to the authorized keys. |
| `RSYNC_SSH_PORT` | 2222 | Ssh port. |
| `RSYNC_STRICT_HOST_KEY_CHECKING_NO` | false | Set to true to disable strict host checking for connections. |
| `TRUST_HOSTS` | | Hosts that will be added to the known hosts. |
| `DATA_DIR` | `/data` | Path of the data directory. |

## Exposed Ports

| Port | Description |
| ----- | ----- |
| `2222`  | ssh |

## Directories

| Path | Description |
| ------------- | ----- |
| `/data` | Reserved data directory. |

## Input Configration

| Source | Destination | Description |
| ------------- | ------------- | ----- |
| `/keys-in/*pub` |  | Keys are added to the authorized keys. |
| `/ssh-in/ssh_host_*` | /etc/ssh/ |  |
| `/ssh-in/sshd_config` | /etc/ssh/ | OpenSSH server configuration. |

## Usage

### Basic

OpenSSH server will be started and accepts connections on port `2222`. The user can connect to the server using the specified keys and use rsync to backup or restore files.

If deployed on Kubernetes, the service can be exposed via NodePort.

```
kubectl expose deploy rsync --type=NodePort --name=rsync-public
rsync -r -v rsync@node:/data/\* /tmp/
```

### Use Tunnel

If the NodePort is blocked or if used behind a firewall a tunnel can be created to the node. For that the most confortable method is to create a `config` file for a fake host `rsync-host`. The fake host must be added to the `hosts` file.

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

The docker-compose file `test.yaml` can be used to startup the ssh daemon container. The ssh daemon will be available at `localhost:2222`.

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

This image is licensed under the [MIT](https://opensource.org/licenses/MIT) license.

Copyright 2017 Erwin Müller

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
