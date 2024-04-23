FROM ubuntu:20.04
LABEL Description="coreBOS linux-apache-php coreBOS Test"

SHELL ["/bin/bash", "-c"]

# Use the default UTF-8 language.
ENV LANG C.UTF-8

ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt -y upgrade
RUN apt autoremove
RUN apt update
RUN apt-get -y install apt-utils
RUN apt install -y lsb-release gnupg2 ca-certificates apt-transport-https software-properties-common
RUN apt-get -y install php-xdebug
RUN add-apt-repository ppa:ondrej/apache2
RUN add-apt-repository ppa:ondrej/php
RUN apt-get update
RUN apt-get -y install openjdk-11-jdk
RUN apt-get install -y apache2 vim curl git wget mysql-client redis-tools cron
RUN apt-get install -y php7.4 php7.4-fpm php7.4-memcached libapache2-mod-php7.4 libapache2-mod-fcgid php7.4-redis php7.4-curl php7.4-gd php7.4-xml php7.4-xdebug php7.4-soap php7.4-mbstring php7.4-zip php7.4-mysql php7.4-imap php7.4-dom
RUN apt update
RUN apt-get install -y php8.2 php8.2-fpm php8.2-memcached php8.2-dev php8.2-xml libapache2-mod-php8.2 php8.2-redis php8.2-curl php8.2-gd php8.2-xml php8.2-xdebug php8.2-soap php8.2-mbstring php8.2-zip php8.2-mysql php8.2-imap php8.2-dom

COPY php.ini /etc/php/7.4/fpm
COPY php.ini /etc/php/8.2/fpm

COPY sonar-scanner-4.7.0.2747-linux/ /home/sonarscan/
RUN a2enmod rewrite
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mailutils
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get -y install nodejs
RUN npm config set unsafe-perm true
RUN npm install -g eslint
RUN apt install php-codesniffer

RUN a2enmod actions fcgid alias proxy_fcgi
RUN apt update
RUN apt-get --no-install-recommends -y install apt-transport-https
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list 
RUN apt-get -y install unixodbc-dev
RUN apt update 
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17 odbcinst=2.3.7 odbcinst1debian2=2.3.7 unixodbc-dev=2.3.7 unixodbc=2.3.7 
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18 unixodbc-dev
RUN pecl install sqlsrv pdo_sqlsrv || apt-get install -y --allow-downgrades odbcinst=2.3.7 odbcinst1debian2=2.3.7 unixodbc=2.3.7 unixodbc-dev=2.3.7
RUN printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/8.2/mods-available/sqlsrv.ini
RUN printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/8.2/mods-available/pdo_sqlsrv.ini
RUN phpenmod -v 8.2 sqlsrv pdo_sqlsrv
RUN phpenmod -v 7.4 sqlsrv pdo_sqlsrv

EXPOSE 80

# adding evolutivo repository to the image
COPY evolutivo /var/www/html/evolutivo
# COPY configs/.htaccess /var/www/html/evolutivo/.htaccess
# COPY index.php /var/www/html/evolutivo/index.php

WORKDIR /var/www/html

COPY start.sh /root
RUN chmod +x /root/start.sh

CMD ["/root/start.sh"]
