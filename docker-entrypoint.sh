#!/bin/sh

# Generate .env dynamically
cat <<EOL > .env
APP_NAME=Laravel
APP_ENV=production
APP_KEY=$(php artisan key:generate --show)
APP_DEBUG=false
APP_URL=${APP_URL:-http://localhost}

DB_CONNECTION=sqlite
DB_DATABASE=/var/www/html/database/database.sqlite
EOL

# Ensure database file exists
touch /var/www/html/database/database.sqlite

# Run migrations
php artisan migrate --force

# Clear caches
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear

# Start Laravel built-in server on port 80
php artisan serve --host=0.0.0.0 --port=80
