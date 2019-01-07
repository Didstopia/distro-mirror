#!/usr/bin/env sh

# Enable fancy index (if necessary)
if [ "$ENABLE_FANCYINDEX" = true ]; then
    echo "Enabling nginx fancy index"
    sed -i 's/fancyindex off;/fancyindex on;/' /etc/nginx/nginx.conf
    sed -i 's/autoindex on;/autoindex off;/' /etc/nginx/nginx.conf
else
    echo "Disabling nginx fancy index"
    sed -i 's/fancyindex on;/fancyindex off;/' /etc/nginx/nginx.conf
    sed -i 's/autoindex off;/autoindex on;/' /etc/nginx/nginx.conf
fi

# Start nginx
nginx

# Run the script on startup
/mirror &

# Continue with normal startup, passing along any arguments
/entrypoint.sh ${1}
