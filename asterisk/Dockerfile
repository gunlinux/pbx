# Используем официальный образ Debian как базовый
FROM debian:latest

# Устанавливаем необходимые пакеты
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    libncurses5-dev \
    libssl-dev \
    libxml2-dev \
    uuid-dev #\
    && rm -rf /var/lib/apt/lists/*

# Задаем рабочую директорию
WORKDIR /usr/src

# Скачиваем и распаковываем Asterisk
RUN wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz \
    && tar -xzf asterisk-18-current.tar.gz \
    && rm asterisk-18-current.tar.gz && ln -s /usr/src/asterisk-18.* /usr/src/asterisk

WORKDIR /usr/src/asterisk
#RUN  
# Устанавливаем Asterisk
RUN apt-get install libedit-dev -y
# dev time 
RUN apt-get install  less vim -y  
RUN apt-get install  sqlite3 libsqlite3-dev -y
RUN ./configure --with-jansson-bundled \
    && make menuselect.makeopts \
    && make \
    && make install \
    && make samples \
    && make config \
    && ldconfig
#RUN apt-get install asterisk
# Копируем конфигурационные файлы в контейнер
COPY asterisk.conf /etc/asterisk/asterisk.conf
COPY extensions.conf /etc/asterisk/extensions.conf
COPY sip.conf /etc/asterisk/sip.conf

# Открываем необходимые порты
EXPOSE 5060/udp 5060/tcp 10000-20000/udp

# Запуск Asterisk
CMD ["asterisk", "-f", "-U", "root"]
#CMD ["/bin/sh"]


