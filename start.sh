#!/usr/bin/env bash

if [ "$FRESH_INSTALL" = "0" ]; then
    # remove the config.inc.php file
    rm -rf /var/www/html/evolutivo/config.inc.php
    # move the config.inc.php to the evolutivo install if its not a fresh install
    cp /config.inc.php /var/www/html/evolutivo/config.inc.php
    # change the values of the config.inc.php file based in the available env variables
    sed -i "1,50s/<DB_HOST>/${DB_HOST}/g" /var/www/html/evolutivo/config.inc.php
    sed -i "1,50s/<DB_PORT>/${DB_PORT}/g" /var/www/html/evolutivo/config.inc.php
    sed -i "1,50s/<DB_NAME>/${DB_NAME}/g" /var/www/html/evolutivo/config.inc.php
    sed -i "1,50s/<DB_USER>/${DB_USER}/g" /var/www/html/evolutivo/config.inc.php
    sed -i "1,50s/<DB_PASS>/${DB_PASS}/g" /var/www/html/evolutivo/config.inc.php
    sed -i "1,50s@<SITE_URL>@${SITE_URL}@g" /var/www/html/evolutivo/config.inc.php
fi

# make sure directory has correct permissions
chown www-data:www-data /var/www/html

# running fpm
mkdir /run/php
php-fpm8.2 -D
chown www-data:www-data /run/php

# the entry point
exec /usr/sbin/apache2ctl -D FOREGROUND
