#!/bin/sh

# Generate APP_KEY if missing
if [ -z "$APP_KEY" ]; then
    export APP_KEY=$(php artisan key:generate --show)
fi

# Copy .env if missing
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Replace APP_KEY in .env
sed -i "s|^APP_KEY=.*|APP_KEY=$APP_KEY|" .env

# Clear caches (skip migrations to avoid failure for now)
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear

# Serve Laravel
php artisan serve --host=0.0.0.0 --port=80
