FROM debian:stretch-slim
LABEL maintainer "Erwin Mueller <erwin.mueller@deventm.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV RSYNC_ROOT /var/rsync
ENV RSYNC_USERNAME rsync
ENV RSYNC_PASSWORD rsync
ENV RSYNC_HOSTS_ALLOW "*"
ENV DATA_DIR /data
ARG APT_CACHE

RUN set -x \
  # Optional add proxy entries for apt.
  && if [ -n "${APT_CACHE}" ]; then \
  echo Acquire::ftp::Proxy \"$APT_CACHE\"; >> /etc/apt/apt.conf.d/08proxy;\
  echo Acquire::http::Proxy \"$APT_CACHE\"; >> /etc/apt/apt.conf.d/08proxy;\
  echo Acquire::https::Proxy \"$APT_CACHE\"; >> /etc/apt/apt.conf.d/08proxy;\
  fi

RUN set -x \
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
  rsync \
  && rm -rf /var/lib/apt/lists/*

# Root and data directory

RUN set -x \
  && mkdir -p ${RSYNC_ROOT} \
  && chmod o+w ${RSYNC_ROOT} \
  && mkdir -p ${DATA_DIR}

VOLUME ${DATA_DIR}

# Rsync port.

EXPOSE 8873

# Finishing up.

ADD rootfs/docker-entrypoint.sh /docker-entrypoint.sh

RUN set -x \
  && chmod +x /docker-entrypoint.sh

USER root

WORKDIR ${RSYNC_ROOT}

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/bin/rsync", "--no-detach", "--daemon", "--port=8873", "--config", "/var/rsync/rsyncd.conf"]
