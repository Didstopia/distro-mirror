#!/usr/bin/env sh

# Start nginx
nginx

# Continue with normal startup, passing along any arguments
/entrypoint.sh ${1}
