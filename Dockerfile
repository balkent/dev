FROM php:7.4.14-apache

ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /var/www/html

RUN apt-get update -qy && \
    apt-get install -y \
    git \
    libicu-dev \
    libpq-dev \
    unzip \
    zip

RUN docker-php-ext-install -j$(nproc) opcache pdo_pgsql

# Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# Xdebug
RUN pecl install xdebug

ADD git/config /root/.gitconfig
ADD apache/apache.conf /etc/apache2/conf-available/apache.conf
ADD apache/vhost.conf /etc/apache2/sites-available/000-default.conf
ADD bash/.bashrc /root/.bashrc
ADD php/php.ini /usr/local/etc/php/conf.d/app.ini

RUN a2enconf apache.conf
RUN a2enmod rewrite remoteip

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*