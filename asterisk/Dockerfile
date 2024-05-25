# Используем официальный образ Debian как базовый
FROM debian:12.5-slim as build-asterisk

# Устанавливаем необходимые пакеты
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    libncurses5-dev \
    libssl-dev \
    libxml2-dev \
    uuid-dev \
    sqlite3 libsqlite3-dev \
    libedit-dev \
    libsrtp2-dev subversion ca-certificates


# Задаем рабочую директорию
WORKDIR /usr/src

# Скачиваем и распаковываем Asterisk
RUN curl -o asterisk-18-current.tar.gz http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz \
    && tar -xzf asterisk-18-current.tar.gz \
    && rm asterisk-18-current.tar.gz && ln -s /usr/src/asterisk-18.* /usr/src/asterisk

WORKDIR /usr/src/asterisk

# Устанавливаем Asterisk
# dev time 
RUN apt-get install libsrtp2-dev subversion ca-certificates -y

RUN ./contrib/scripts/get_mp3_source.sh 
RUN apt-get install wget -y &&  \
    ./configure --with-pjproject-bundled --with-jansson-bundled --with-crypto --with-ssl=ssl --with-srtp && \
    make menuselect/menuselect menuselect-tree menuselect.makeopts && \
      menuselect/menuselect --disable BUILD_NATIVE \
      menuselect/menuselect --enable BETTER_BACKTRACES \
      menuselect/menuselect --enable codec_opus \
      menuselect/menuselect --enable app_macro  \
      menuselect/menuselect --enable format_mp3  \
      menuselect/menuselect --enable res_config_mysql \
      menuselect/menuselect --enable app_mysql menuselect.makeopts && \
    make -j4 && \
    make -j4 install && \
    make -j4 samples && \
    make basic-pbx && \
    make progdocs && ldconfig

FROM debian:12.5-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl3 \
    libxml2 \
    libuuid1 \
    libsqlite3-0 \
    procps \
    libedit2 && rm -rf /var/lib/apt/lists/*

ARG UID=10002
ENV ASTSAFE_FOREGROUND=1
RUN groupadd asterisk -g "${UID}" && useradd -u "${UID}" -r -d /var/lib/asterisk -g asterisk asterisk && \
  usermod -aG audio,dialout asterisk  

COPY --chown=asterisk:asterisk --from=build-asterisk /lib/asterisk/ /lib/asterisk/
COPY --chown=asterisk:asterisk --from=build-asterisk /etc/asterisk/ /etc/asterisk/
COPY --chown=asterisk:asterisk --from=build-asterisk /usr/lib/asterisk/ /usr/lib/asterisk/
COPY --chown=asterisk:asterisk --from=build-asterisk /var/spool/asterisk/ /var/spool/asterisk/
COPY --chown=asterisk:asterisk --from=build-asterisk /var/run/asterisk/ /var/run/asterisk/
COPY --chown=asterisk:asterisk --from=build-asterisk /var/lib/asterisk/ /var/lib/asterisk/
COPY --chown=asterisk:asterisk --from=build-asterisk /var/log/asterisk/ /var/log/asterisk/

COPY --chown=asterisk:asterisk --from=build-asterisk /lib/libasterisk* /lib/
COPY --chown=asterisk:asterisk --from=build-asterisk /usr/sbin/asterisk /usr/sbin/asterisk
COPY --chown=asterisk:asterisk --from=build-asterisk /usr/sbin/safe_asterisk /usr/sbin/safe_asterisk

COPY --chown=asterisk:asterisk asterisk.conf /etc/asterisk/asterisk.conf


CMD ["/usr/sbin/safe_asterisk"]
