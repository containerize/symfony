FROM php:fpm-alpine

RUN apk add --no-cache supervisor git openssh-client nginx \
    autoconf gcc libc-dev make \
    freetype libpng libjpeg-turbo freetype-dev libjpeg-turbo-dev libpng-dev \
    icu-dev \
    libmcrypt-dev readline-dev \
    libxslt-dev \
    bzip2-dev

# extension
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure intl \
    && docker-php-ext-install opcache \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install iconv mcrypt mysqli pdo  mbstring gd bcmath calendar exif intl sockets xsl zip bz2

# extension - redis
RUN pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini

# install composer
ENV COMPOSER_HOME /composer
# allow Composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# configuration
COPY conf/nginx/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx/app.conf /etc/nginx/conf.d/app.conf
COPY conf/php/docker-php-ext-opcache.ini /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
COPY conf/php/symfony.ini /usr/local/etc/php/conf.d/symfony.ini
COPY conf/php/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY conf/supervisord.conf /etc/supervisord.conf

EXPOSE 80

WORKDIR /symfony

# volume logs
VOLUME ["/var/log/nginx/"]

CMD ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]
