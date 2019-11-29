FROM containerize/symfony:base

RUN  apt-get update \
    && apt-get install -y sox logrotate \
    && apt-get install libldap2-dev -y \
    && rm -r /var/lib/apt/lists/* \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap

# configuration
COPY conf/nginx/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx/app.conf /etc/nginx/conf.d/app.conf
COPY conf/php/symfony.ini /usr/local/etc/php/conf.d/symfony.ini
COPY conf/php/fpm.d/docker.conf /usr/local/etc/php-fpm.d/docker.conf
COPY conf/php/fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY conf/supervisor/conf.d /etc/supervisor/conf.d
COPY conf/ssh/ssh_config /etc/ssh/ssh_config

# logrotate
COPY conf/logrotate.d/nginx  /etc/logrotate.d/nginx
COPY conf/logrotate.d/php-fpm  /etc/logrotate.d/php-fpm

EXPOSE 80
WORKDIR /symfony

VOLUME ["/var/log", "/symfony"]

COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY ./supervisord.sh /usr/local/bin/supervisord.sh
ENTRYPOINT [ "docker-entrypoint.sh" ]

CMD [ "-n", "-c", "/etc/supervisor/supervisord.conf" ]