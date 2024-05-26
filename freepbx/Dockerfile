# Используем официальный образ Debian как базовый
FROM asterisk:0.0.12 AS builder

# Устанавливаем необходимые пакеты
RUN apt-get update && apt-get install -y --no-install-recommends  \
    build-essential \
    wget \
    mariadb-server \
    lsb-release ca-certificates curl

COPY  phphelper.sh  .
RUN bash phphelper.sh

RUN apt-get update && apt-get install -y --no-install-recommends  \
    php7.4 php7.4-mysql php7.4-cli php7.4-common php7.4-imap php7.4-ldap php7.4-xml php7.4-fpm php7.4-curl php7.4-mbstring php7.4-zip php7.4-gd php7.4-gettext php7.4-xml php7.4-json \
    cron

# PBX HELL HERE
WORKDIR /usr/src 
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs
RUN wget http://mirror.freepbx.org/modules/packages/freepbx/7.4/freepbx-16.0-latest.tgz && \
tar xfz freepbx-16.0-latest.tgz  && ln -s freepbx-16.0 freepbx
WORKDIR /usr/src/freepbx
COPY  dbhelper.sh  .
COPY  phphelper.sh  .
RUN bash phphelper.sh
##  php -hell
ARG UID=10002
#RUN groupadd asterisk -g "${UID}" && useradd -u "${UID}" -r -d /var/lib/asterisk -g asterisk asterisk && usermod -aG audio,dialout asterisk  && chown -R asterisk:asterisk /etc/asterisk  /var/lib/asterisk  /var/lib/run/asterisk

COPY asterisk.conf /etc/asterisk/asterisk.conf

COPY pbx.sh  .

RUN /usr/sbin/safe_asterisk & sleep 1 &&  \ 
    bash pbx.sh && \
    bash dbhelper.sh && \
    ./install -n --dbuser=root --dbpass=123123 
#&& \
#    echo fwconsole setting MODULE_REPO ${MODULE_REPO} && \
COPY clear.sh clear.sh
RUN /usr/sbin/safe_asterisk  & sleep 1 &&  \
  mariadbd --user root  & sleep 15 && fwconsole ma enablerepo extended  && \
  fwconsole setting MODULE_REPO "http://mirror1.freepbx.org,http://mirror2.freepbx.org" && \
  fwconsole ma upgradeall && \
  fwconsole ma install core && \
  fwconsole ma install framework && \
  # asterisk -G asterisk -U asterisk -C /etc/asterisk/asterisk.conf & sleep 6 && \
  fwconsole ma downloadinstall api paging parking queueprio weakpasswords callwaiting languages findmefollow backup bulkhandler queues ringgroups timeconditions ivr cel configedit asteriskinfo certman ucp webrtc sipsettings announcement blacklist  && \
  fwconsole ma installlocal && \
  fwconsole ma download customcontexts &&\
  fwconsole ma install customcontexts &&\
  fwconsole chown --verbose &&\
  fwconsole  setting SIGNATURECHECK 0 &&\
  bash clear.sh

RUN mariadbd --user root & sleep 15 && \
  mysqldump -u root -p123123 asterisk > /opt/dump.sql && \
  mysqldump -u root -p123123 asteriskcdrdb > /opt/dumpcdr.sql

FROM debian:12.5-slim

WORKDIR /opt/
RUN apt-get update && apt-get install -y --no-install-recommends  \
    wget \
    lsb-release ca-certificates curl

COPY phphelper.sh  .
RUN bash phphelper.sh && rm phphelper.sh
RUN apt-get update && apt-get install -y --no-install-recommends  \
    php7.4 php7.4-mysql php7.4-cli php7.4-common php7.4-imap php7.4-ldap php7.4-xml php7.4-fpm php7.4-curl php7.4-mbstring php7.4-zip php7.4-gd php7.4-gettext php7.4-xml php7.4-json \
    cron netcat-traditional  mariadb-client \
    vim

# PBX HELL HERE
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*

ARG UID=10002
RUN groupadd asterisk -g "${UID}" && useradd -u "${UID}" -r -d /var/lib/asterisk -g asterisk asterisk \
  && mkdir -p /var/lib/asterisk \
  && chown asterisk:asterisk /var/lib/asterisk

COPY --chown=asterisk:asterisk --from=builder /etc/freepbx.conf /etc/freepbx.conf
COPY --chown=asterisk:asterisk --from=builder /etc/asterisk  /etc/asterisk
COPY --chown=asterisk:asterisk --from=builder /var/www/html  /var/www/html
COPY --chown=asterisk:asterisk --from=builder /var/www/html  /var/www/html

# db duimps
COPY --chown=asterisk:asterisk --from=builder /opt/dump.sql  /opt/dump.sql
COPY --chown=asterisk:asterisk --from=builder /opt/dumpcdr.sql  /opt/dumpcdr.sql
# binaries
COPY --chown=asterisk:asterisk --from=builder /usr/sbin/fwconsole /usr/sbin/fwconsole
COPY --chown=asterisk:asterisk --from=builder /usr/sbin/asterisk /usr/sbin/asterisk
COPY --chown=asterisk:asterisk --from=builder /var/spool/asterisk /var/spool/asterisk
COPY --chown=asterisk:asterisk --from=builder /var/log/asterisk /var/log/asterisk
#COPY --chown=asterisk:asterisk --from=builder /usr/lib/asterisk /usr/lib/asterisk
#COPY --chown=asterisk:asterisk --from=builder /lib/asterisk /lib/asterisk
COPY --chown=asterisk:asterisk --from=builder /lib/libasterisk* /lib/

RUN sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 0.0.0.0:9000|g'  /etc/php/7.4/fpm/pool.d/www.conf && \
  sed -i 's/group = www-data/group = asterisk/g' /etc/php/7.4/fpm/pool.d/www.conf && \ 
  sed -i 's/user = www-data/user = asterisk/g' /etc/php/7.4/fpm/pool.d/www.conf && \ 
  sed -i 's/listen.owner = www-data/listen.owner = asterisk/g' /etc/php/7.4/fpm/pool.d/www.conf && \
  sed -i 's/listen.group = www-data/listen.group = asterisk/g' /etc/php/7.4/fpm/pool.d/www.conf && \
  sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/7.4/fpm/pool.d/www.conf && \
  sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.4/fpm/php-fpm.conf

COPY prelaunch.sh .
expose  9000

ENTRYPOINT ["./prelaunch.sh"]
