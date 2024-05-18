# Используем официальный образ Debian как базовый
FROM debian:latest

# Устанавливаем необходимые пакеты
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    libncurses5-dev \
    libssl-dev \
    libxml2-dev \
    uuid-dev \
    sqlite3 libsqlite3-dev \
    libedit-dev 
    # && rm -rf /var/lib/apt/lists/*

RUN apt-get install  less vim -y  

# Задаем рабочую директорию
WORKDIR /usr/src

# Скачиваем и распаковываем Asterisk
RUN wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz \
    && tar -xzf asterisk-18-current.tar.gz \
    && rm asterisk-18-current.tar.gz && ln -s /usr/src/asterisk-18.* /usr/src/asterisk

WORKDIR /usr/src/asterisk

# Устанавливаем Asterisk
# dev time 
RUN ./configure --with-jansson-bundled \
    && make menuselect.makeopts \
    && make \
    && make install \
    && make samples \
    && make config \
    && ldconfig
# Костльный бд движы
RUN apt-get install -y mariadb-server 
#RUN apt-get install asterisk
# Некостыльные бд
# дебы  freepbx вроде ?
RUN apt-get install -y odbc-mariadb  mariadb-client unixodbc odbcinst \
git vim curl wget libnewt-dev libssl-dev libncurses5-dev subversion software-properties-common libsqlite3-dev build-essential libjansson-dev libxml2-dev uuid-dev sox mpg123 lame ffmpeg
# node
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs


# PBX HELL HERE

WORKDIR /usr/src 
RUN wget http://mirror.freepbx.org/modules/packages/freepbx/7.4/freepbx-16.0-latest.tgz && \
tar xfz freepbx-16.0-latest.tgz  && ln -s freepbx-16.0 freepbx
WORKDIR /usr/src/freepbx
COPY  dbhelper.sh  .
COPY  phphelper.sh  .
RUN bash phphelper.sh
##  php -hell
RUN  apt update && apt install -y php7.4 && \
  apt install -y php7.4-mysql php7.4-cli php7.4-common php7.4-imap php7.4-ldap php7.4-xml php7.4-fpm php7.4-curl php7.4-mbstring php7.4-zip php7.4-gd php7.4-gettext php7.4-xml php7.4-json
RUN groupadd asterisk && useradd -r -d /var/lib/asterisk -g asterisk asterisk && usermod -aG audio,dialout asterisk 
#chown -R asterisk.asterisk /etc/asterisk /var/{lib,log,spool}/asterisk /usr/lib64/asterisk

RUN chown -R asterisk:asterisk /var/lib/asterisk/
COPY asterisk.conf /etc/asterisk/asterisk.conf
RUN mkdir -p /home/asterisk && chown -R asterisk:asterisk /home/asterisk /var/run/asterisk/ /var/lib/asterisk
RUN apt-get install cron -y
RUN rm -f /var/lib/asterisk/astdb.sqlite3
COPY pbx.sh  .

RUN ls -ld  /var/lib/asterisk
RUN chmod -R 777 /var/lib/asterisk

RUN ls -ld  /var/lib/asterisk
#RUN chown -Rvf 1000:/var/lib/asterisk /var/run/asterisk  
RUN mkdir -p /loki
#RUN groupadd -g 1488 loki && \
#    useradd -m -u 1488 -g loki -s /bin/bash loki 
RUN chown -R asterisk:asterisk /var/lib/asterisk

RUN ls -ld  /var/lib/asterisk
RUN rm -f /var/lib/asterisk/astdb.sqlite3 && bash pbx.sh && \
    asterisk -G asterisk -U asterisk -C /etc/asterisk/asterisk.conf & sleep 6 && \
    bash dbhelper.sh && \
    ./install -n --dbuser=root --dbpass=123123 
#&& \
#    echo fwconsole setting MODULE_REPO ${MODULE_REPO} && \
RUN echo "WTF"
RUN mariadbd --user root  & sleep 15 && fwconsole ma enablerepo extended  && \
      fwconsole ma upgradeall
RUN mariadbd --user root  & sleep 10 && \
  ps -aux  &&\
  fwconsole setting MODULE_REPO "http://mirror1.freepbx.org,http://mirror2.freepbx.org" && \
  fwconsole ma upgradeall && \
  fwconsole ma install core && \
  fwconsole ma install framework && \
  asterisk -G asterisk -U asterisk -C /etc/asterisk/asterisk.conf & sleep 6 && \
  fwconsole ma downloadinstall api paging parking queueprio weakpasswords callwaiting languages findmefollow backup bulkhandler queues ringgroups timeconditions ivr cel configedit asteriskinfo certman ucp webrtc sipsettings && \
  fwconsole ma installlocal
  # announcement blacklist  

RUN mariadbd --user root & sleep 15 && mysqldump -u root -p123123 --all-databases > all_databases_dump.sql





# Копируем конфигурационные файлы в контейнер
COPY extensions.conf /etc/asterisk/extensions.conf
COPY sip.conf /etc/asterisk/sip.conf

# Открываем необходимые порты
EXPOSE 5060/udp 5060/tcp 10000-20000/udp

# Запуск Asterisk
CMD ["asterisk", "-f", "-U", "root"]
#CMD ["/bin/sh"]


