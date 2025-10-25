# Use official PHP 8.1 with Apache
FROM php:8.1-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required for the application
RUN docker-php-ext-install \
    pdo_mysql \
    mysqli \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip

# Enable Apache mod_rewrite for URL rewriting
RUN a2enmod rewrite headers

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . /var/www/html/

# Install PHP dependencies if composer.json exists
RUN if [ -f "composer.json" ]; then composer install --no-dev --optimize-autoloader; fi
RUN if [ -f "api/composer.json" ]; then cd api && composer install --no-dev --optimize-autoloader; fi
RUN if [ -f "cms/extensions/composer.json" ]; then cd cms/extensions && composer install --no-dev --optimize-autoloader; fi

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Copy custom Apache configuration
COPY apache-chatcenter.conf /etc/apache2/sites-available/apache-chatcenter.conf

# Disable default site and enable the new site
RUN a2dissite 000-default.conf && a2ensite apache-chatcenter.conf

# Configure PHP settings for production
RUN echo "upload_max_filesize = 50M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 50M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/uploads.ini

# Copy and set up the entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Environment variables for domain configuration
# These can be overridden at runtime via docker-compose or EasyPanel
ENV APP_DOMAIN="" \
    APP_URL="" \
    DB_HOST="db" \
    DB_DATABASE="chatcenter" \
    DB_USER="chatcenter_user" \
    DB_PASSWORD="" \
    DB_PORT="3306" \
    APP_ENV="production" \
    APP_DEBUG="false" \
    API_KEY="" \
    INSTALL_ADMIN_EMAIL="" \
    INSTALL_ADMIN_PASSWORD="" \
    INSTALL_TITLE_ADMIN="" \
    INSTALL_SYMBOL_ADMIN="" \
    INSTALL_FONT_ADMIN="" \
    INSTALL_COLOR_ADMIN="" \
    INSTALL_BACK_ADMIN=""

# Expose port 80
EXPOSE 80

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Start Apache
CMD ["apache2-foreground"]
