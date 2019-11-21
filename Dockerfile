FROM alpine:3.10.3

LABEL MAINTAINER=<ops@newsletter2go.com>

EXPOSE 22

COPY .docker/ /

RUN chmod 600 -R /root

RUN apk add --no-cache openssh python3 sudo \
  && ln -sf python3 /usr/bin/python \
  && sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
  && echo "root:root" | chpasswd

ENTRYPOINT ["/docker-entrypoint.sh"]