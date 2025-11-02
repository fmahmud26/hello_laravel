#!/bin/sh

# Generate APP_KEY dynamically if missing
if [ -z "$APP_KEY" ]; then
    export APP_KEY=$(php artisan key:generate --show)
fi

# Save APP_KEY to .env
sed -i "s|^APP_KEY=.*|APP_KEY=$APP_KEY|" .env

# Run migrations
php artisan migrate --force

# Clear caches
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear

# Start server
php artisan serve --host=0.0.0.0 --port=80
