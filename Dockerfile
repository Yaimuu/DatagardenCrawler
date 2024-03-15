# Use the latest PHP image from Docker Hub
FROM php:7.4

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
    supervisor \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql \
    && mkdir -p /var/log/supervisor 

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy Laravel files
COPY . .

WORKDIR /var/www/html/datagarden-crawler

RUN chmod -R 755 .

# Install Laravel dependencies
RUN composer install --no-scripts --no-autoloader && \
    composer update --lock && \
    composer dump-autoload --no-scripts

RUN composer clear-cache && \
    rm -rf /root/.composer/cache/*

RUN echo user=root >>  /etc/supervisor/supervisord.conf

# Expose port 8080
EXPOSE 8080

# Generate security key
RUN php artisan key:generate
# Optimizing Configuration loading
RUN php artisan config:cache
# Optimizing Route loading
RUN php artisan route:cache
# Optimizing View loading
RUN php artisan view:cache

# Run Laravel server
CMD bash -c "composer install --working-dir=./datagarden-crawler/ && php ./datagarden-crawler/artisan serve --host 0.0.0.0 --port 8080"