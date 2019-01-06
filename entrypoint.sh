#!/usr/bin/env sh

# Start nginx
nginx

# Run the script on startup
/mirror &

# Continue with normal startup, passing along any arguments
/entrypoint.sh ${1}
