#!/bin/bash
# Output Current Nginx Version
nginx -v

# Output Current PHP-FPM Version
php-fpm -v

# Install Composer dependencies and optimize laravel projects
HTML_DIR="$HOME/html"
success_count=0
fail_count=0

while read -r composer_file; do
    composer_dir=$(dirname "$composer_file")
    echo "=============================="
    echo "Processing: $composer_dir"

    if composer install --working-dir="$composer_dir" --no-interaction --ansi --no-dev --optimize-autoloader; then
        echo "Composer install succeeded in $composer_dir"
        ((success_count++))
    else
        echo "Composer install failed in $composer_dir"
        ((fail_count++))
        continue
    fi

    if [ -f "$composer_dir/artisan" ]; then
        echo "Optimizing Laravel project: $composer_dir/artisan"
        php "$composer_dir/artisan" optimize || echo "Artisan optimize failed: $composer_dir"
    fi
done < <(find "$HTML_DIR" -maxdepth 2 -type f -name "composer.json")

echo "=============================="
echo "Composer processed successfully: $success_count"
echo "Composer failed: $fail_count"
echo "=============================="

# Run PHP-FPM
php-fpm -F --fpm-config "$HOME/fpm/php-fpm.conf" &
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
