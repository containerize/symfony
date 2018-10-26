FROM containerize/symfony:base

RUN  apt-get update \
    && apt-get install -y sox \
    && rm -r /var/lib/apt/lists/*

# configuration
COPY conf/nginx/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx/app.conf /etc/nginx/conf.d/app.conf
COPY conf/php/symfony.ini /usr/local/etc/php/conf.d/symfony.ini
COPY conf/php/fpm.d/docker.conf /usr/local/etc/php-fpm.d/docker.conf
COPY conf/php/fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY conf/supervisor/conf.d /etc/supervisor/conf.d
COPY conf/ssh/ssh_config /etc/ssh/ssh_config

EXPOSE 80
WORKDIR /symfony

VOLUME ["/var/log", "/symfony"]

ENTRYPOINT ["supervisord"]
CMD ["-n", "-c", "/etc/supervisor/supervisord.conf"]