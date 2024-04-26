FROM ubuntu:20.04

SHELL ["/bin/bash", "-c"]

# Use the default UTF-8 language.
ENV LANG C.UTF-8

ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt -y upgrade && apt -y autoremove

# Install required packages
RUN apt-get -y install apt-utils lsb-release gnupg2 ca-certificates apt-transport-https software-properties-common
# RUN apt-get -y install openjdk-11-jdk apache2 vim curl git wget mysql-client redis-tools cron nodejs npm mailutils

# Add repositories and install PHP 8.2 and extensions
RUN add-apt-repository ppa:ondrej/php
RUN apt update
RUN apt-get -y install php8.2 php8.2-fpm php8.2-memcached php8.2-dev php8.2-xml libapache2-mod-php8.2 php8.2-redis php8.2-curl php8.2-gd php8.2-xdebug php8.2-soap php8.2-mbstring php8.2-zip php8.2-mysql php8.2-imap php8.2-dom

# Enable necessary Apache modules
RUN a2enmod rewrite actions alias proxy proxy_fcgi

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Microsoft ODBC and SQL Server extensions
RUN apt-get -y install apt-transport-https
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list 
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql17 odbcinst=2.3.7 odbcinst1debian2=2.3.7 unixodbc-dev=2.3.7 unixodbc=2.3.7
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18 unixodbc-dev
RUN pecl install sqlsrv pdo_sqlsrv || apt-get install -y --allow-downgrades odbcinst=2.3.7 odbcinst1debian2=2.3.7 unixodbc=2.3.7 unixodbc-dev=2.3.7
RUN printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/8.2/mods-available/sqlsrv.ini
RUN printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/8.2/mods-available/pdo_sqlsrv.ini
RUN phpenmod -v 8.2 sqlsrv pdo_sqlsrv

# pass your php.ini file
COPY php.ini /etc/php/8.2/cli/php.ini
COPY php.ini /etc/php/8.2/apache2/php.ini

# Expose port 80
EXPOSE 80

# Copy application files and configurations
RUN rm -rf /var/www/html/index.html
COPY --chown=www-data:www-data evolutivo /var/www/html/
COPY configs/.htaccess /var/www/html/.htaccess

# Set working directory
WORKDIR /var/www/html

# Copy and set permissions for startup script
COPY start.sh /root
RUN chmod +x /root/start.sh

# Set entry point
ENTRYPOINT ["/root/start.sh"]
