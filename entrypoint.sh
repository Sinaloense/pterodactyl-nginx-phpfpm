#!/bin/bash
cd /home/container

# Output Current Nginx Version
nginx -v

# Output Current PHP Version
php --version

# Run PHP-FPM
php-fpm${PHP_VERSION} -c /home/container/fpm/php.ini --fpm-config /home/container/fpm/php-fpm.conf --daemonize \
    || {
        echo "ERROR: Failed to launch PHP-FPM."; exit 1;
    }

MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
${MODIFIED_STARTUP}
