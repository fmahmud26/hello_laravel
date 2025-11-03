FROM ubuntu:24.04

WORKDIR /var/www/html

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common curl git sqlite3 unzip \
    && add-apt-repository ppa:ondrej/php -y \
    && apt-get update && apt-get install -y \
        php8.3-cli php8.3-fpm php8.3-sqlite3 php8.3-mbstring \
        php8.3-bcmath php8.3-xml php8.3-zip php8.3-pdo \
        php8.3-pdo-mysql php8.3-curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Create necessary directories
RUN mkdir -p storage/framework/{sessions,views,cache} storage/logs bootstrap/cache database

# Copy source code
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Ensure writable dirs
RUN chmod -R 775 storage bootstrap/cache database && chown -R www-data:www-data storage bootstrap/cache

# Cache config and routes for performance
RUN php artisan config:clear || true && php artisan route:clear || true
RUN php artisan config:cache || true && php artisan route:cache || true

# Startup script
RUN echo '#!/bin/bash\n\
set -e\n\
cd /var/www/html\n\
\n\
# Ensure SQLite DB exists\n\
if [ ! -f database/database.sqlite ]; then\n\
    echo "Creating SQLite database..."\n\
    touch database/database.sqlite\n\
    chmod 666 database/database.sqlite\n\
fi\n\
\n\
# Run migrations (safe retry)\n\
for i in {1..5}; do\n\
  if php artisan migrate --force --no-interaction; then\n\
    echo "Migrations OK"\n\
    break\n\
  else\n\
    echo "Retrying migrations (\$i)..." && sleep 5\n\
  fi\n\
done\n\
\n\
# Start Laravel\n\
echo "Starting Laravel on port 8000..."\n\
exec php artisan serve --host=0.0.0.0 --port=8000\n' > /startup.sh && chmod +x /startup.sh

EXPOSE 8000
CMD ["/startup.sh"]
