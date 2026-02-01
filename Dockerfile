FROM php:8.5-fpm-bookworm

LABEL maintainer="Manuel Martinez <sina@serverscstrike.com>"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --no-install-recommends -y \
    tini nginx wget zip unzip git jpegoptim optipng pngquant gifsicle libavif-bin ghostscript \
    && curl -fsSL -o /usr/local/bin/install-php-extensions https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    && chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions bcmath exif gd gmp imagick intl maxminddb memcached mongodb mysqli pdo_mysql pgsql soap sockets zip \
    && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs && npm install -g svgo \
    && wget -q -O /tmp/composer.phar https://getcomposer.org/download/latest-stable/composer.phar \
    && SHA256=$(wget -q -O - https://getcomposer.org/download/latest-stable/composer.phar.sha256) \
    && echo "$SHA256 /tmp/composer.phar" | sha256sum -c - \
    && mv /tmp/composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && rm -rf /var/lib/apt/lists/* \
    && adduser --disabled-password --home /home/container container

ENV PHP_INI_SCAN_DIR=/usr/local/etc/php/conf.d:/home/container/fpm/conf.d

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER container
ENV USER=container HOME=/home/container

WORKDIR /home/container

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
