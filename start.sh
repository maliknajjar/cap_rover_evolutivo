#!/usr/bin/env bash

# make sure directory has correct permissions
chown www-data:www-data /var/www/html

# running fpm
mkdir /run/php
php-fpm8.2 -D
chown www-data:www-data /run/php

# the entry point
exec /usr/sbin/apache2ctl -D FOREGROUND
