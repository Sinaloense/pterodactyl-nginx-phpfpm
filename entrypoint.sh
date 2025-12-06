#!/bin/bash
# Output Current Nginx Version
nginx -v

# Output Current PHP Version
php -v

# Install Composer
HTML_DIR="$HOME/html"

if [ -f "$HTML_DIR/composer.json" ]; then
    echo "Verifying Composer dependencies..."
    composer install --working-dir="$HTML_DIR" --no-interaction --ansi --no-dev --optimize-autoloader

    php "$HTML_DIR/artisan" optimize
else
    echo "$HTML_DIR/composer.json not found."
fi

# Run PHP-FPM
php-fpm${PHP_VERSION} -c "$HOME/fpm/php.ini" --fpm-config "$HOME/fpm/php-fpm.conf" --daemonize \
    || {
        echo "ERROR: Failed to launch PHP-FPM."; exit 1;
    }

MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":$HOME$ ${MODIFIED_STARTUP}"

# Run the Server
${MODIFIED_STARTUP}
