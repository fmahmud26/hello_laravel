#!/bin/sh

# Create .env if missing
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Generate APP_KEY if missing
php artisan key:generate --force

# Run migrations
php artisan migrate --force

# Clear caches
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear

# Start Laravel server
php artisan serve --host=0.0.0.0 --port=8000
