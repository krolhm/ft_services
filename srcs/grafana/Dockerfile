FROM        alpine:3.12.0

LABEL       maintainer="Raphaël Bourgeat (rbourgea@student.42.fr)"

WORKDIR     /tmp


RUN         apk add --no-cache grafana telegraf --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community


COPY        srcs/grafana.db /usr/share/grafana/data/grafana.db
COPY        srcs/entrypoint.sh /usr/sbin/entrypoint.sh

ENTRYPOINT  ["/usr/sbin/entrypoint.sh"]
