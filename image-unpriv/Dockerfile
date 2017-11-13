FROM erwin82/rsync:v2
LABEL maintainer "Erwin Mueller <erwin.mueller@deventm.com>"

ADD rootfs/docker-entrypoint.sh /docker-entrypoint.sh

RUN set -x \
  && chmod +x /docker-entrypoint.sh \
  && chmod g+rwX -R /etc/ssh \
  && chmod g+rw /etc/passwd \
  && chmod g+rwX /home/rsync \
  && mkdir -p /run/ssh \
  && chmod g+rwX /run/ssh

USER rsync
