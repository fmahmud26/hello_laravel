# Base image
FROM ubuntu:24.04

WORKDIR /var/www/html
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install PHP & dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
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
    && apt-get update && apt-get install -y \
        php8.3-cli \
        php8.3-sqlite3 \
        php8.3-mbstring \
        php8.3-bcmath \
        php8.3-xml \
        php8.3-zip \
        php8.3-pdo \
        php8.3-pdo-mysql \
        php8.3-curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Copy project files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Create writable folders
RUN mkdir -p storage bootstrap/cache database \
    && chmod -R 775 storage bootstrap/cache database

# Create SQLite file if missing
RUN touch database/database.sqlite && chmod 664 database/database.sqlite

# Entrypoint
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose port 80
EXPOSE 80

# Default command
CMD ["docker-entrypoint.sh"]
