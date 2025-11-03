FROM ubuntu:24.04

WORKDIR /var/www/html

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    git \
    sqlite3 \
    && add-apt-repository ppa:ondrej/php -y \
    && apt-get update \
    && apt-get install -y \
        php8.3-cli \
        php8.3-fpm \
        php8.3-sqlite3 \
        php8.3-mbstring \
        php8.3-bcmath \
        php8.3-xml \
        php8.3-zip \
        php8.3-pdo \
        php8.3-pdo-mysql \
        php8.3-curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Create necessary directories
RUN mkdir -p storage/framework/{sessions,views,cache} storage/logs bootstrap/cache database

# Copy application
COPY . .

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Set up environment and permissions
RUN if [ ! -f .env ]; then cp .env.example .env; fi \
    && php artisan key:generate --force \
    && chmod -R 775 storage bootstrap/cache database \
    && chown -R www-data:www-data storage bootstrap/cache

# Create startup script with SQLite lock handling
RUN echo '#!/bin/bash\n\
set -e\n\
cd /var/www/html\n\
\n\
# Wait for any existing database operations to complete\n\
if [ -f database/database.sqlite ]; then\n\
    echo "Waiting for database to be ready..."\n\
    timeout 30s bash -c '\''while ! sqlite3 database/database.sqlite "SELECT 1;" > /dev/null 2>&1; do sleep 1; done'\'' || echo "Database check timed out, continuing..."\n\
fi\n\
\n\
# Create database file if it doesn'\''t exist\n\
if [ ! -f database/database.sqlite ]; then\n\
    echo "Creating new SQLite database..."\n\
    touch database/database.sqlite\n\
    chmod 666 database/database.sqlite\n\
fi\n\
\n\
# Run migrations with retry logic for concurrent access\n\
echo "Running database migrations..."\n\
for i in {1..5}; do\n\
    if php artisan migrate --force --no-interaction; then\n\
        echo "Migrations completed successfully"\n\
        break\n\
    else\n\
        echo "Migration attempt \$i failed, retrying in 5 seconds..."\n\
        sleep 5\n\
    fi\n\
done\n\
\n\
# Start the server\n\
echo "Starting Laravel server on port 8000..."\n\
exec php artisan serve --host=0.0.0.0 --port=8000' > /startup.sh \
    && chmod +x /startup.sh

EXPOSE 8000

CMD ["/startup.sh"]