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

# Create necessary directories with proper permissions
RUN mkdir -p storage/framework/{sessions,views,cache} storage/logs bootstrap/cache database \
    && chmod -R 775 storage bootstrap/cache

# Copy application
COPY . .

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Set up environment
RUN if [ ! -f .env ]; then cp .env.example .env; fi \
    && php artisan key:generate --force \
    && chown -R www-data:www-data storage bootstrap/cache

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]