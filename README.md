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
| RSYNC_USERNAME | rsync | User name to access the data directory. |
| RSYNC_PASSWORD | rsync | Password to access the data directory. |
| RSYNC_HOSTS_ALLOW | * | List of hosts that are allowed to connect to the rsync daemon. |
| DATA_DIR | /data | Path of the data directory. |

## Exposed Ports

| Port | Description |
| ------------- | ----- |
| 8873  | rsync |

## Directories

| Path | Description |
| ------------- | ----- |
| /data | Reserved data directory. |

## Test

The docker-compose file `test.yaml` can be used to startup the rsync daemon 
container. The rsync daemon will be available at `localhost:8873`.

```
docker-compose -f test.yaml up
```

Alternatifly, the `make` utility can be used to start a test container.

```
make up
```

To test the rsync daemon container.

```
rsync -rv rsync://host:8873/data/. .
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
