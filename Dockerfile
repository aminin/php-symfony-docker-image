FROM php:cli

LABEL maintainer="Anton Minin <a.minin@omlook.com>"

# 58.2 is the newest version of ICU jessie can compile
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        ucf libc6 libgd3 libxpm4 libmcrypt4 libfreetype6 libpng12-0 libjpeg62-turbo \
        libicu-dev \
        g++ \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
  && curl -sS -o /tmp/icu.tar.gz -L http://download.icu-project.org/files/icu4c/58.2/icu4c-58_2-src.tgz \
    && tar -zxf /tmp/icu.tar.gz -C /tmp \
    && cd /tmp/icu/source \
    && ./configure --prefix=/opt/icu58.2 \
    && make \
    && make install \
    && docker-php-ext-configure intl --with-icu-dir=/opt/icu58.2 \
    && docker-php-ext-install intl \
    && docker-php-ext-enable opcache \
    && docker-php-ext-install -j$(nproc) iconv mcrypt zip pdo_mysql exif \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
  && pecl install redis \
    && pecl install xdebug \
    && docker-php-ext-enable redis xdebug \
  && apt-get remove -y \
        libicu-dev \
        g++ \
        libpng-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && apt-get autoremove -y \
  && rm -rf /var/cache/apt/* && rm -rf /tmp/* && rm -rf /var/lib/apt/lists/*

RUN curl --insecure https://getcomposer.org/composer.phar -o /usr/bin/composer && chmod +x /usr/bin/composer

ADD symfony.ini /usr/local/etc/php/conf.d/
ADD php.ini /usr/local/etc/php/

CMD pwd; whoami; php -v;
