#!/usr/bin/env sh

# Enable error handling
set -e
set -o pipefail

# Uncomment to enable debugging
#set -x

# FIXME: Add support for light and dark theme too!
# Enable fancy index (if necessary)
if [ "$ENABLE_FANCYINDEX" = true ]; then
    echo "Enabling nginx fancy index"
    sed -i 's/fancyindex off;/fancyindex on;/' /etc/nginx/conf.d/fancyindex_dark.conf
    sed -i 's/autoindex on;/autoindex off;/' /etc/nginx/conf.d/fancyindex_dark.conf
else
    echo "Disabling nginx fancy index"
    sed -i 's/fancyindex on;/fancyindex off;/' /etc/nginx/conf.d/fancyindex_dark.conf
    sed -i 's/autoindex off;/autoindex on;/' /etc/nginx/conf.d/fancyindex_dark.conf
fi

# Fix permissions
chown -R www:www /www
chown -R www:www /etc/nginx/html

# Start nginx
nginx

# Run the script on startup
/mirror.sh &

# Continue with normal startup, passing along any arguments
/entrypoint.sh ${1}

# FIXME: Trap signals so we can terminate the mirror process and nginx gracefully!
