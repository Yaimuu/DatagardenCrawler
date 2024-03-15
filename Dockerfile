# Use the latest PHP image from Docker Hub
FROM php:7.4-fpm

# Set working directory
WORKDIR /var/www

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

WORKDIR /var/www/datagarden-crawler

RUN chmod -R 755 .

# Expose port
EXPOSE 80 8080

# Run Laravel server
CMD bash -c "chmod +x start.sh & ./start.sh"