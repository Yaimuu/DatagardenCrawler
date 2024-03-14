# Use the latest PHP image from Docker Hub
FROM php:latest

# Set working directory
WORKDIR /var/www/html

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

# Copy Laravel files
COPY . .

RUN chmod -R +x datagarden-crawler
# Run Composer install
WORKDIR /var/www/html/datagarden-crawler

# Install Laravel dependencies
RUN composer install
RUN ls ./vendor
RUN composer update

# Expose port 80
EXPOSE 8080

# Run Laravel server
CMD php artisan serve --host=0.0.0.0 --port=8080