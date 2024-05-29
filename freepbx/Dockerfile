# Используем официальный образ Debian как базовый
FROM asterisk:0.1.3 AS builder

# Устанавливаем необходимые пакеты
RUN apk update && \
    apk add --repository http://dl-cdn.alpinelinux.org/alpine/3.14/community \
      build-base \
      wget \
      mariadb \
      curl \
      php7 \
      php7-cli \
      php7-common \
      php7-curl \
      php7-fpm \
      php7-gd \
      php7-gettext \
      php7-imap \
      php7-json \
      php7-ldap \
      php7-mbstring \
      php7-mysqli \
      php7-xml \
      php7-zip \
      php7-simplexml \
      php7-posix \
      php7-pdo \
      php7-pdo_mysql\
      php7-phar \
      php7-sysvsem \
      musl-locales \
      gnupg \
      php7-session \
      findutils \
      runuser \
      mariadb-client \
      # we need it?
      busybox-suid \
      bash && \
    rm -rf /var/cache/apk/*


## PBX HELL HERE
WORKDIR /usr/src 
RUn curl -fsSL https://unofficial-builds.nodejs.org/download/release/v18.16.0/node-v18.16.0-linux-x64-musl.tar.xz -o node.tar.xz \
    && tar -xf node.tar.xz -C /usr/local --strip-components=1 \
    && rm node.tar.xz 
RUN wget http://mirror.freepbx.org/modules/packages/freepbx/7.4/freepbx-16.0-latest.tgz && \
tar xfz freepbx-16.0-latest.tgz  && ln -s freepbx-16.0 freepbx
WORKDIR /usr/src/freepbx

COPY dbhelper.sh .
COPY pbx.sh .
COPY clear.sh .

RUN /usr/sbin/safe_asterisk & sleep 1 && \ 
    bash pbx.sh && \
    bash dbhelper.sh && \
    ./install -n --dbuser=root --dbpass=123123 && \
  fwconsole ma enablerepo extended  && \
    fwconsole setting MODULE_REPO "http://mirror1.freepbx.org,http://mirror2.freepbx.org" && \
    fwconsole ma upgradeall && \
    fwconsole ma install core && \
    fwconsole ma install framework && \
    fwconsole ma downloadinstall \
      api \
      paging \
      parking \
      queueprio \
      weakpasswords \
      callwaiting \
      languages \
      findmefollow \
      backup \
      bulkhandler \
      queues \
      ringgroups \
      timeconditions \
      ivr \
      cel \
      configedit \
      asteriskinfo \
      certman \
      ucp \
      webrtc \
      sipsettings \
      announcement \
      blacklist  && \
    fwconsole ma installlocal && \
    fwconsole ma download customcontexts && \
    fwconsole ma install customcontexts && \
    fwconsole chown && \
    fwconsole  setting SIGNATURECHECK 0 && \
    bash clear.sh && \
    mysqldump -u root -p123123 asterisk > /opt/dump.sql && \
    mysqldump -u root -p123123 asteriskcdrdb > /opt/dumpcdr.sql && \
    rm -rf /usr/src/* /var/www/html/admin/modules/_cache/*

FROM alpine:3.14 
#
WORKDIR /opt/

RUN apk add --repository http://dl-cdn.alpinelinux.org/alpine/3.14/community \
  php7 \
  php7-cli \
  php7-common \
  php7-curl \
  php7-fpm \
  php7-gd \
  php7-gettext \
  php7-imap \
  php7-json \
  php7-ldap \
  php7-mbstring \
  php7-mysqli \
  php7-xml \
  php7-zip \
  bash \
  mariadb-client  \
  php7-simplexml \
  php7-posix \
  runuser   \
  php7-pdo \
  php7-pdo_mysql \
  php7-sysvsem  \
  musl-locales  \
  gnupg \
  php7-session \
  findutils \
  php7-phar  \
  netcat-openbsd \
  curl && \
    rm -rf /var/cache/apk/*

# nodejs
WORKDIR /opt/
RUn curl -fsSL https://unofficial-builds.nodejs.org/download/release/v18.16.0/node-v18.16.0-linux-x64-musl.tar.xz -o node.tar.xz \
    && tar -xf node.tar.xz -C /usr/local --strip-components=1 \
    && rm node.tar.xz 

ARG UID=10002
ENV ASTSAFE_FOREGROUND=1
RUN addgroup -S asterisk -g "${UID}" && \
    adduser -S asterisk -G asterisk -u "${UID}" -h /var/lib/asterisk && \
    addgroup asterisk audio && \
    addgroup asterisk dialout

COPY --chown=asterisk:asterisk --from=builder /etc/freepbx.conf /etc/freepbx.conf
COPY --chown=asterisk:asterisk --from=builder /etc/asterisk  /etc/asterisk
COPY --chown=asterisk:asterisk --from=builder /var/www/html  /var/www/html

## db duimps
COPY --chown=asterisk:asterisk --from=builder /opt/dump.sql  /opt/dump.sql
COPY --chown=asterisk:asterisk --from=builder /opt/dumpcdr.sql  /opt/dumpcdr.sql
## binaries
COPY --chown=asterisk:asterisk --from=builder /usr/sbin/fwconsole /usr/sbin/fwconsole
COPY --chown=asterisk:asterisk --from=builder /var/spool/asterisk /var/spool/asterisk
COPY --chown=asterisk:asterisk --from=builder /var/log/asterisk /var/log/asterisk
COPY --chown=asterisk:asterisk --from=builder /usr/sbin/asterisk_cli /usr/sbin/asterisk

RUN sed -i 's/group = nobody/group = asterisk/g' /etc/php7/php-fpm.d/www.conf && \
  sed -i 's/user = nobody/user = asterisk/g' /etc/php7/php-fpm.d/www.conf && \ 
  sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/g' /etc/php7/php-fpm.d/www.conf && \
  sed -i 's/;listen.owner = nobody/listen.owner = asterisk/g' /etc/php7/php-fpm.d/www.conf && \
  sed -i 's/;listen.group = nobody/listen.group = asterisk/g' /etc/php7/php-fpm.d/www.conf && \
  sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php7/php-fpm.d/www.conf && \
  sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php7/php-fpm.conf
#
COPY prelaunch.sh .
COPY logging.conf /etc/php7/php-fpm.d/
COPY temp.sql /opt/
COPY --chown=asterisk:asterisk manager.conf /etc/asterisk/
expose  9000
#
ENTRYPOINT ["./prelaunch.sh"]
