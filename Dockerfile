# Use Ubuntu 24.04 LTS as base
FROM ubuntu:24.04

# Set working directory
WORKDIR /var/www/html

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Update & install dependencies
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
RUN mkdir -p storage bootstrap/cache database

# Copy entire application
COPY . .

# Install dependencies and set up application
COPY .env.example .env
RUN composer install --no-dev --optimize-autoloader \
    && touch database/database.sqlite \
    && chmod -R 775 storage bootstrap/cache database \
    && php artisan key:generate --force || true

# Expose port 8000 for artisan serve
EXPOSE 8000

# Default command to run Laravel
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]