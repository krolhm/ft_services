FROM        alpine:3.12.0

LABEL       maintainer="Raphaël Bourgeat (rbourgea@student.42.fr)"

RUN         apk add --no-cache influxdb telegraf --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community


COPY        srcs/entrypoint.sh /usr/sbin/entrypoint.sh


ENTRYPOINT  ["/usr/sbin/entrypoint.sh"]
