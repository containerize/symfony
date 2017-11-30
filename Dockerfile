FROM php:fpm-jessie

RUN apt-get update \
    && apt-get install -y glusterfs-client supervisor git nginx \
    # gd
    libjpeg62-turbo-dev libpng-dev libfreetype6-dev \ 
    # intl
    libicu-dev \
    # mcrypt
    libmcrypt-dev \
    # xsl
    libxslt-dev \
    # bz2
    libbz2-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure intl \
    && docker-php-ext-install opcache pdo_mysql iconv mcrypt mysqli pdo mbstring gd bcmath calendar exif intl sockets xsl zip bz2 \
    # redis
    && echo ' ' | pecl install -f redis \
    && rm -rf /tmp/pear \
    && echo "extension=redis.so" > /usr/local/etc/php/conf.d/docker-php-ext-redis.ini \
    # composer
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


ENV COMPOSER_HOME /composer
# allow Composer to be run as root
# ENV COMPOSER_ALLOW_SUPERUSER 1

# configuration
COPY conf/nginx/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx/app.conf /etc/nginx/conf.d/app.conf
COPY conf/php/docker-php-ext-opcache.ini /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
COPY conf/php/symfony.ini /usr/local/etc/php/conf.d/symfony.ini
COPY conf/php/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY conf/supervisord/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

EXPOSE 80

WORKDIR /symfony

# volumes
VOLUME ["/var/log/nginx/"]

VOLUME ["/symfony"]

ENTRYPOINT [ "supervisord", "-c", "/etc/supervisor/conf.d/supervisor.conf" ]