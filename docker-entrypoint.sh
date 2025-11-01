#!/bin/sh

# Generate APP_KEY if missing
php artisan key:generate --force

# Clear Laravel caches
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear

# Start Laravel server
php artisan serve --host=0.0.0.0 --port=8000
