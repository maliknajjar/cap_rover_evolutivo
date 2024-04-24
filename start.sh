#!/usr/bin/env bash
chown -R www-data:www-data /var/www/html
service cron start

if [ "$FRESH_INSTALL" = "true" ]; then
    # move the config.inc.php to the evolutivo install if its not a fresh install
    cp /config.inc.php /var/www/html/evolutivo/config.inc.php
    # change the values of the config.inc.php file
    sed -i "1,50s/<DB_HOST>/${DB_HOST}/g" /var/www/html/evolutivo/config.inc.php
    sed -i "1,50s/<DB_PORT>/${DB_PORT}/g" /var/www/html/evolutivo/config.inc.php
    sed -i "1,50s/<DB_NAME>/${DB_NAME}/g" /var/www/html/evolutivo/config.inc.php
    sed -i "1,50s/<DB_USER>/${DB_USER}/g" /var/www/html/evolutivo/config.inc.php
    sed -i "1,50s/<DB_PASS>/${DB_PASS}/g" /var/www/html/evolutivo/config.inc.php
fi


# running fpm
mkdir /run/php
php-fpm8.2 -D
php-fpm7.4 -D
chown www-data:www-data /run/php

# the entry point
exec /usr/sbin/apache2ctl -D FOREGROUND
