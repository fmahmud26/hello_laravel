#!/bin/bash
# start.sh

# Create sqlite database file if it doesn't exist
touch /var/www/database/database.sqlite

# Run database migrations
php artisan migrate --force

# Start PHP-FPM and Nginx
php-fpm &
nginx -g "daemon off;"