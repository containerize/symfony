FROM php:fpm-alpine

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories \
    && echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && echo 'http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
    && apk add --no-cache git openssh-client nginx \
    # php7-redis  php7-session \
    freetype libpng libjpeg-turbo freetype-dev libjpeg-turbo-dev libpng-dev \
    icu-dev \
    libmcrypt-dev readline-dev \
    libxslt-dev \
    bzip2-dev

# extension
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-configure intl && \
    docker-php-ext-install opcache iconv mcrypt mysqli pdo pdo_mysql mbstring gd \
    bcmath calendar exif intl sockets xsl zip bz2

# extension - redis
# ENV PHPREDIS_VERSION 2.2.7
# ENV PHP_AUTOCONF 
# RUN pecl channel-update pecl.php.net \
#     && pecl install -o -f redis \
#     && rm -rf /tmp/pear \
#     && echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini
# RUN curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz \
#     && tar xfz /tmp/redis.tar.gz \
#     && rm -r /tmp/redis.tar.gz \
#     && mkdir -p /usr/src/php/ext/redis \
#     && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
#     && docker-php-ext-install redis


# composer
ENV COMPOSER_HOME /composer

# allow Composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY app.conf /etc/nginx/conf.d/app.conf
COPY docker-php-ext-opcache.ini /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
COPY symfony.ini /usr/local/etc/php/conf.d/symfony.ini
COPY php-fpm.conf /usr/local/etc/php-fpm.conf

EXPOSE 80

WORKDIR /symfony

# volume logs
VOLUME ["/var/log/nginx/"]

ENTRYPOINT ["nginx"]
