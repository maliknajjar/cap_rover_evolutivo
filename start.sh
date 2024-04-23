#!/usr/bin/env bash
chown -R www-data:www-data /var/www/html
service cron start

# running fpm
mkdir /run/php
php-fpm8.2 -D
php-fpm7.4 -D
chown www-data:www-data /run/php

# the entry point
exec /usr/sbin/apache2ctl -D FOREGROUND
