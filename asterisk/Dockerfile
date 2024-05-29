# Используем официальный образ Debian как базовый
FROM alpine:3.14 as build-asterisk

ENV ASTERISK_MODULES_ENABLE BETTER_BACKTRACES codec_opus app_macro res_config_mysql format_mp3 chan_sip pbx_ael cdr_odbc app_mysql
ENV ASTERISK_MODULES_DISABLE BUILD_NATIVE app_adsiprog app_alarmreceiver  app_externalivr app_festival app_getcpeid app_ivrdemo app_jack app_meetme app_osplookup app_page app_privacy app_skel app_zapateller cdr_csv cdr_radius cdr_tds  cdr_sqlite3_custom cdr_pgsql chan_alsa chan_dahdi chan_console chan_mgcp chan_unistim codec_dahdi pbx_ael pbx_dundi pbx_lua res_adsi res_ael_share res_config_pgsql res_snmp res_timing_dahdi res_speech
ENV ASTERISK_CATEGORY_DISABLE MENUSELECT_CORE_SOUNDS MENUSELECT_MOH MENUSELECT_EXTRA_SOUNDS

RUN set -ex; apk update \
    && apk add --no-cache --virtual .runtime-deps \
      # ncurses-dev
      ncurses-terminfo-base ncurses-terminfo ncurses-libs \
      # util-linux-dev
      libuuid libblkid libfdisk libmount libsmartcols \
      # jansson-dev
      jansson \
      # libxml2-dev
      libxml2 \
      # sqlite-dev
      sqlite-libs \
      # ODBC
      readline unixodbc \
    && apk add --no-cache --virtual .build-deps \
      # Apply patches
      wget patch \
      # Core compile dependencies
      build-base ncurses-dev util-linux-dev jansson-dev libxml2-dev sqlite-dev bsd-compat-headers \
      # ODBC dependencies
      unixodbc-dev  curl subversion \
      wget  libedit-dev libsrtp-dev openssl-dev alsa-lib-dev gsm-dev \
      speex-dev speexdsp-dev	portaudio-dev libsrtp-dev libsamplerate-dev linux-headers binutils 

# Задаем рабочую директорию
WORKDIR /usr/src

# Скачиваем и распаковываем Asterisk
RUN curl -o asterisk-18-current.tar.gz http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz \
    && tar -xzf asterisk-18-current.tar.gz \
    && rm asterisk-18-current.tar.gz && ln -s /usr/src/asterisk-18.* /usr/src/asterisk

WORKDIR /usr/src/asterisk

RUN ./configure --with-pjproject-bundled --with-jansson-bundled --with-crypto --with-ssl=ssl --with-srtp
COPY  patches/* ./
RUN patch -p1 < ./10-musl-mutex-init.patch
RUN patch -p1 < ./20-musl-astmm-fix.patch
RUN patch -p1 < ./30-asterisk-mariadb.patch
RUN patch -p1 < ./40-asterisk-cdefs.patch
RUN patch -p1 < ./gethostbyname_r.patch
RUN patch third-party/pjproject/source/pjlib/include/pj/config_site.h < ./pjsip.patch

RUN  make menuselect/menuselect menuselect-tree menuselect.makeopts && \
    menuselect/menuselect \
       # Enable modules
       $(for MODULE in $ASTERISK_MODULES_ENABLE; do echo --enable $MODULE; done;) \
       # Disable modules
       $(for MODULE in $ASTERISK_MODULES_DISABLE; do echo --disable $MODULE; done;) \
       menuselect/menuselect --disable MALLOC_DEBUG \
       # Disable categories
       $(for CATEGORY in $ASTERISK_CATEGORY_DISABLE; do echo --disable-category $CATEGORY; done;) menuselect.makeopts && ./contrib/scripts/get_mp3_source.sh && make --no-silent  && make -j4 install  && \
  make basic-pbx  && strip /usr/lib/asterisk/modules/* 
RUN strip /usr/lib/asterisk/modules/* || True

# собираем asterisk_cli
RUN apk add go
WORKDIR /usr/src/
COPY ./asterisk_cli ./asterisk_cli
WORKDIR /usr/src/asterisk_cli
RUN make

FROM alpine:3.14

RUN apk update && apk add --no-cache \
    openssl \
    libxml2 \
    util-linux \
    sqlite-libs \
    procps \
    libedit && rm -rf /var/cache/apk/*

ARG UID=10002
ENV ASTSAFE_FOREGROUND=1
RUN addgroup -S asterisk -g "${UID}" && adduser -S asterisk -G asterisk -u "${UID}" -h /var/lib/asterisk &&  addgroup asterisk audio &&     addgroup asterisk dialout

#COPY --chown=asterisk:asterisk --from=build-asterisk /lib/asterisk/ /lib/asterisk/
COPY --chown=asterisk:asterisk --from=build-asterisk /etc/asterisk/ /etc/asterisk/
COPY --chown=asterisk:asterisk --from=build-asterisk /usr/lib/asterisk/ /usr/lib/asterisk/
COPY --chown=asterisk:asterisk --from=build-asterisk /var/spool/asterisk/ /var/spool/asterisk/
COPY --chown=asterisk:asterisk --from=build-asterisk /var/run/asterisk/ /var/run/asterisk/
COPY --chown=asterisk:asterisk --from=build-asterisk /var/lib/asterisk/ /var/lib/asterisk/
COPY --chown=asterisk:asterisk --from=build-asterisk /var/log/asterisk/ /var/log/asterisk/
COPY --chown=asterisk:asterisk --from=build-asterisk /usr/lib/libasterisk* /usr/lib/
COPY --chown=asterisk:asterisk --from=build-asterisk /usr/sbin/asterisk /usr/sbin/asterisk
COPY --chown=asterisk:asterisk --from=build-asterisk /usr/sbin/safe_asterisk /usr/sbin/safe_asterisk
COPY --chown=asterisk:asterisk --from=build-asterisk /usr/src/asterisk_cli/server/server  /usr/sbin/asterisk_cli_server
COPY --chown=asterisk:asterisk --from=build-asterisk /usr/src/asterisk_cli/client/client /usr/sbin/asterisk_cli

COPY --chown=asterisk:asterisk asterisk.conf /etc/asterisk/asterisk.conf
COPY prelaunch.sh .

ENTRYPOINT ["./prelaunch.sh"]
CMD ["/usr/sbin/safe_asterisk"]
