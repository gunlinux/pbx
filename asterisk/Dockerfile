# Используем официальный образ Debian как базовый
FROM debian:12 as build-asterisk

# Устанавливаем необходимые пакеты
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    libncurses5-dev \
    libssl-dev \
    libxml2-dev \
    uuid-dev \
    sqlite3 libsqlite3-dev \
    libedit-dev 
    # && rm -rf /var/lib/apt/lists/*


# Задаем рабочую директорию
WORKDIR /usr/src

# Скачиваем и распаковываем Asterisk
RUN wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz \
    && tar -xzf asterisk-18-current.tar.gz \
    && rm asterisk-18-current.tar.gz && ln -s /usr/src/asterisk-18.* /usr/src/asterisk

WORKDIR /usr/src/asterisk

# Устанавливаем Asterisk
# dev time 
RUN apt-get install wget curl -y
RUN ./configure --with-jansson-bundled \
    && make menuselect.makeopts \
    && make \
    && make install \
    && make samples \
    && make config \
    && ldconfig
RUN ls -ld /lib64/ /lib/
RUN ls -l /lib64/ /lib/
FROM debian:12

RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl3 \
    libxml2 \
    libuuid1 \
    libsqlite3-0 \
    libedit2

#COPY --from=build-asterisk /lib64/asterisk/ /lib64/asterisk
COPY --from=build-asterisk /lib/asterisk/ /lib/asterisk
COPY --from=build-asterisk /var/spool/asterisk /var/spool/asterisk
COPY --from=build-asterisk /etc/asterisk /etc/asterisk
COPY --from=build-asterisk /usr/lib/asterisk /user/lib/asterisk
#COPY --from=build-asterisk /usr/lib64/asterisk /usr/lib64/asterisk
COPY --from=build-asterisk /usr/lib/asterisk /usr/lib/asterisk
COPY --from=build-asterisk /usr/sbin/asterisk /usr/sbin/asterisk
COPY --from=build-asterisk /usr/sbin/safe_asterisk /usr/sbin/safe_asterisk
COPY --from=build-asterisk /var/lib/asterisk /var/lib/asterisk

COPY asterisk.conf /etc/asterisk/asterisk.conf
RUN mkdir /var/lib/run/asterisk -p
ARG UID=10002
ENV ASTSAFE_FOREGROUND=1
RUN groupadd asterisk -g "${UID}" && useradd -u "${UID}" -r -d /var/lib/asterisk -g asterisk asterisk && usermod -aG audio,dialout asterisk  && chown -R asterisk:asterisk /etc/asterisk  /var/lib/asterisk  /var/lib/run/asterisk
CMD ["/usr/sbin/safe_asterisk"]
