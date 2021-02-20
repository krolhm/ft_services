FROM        alpine:3.12.0

LABEL       maintainer="Raphaël Bourgeat (rbourgea@student.42.fr)"

WORKDIR     /tmp

RUN     apk add --no-cache mysql mysql-client
RUN     apk add --no-cache telegraf --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

COPY        srcs/entrypoint.sh /usr/sbin/entrypoint.sh
COPY        srcs/init_db.sh    /usr/sbin/init_db.sh

ENTRYPOINT ["/usr/sbin/entrypoint.sh"]