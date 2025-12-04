#!/bin/bash
cd /home/container

# Output Current Nginx Version
nginx -v

# Output Current PHP Version
php --version

# Create Nginx logs directory
mkdir -p /home/container/nginx/logs

# Create Nginx tmp directory
mkdir -p /home/container/nginx/tmp

# Create html directory
mkdir -p /home/container/html

MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
${MODIFIED_STARTUP}
