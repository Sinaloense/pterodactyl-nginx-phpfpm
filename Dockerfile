# ─────────────────────────────────────────────────────────────────────────────
# Etapa 1 – Compilar PHP 7.4 (security backports de remicollet)
# ─────────────────────────────────────────────────────────────────────────────
FROM debian:bullseye-slim AS php-builder

LABEL maintainer="Manuel Martinez <sina@serverscstrike.com>"

ENV DEBIAN_FRONTEND=noninteractive

# Repositorios apuntando a archive por EOL de Bullseye
RUN echo "deb http://archive.debian.org/debian bullseye main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security bullseye-security main" >> /etc/apt/sources.list && \
    apt-get -o Acquire::Check-Valid-Until=false update && apt-get install --no-install-recommends -y \
    ca-certificates curl git autoconf automake bison re2c pkg-config \
    make gcc g++ libxml2-dev libsqlite3-dev libssl-dev libcurl4-openssl-dev \
    libonig-dev libreadline-dev libzip-dev zlib1g-dev libbz2-dev \
    libpng-dev libjpeg62-turbo-dev libwebp-dev libfreetype6-dev \
    libgmp-dev libicu-dev libpq-dev default-libmysqlclient-dev \
    libmemcached-dev libsodium-dev libargon2-dev \
    libmagickwand-dev libmagickcore-dev libmaxminddb-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 --branch PHP-7.4-security-backports \
    https://github.com/remicollet/php-src-security.git /usr/src/php

WORKDIR /usr/src/php

RUN ./buildconf --force && \
    ./configure \
    --prefix=/usr/local \
    --with-config-file-path=/usr/local/etc/php \
    --with-config-file-scan-dir=/usr/local/etc/php/conf.d \
    --enable-fpm \
    --with-fpm-user=container \
    --with-fpm-group=container \
    --enable-mbstring \
    --enable-bcmath \
    --enable-sockets \
    --enable-soap \
    --enable-intl \
    --enable-opcache \
    --enable-exif \
    --with-openssl \
    --with-curl \
    --with-zlib \
    --with-bz2 \
    --with-zip \
    --with-gmp \
    --with-readline \
    --with-pdo-mysql \
    --with-mysqli \
    --with-pdo-pgsql \
    --with-pgsql \
    --with-sodium \
    --with-password-argon2 \
    --enable-gd \
    --with-jpeg \
    --with-webp \
    --with-freetype \
    --disable-short-tags \
    --with-pear \
    && make -j"$(nproc)" \
    && make install

# Instalar módulos PECL adicionales y habilitarlos
RUN mkdir -p /usr/local/etc/php/conf.d && \
    pecl channel-update pecl.php.net && \
    pecl install imagick-3.7.0 memcached-3.2.0 mongodb-1.16.2 maxminddb-1.11.1 && \
    echo "extension=imagick.so" > /usr/local/etc/php/conf.d/20-imagick.ini && \
    echo "extension=memcached.so" > /usr/local/etc/php/conf.d/20-memcached.ini && \
    echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/20-mongodb.ini && \
    echo "extension=maxminddb.so" > /usr/local/etc/php/conf.d/20-maxminddb.ini && \
    echo "zend_extension=opcache.so" > /usr/local/etc/php/conf.d/10-opcache.ini && \
    echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/10-opcache.ini

# ─────────────────────────────────────────────────────────────────────────────
# Etapa 2 – Imagen final
# ─────────────────────────────────────────────────────────────────────────────
FROM debian:bullseye-slim

LABEL maintainer="Manuel Martinez <sina@serverscstrike.com>"

ENV DEBIAN_FRONTEND=noninteractive

RUN echo "deb http://archive.debian.org/debian bullseye main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security bullseye-security main" >> /etc/apt/sources.list && \
    apt-get -o Acquire::Check-Valid-Until=false update && apt-get install --no-install-recommends -y \
    ca-certificates curl tini nginx wget zip unzip git jpegoptim optipng pngquant gifsicle libavif-bin ghostscript \
    libxml2 libsqlite3-0 libssl1.1 libcurl4 libonig5 libreadline8 libzip4 zlib1g libbz2-1.0 \
    libpng16-16 libjpeg62-turbo libwebp6 libfreetype6 libgmp10 libicu67 \
    libpq5 libmariadb3 libmemcached11 libsodium23 libargon2-1 \
    libmagickwand-6.q16-6 libmaxminddb0 \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs && npm install -g svgo \
    && wget -q -O /tmp/composer.phar https://getcomposer.org/download/latest-2.x/composer.phar \
    && SHA256=$(wget -q -O - https://getcomposer.org/download/latest-2.x/composer.phar.sha256) \
    && echo "$SHA256 /tmp/composer.phar" | sha256sum -c - \
    && mv /tmp/composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && rm -rf /var/lib/apt/lists/* \
    && adduser --disabled-password --home /home/container container

COPY --from=php-builder /usr/local /usr/local

RUN mkdir -p /usr/local/etc/php/conf.d /usr/local/var/log /usr/local/var/run \
    && cp /usr/local/etc/php-fpm.conf.default /usr/local/etc/php-fpm.conf \
    && cp /usr/local/etc/php-fpm.d/www.conf.default /usr/local/etc/php-fpm.d/www.conf

ENV PHP_INI_SCAN_DIR=/usr/local/etc/php/conf.d:/home/container/fpm/conf.d

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER container
ENV USER=container HOME=/home/container

WORKDIR /home/container

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
