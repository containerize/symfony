FROM php:fpm-jessie

RUN apt-get update \
    && apt-get install -y glusterfs-client supervisor git nginx openssh-server vim locales \
    # gd
    libjpeg62-turbo-dev libpng12-dev libfreetype6-dev \ 
    # intl
    libicu-dev \
    # mcrypt
    libmcrypt-dev \
    # xsl
    libxslt-dev \
    # bz2
    libbz2-dev \
    # sshd
    && mkdir -p /var/run/sshd \
    # cleanup apt-get
    && rm -r /var/lib/apt/lists/* \
    # remember pass
    && sed -i s/#PasswordAuthentication.*/PasswordAuthentication\ no/ /etc/ssh/sshd_config \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure intl \
    && docker-php-ext-install opcache pdo_mysql iconv mcrypt mysqli pdo mbstring gd bcmath calendar exif intl sockets xsl zip bz2 \
    # redis
    && echo ' ' | pecl install -f redis \
    && rm -rf /tmp/pear \
    && echo "extension=redis.so" > /usr/local/etc/php/conf.d/docker-php-ext-redis.ini \
    # composer
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    # support zh
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen 


ENV COMPOSER_HOME /composer
# allow Composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

ENV LANG en_US.UTF-8

# configuration
COPY conf/php/docker-php-ext-opcache.ini /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
