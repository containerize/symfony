FROM php:7.0-fpm

# update
RUN apt-get update 

# extension - except: imagick apc xdebug geoip redis
RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng12-dev
RUN docker-php-ext-install iconv mcrypt mysqli pdo pdo_mysql mbstring gd
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ 

RUN usermod -u 1000 www-data

WORKDIR /symfony

EXPOSE 9000

VOLUME ["/user/local/etc/php/conf.d/symfony.ini"]
VOLUME ["/etc/php-fpm.conf"]

CMD ["php-fpm", "-F"]
