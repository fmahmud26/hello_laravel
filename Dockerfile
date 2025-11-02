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
    wget \
    unzip \
    git \
    sqlite3 \
    zip \
    libpng-dev \
    libjpeg-dev \
    libfreetype-dev \
    libonig-dev \
    libzip-dev \
    sudo \
    nano \
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

# Create storage and bootstrap/cache folders with write permissions
RUN mkdir -p storage bootstrap/cache database \
    && chmod -R 775 storage bootstrap/cache database

# Copy composer files first (for better caching)
COPY composer.json composer.lock ./

# Install Composer dependencies
RUN composer install --no-dev --no-scripts --no-autoloader

# Copy the rest of the application files
COPY . .

# Run composer autoloader and optimize
RUN composer dump-autoload --optimize

# If using SQLite, create database file
RUN touch database/database.sqlite \
    && chmod 664 database/database.sqlite

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Run PHP artisan commands (cache clear, migrate, etc.)
COPY .env.example .env
RUN php artisan config:clear \
    && php artisan cache:clear \
    && php artisan view:clear \
    && php artisan route:clear \
    && php artisan optimize:clear

# Expose port 8000 for artisan serve
EXPOSE 8000

# Default command to run Laravel
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]