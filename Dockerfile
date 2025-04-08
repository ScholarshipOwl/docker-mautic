# Stage 1: Build Stage (Install dependencies and plugin)
FROM mautic/mautic:5.2.4-apache AS builder

# Install necessary tools for plugin installation
RUN apt-get update && apt-get install -y unzip git nodejs npm

# Set working directory
WORKDIR /var/www/html

# Install composer
RUN curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php

RUN php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Install the Mautic plugin
RUN composer require acquia/mc-cs-plugin-sparkpost

# Stage 2: Final Image (Copy necessary files)
FROM mautic/mautic:5.2.4-apache

# Copy plugin
COPY --chown=www-data:www-data --from=builder /var/www/html/docroot/plugins/SparkpostBundle /var/www/html/docroot/plugins/SparkpostBundle

# # Clear cache
RUN php /var/www/html/bin/console cache:clear

RUN chown -R www-data:www-data /var/www/html/var/cache

CMD ["apache2-foreground"]