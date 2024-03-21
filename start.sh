#!/bin/bash
echo "composer install"
composer install --no-scripts --no-autoloader --working-dir=./datagarden-crawler/
echo "composer update"
composer update --lock --working-dir=./datagarden-crawler/
echo "composer dump-autoload"
composer dump-autoload --no-scripts --working-dir=./datagarden-crawler/

php ./datagarden-crawler/artisan key:generate
# Generate security key
php ./datagarden-crawler/artisan key:generate
# Optimizing Configuration loading
php ./datagarden-crawler/artisan config:cache
# Optimizing Route loading
php ./datagarden-crawler/artisan route:cache
# Optimizing View loading
php ./datagarden-crawler/artisan view:cache

# Running the app
php ./datagarden-crawler/artisan serve --host 0.0.0.0 --port 80