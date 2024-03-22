# Use the latest PHP image from Docker Hub
FROM php:7.4-apache

# Set working directory
WORKDIR /var/www

RUN apt-get update && apt-get install -y gnupg2
# Add apt repo ppa:ondrej/php
RUN echo "deb https://ppa.launchpadcontent.net/ondrej/php/ubuntu focal main" | tee -a /etc/apt/sources.list
RUN echo "#deb-src https://ppa.launchpadcontent.net/ondrej/php/ubuntu focal main" | tee -a /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4f4ea0aae5267a6c 

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Config apache
RUN echo "ServerName laravel-app.local" >> /etc/apache2/apache2.conf

ENV APACHE_DOCUMENT_ROOT=/var/www/datagarden-crawler/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN a2enmod rewrite headers

# Start with base PHP config, then add extensions.
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# Copy Laravel files
COPY . .

WORKDIR /var/www/datagarden-crawler

RUN chmod -R 755 .

# Expose port
EXPOSE 80 8080

# RUN composer require cybercite/datagarden-php-api-client-light

# Run Laravel server
CMD bash -c "chmod +x start.sh & ./start.sh"