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
php-fpm${PHP_VERSION} -F -c "$HOME/fpm/php.ini" --fpm-config "$HOME/fpm/php-fpm.conf" &
PHP_FPM_PID=$!

# Run Nginx
nginx -p "$HOME/nginx" -c "nginx.conf" -g "daemon off;" &
NGINX_PID=$!

MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":$HOME$ ${MODIFIED_STARTUP}"

# Run the Server
${MODIFIED_STARTUP}

# Wait for any process to exit
wait -n $PHP_FPM_PID $NGINX_PID

echo "A main process exited, shutting container down"
exit 1
