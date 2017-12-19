FROM wordpress:php7.2-fpm

RUN apt-get update && apt-get install -y \
        libicu-dev \
        libmcrypt-dev \
        libmagickwand-dev \
        libsodium-dev \
        --no-install-recommends && rm -r /var/lib/apt/lists/* \

    && pecl install redis-3.1.4 imagick-3.4.3 libsodium-2.0.10 \
    && docker-php-ext-enable redis imagick sodium \
    && docker-php-ext-install -j$(nproc) exif gettext intl sockets zip
