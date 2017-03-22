FROM php:fpm-alpine

RUN apk add --no-cache git openssh-client \
    freetype libpng libjpeg-turbo freetype-dev libjpeg-turbo-dev libpng-dev \
    icu-dev \
    libmcrypt-dev readline-dev \
    libxslt-dev \
    bzip2-dev

# extension
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ 
RUN docker-php-ext-configure intl
RUN docker-php-ext-install opcache iconv mcrypt mysqli pdo pdo_mysql mbstring gd \
    bcmath calendar exif intl sockets xsl zip bz2

# extension - redis
RUN pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini

# composer
ENV COMPOSER_HOME /composer

ENV PATH /composer/vendor/bin:$PATH

# Allow Composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

# Setup the Composer installer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"

# RUN curl -sS https://getcomposer.org/installer | php -- \
#     --install-dir=/usr/local/bin \
#     --filename=composer

# install caddy
RUN curl --silent --show-error --fail --location \
      --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
      "https://caddyserver.com/download/build?os=linux&arch=amd64&features=${plugins}" \
    | tar --no-same-owner -C /usr/bin/ -xz caddy \
 && chmod 0755 /usr/bin/caddy \
 && /usr/bin/caddy -version

COPY Caddyfile /etc/Caddyfile

EXPOSE 80 443 2015


RUN usermod -u 1000 www-data

WORKDIR /symfony

VOLUME ["/user/local/etc/php/conf.d/symfony.ini"]
VOLUME ["/etc/php-fpm.conf"]

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout"]