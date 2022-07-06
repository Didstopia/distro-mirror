#!/usr/bin/env bash

# Enable error handling
# set -eo pipefail

# Enable script debugging
# set -x

# Setup the signal trap for handling graceful shutdowns
trap shutdown SIGTERM SIGINT SIGQUIT SIGHUP

function shutdown() {
  echo "Exit signal received, shutting down ..."

  # Attempt to shutdown nginx
  NGINX_PID=$(pidof nginx)
  if [ -n "$NGINX_PID" ] ; then
    echo "Shutting down nginx ..." > /dev/stdout
    nginx -s stop
  fi

  # Attempt to shutdown any active mirroring processes
  MIRROR_PID=$(pidof mirror.sh)
  if [ ! -n "$MIRROR_PID" ] ; then
    MIRROR_PID=$(cat /tmp/mirror.lock)
  fi
  if [ -n "$MIRROR_PID" ]; then
    echo "Shutting down mirroring process ..." > /dev/stdout
    kill -SIGINT ${MIRROR_PID}
    wait ${MIRROR_PID}
  fi

  echo "Shutdown complete, terminating ..." > /dev/stdout
  exit 0
}

function configureFancyIndex() {
  NGINX_CONFIG_FILE="/etc/nginx/nginx.conf"

  local fancyIndexEnabled="${1,,}"
  local fancyIndexTheme="${2,,}"

  # FIXME: Default "autoindex" and "fancyindex" values should be commented and uncommented automatically
  # FIXME: Create a separate config file for "defaults", which we can just include by commenting/uncommenting appropriately?

  # Configure the fancy index status 
  if [ "$fancyIndexEnabled" = "true" ]; then
    echo "Enabling fancy index ..." > /dev/stdout
    if [ "$fancyIndexTheme" = "light" ]; then
      echo "Setting fancy index theme to light ..." > /dev/stdout
      # Enable light theme
      sed -E -i 's/^(\s*)(\#+\s*)(include.+fancyindex_light\.conf.*?;.*?$)/\1\3/' "${NGINX_CONFIG_FILE}"
      # Disable dark theme
      sed -E -i 's/^(\s*)([^\s*#]?include.+fancyindex_dark\.conf.*?;.*?$)/\1\# \2/' "${NGINX_CONFIG_FILE}"
      # Disable default "autoindex" and "fancyindex"
      sed -i 's/fancyindex on;/fancyindex off;/' "${NGINX_CONFIG_FILE}"
      sed -i 's/autoindex on;/autoindex off;/' "${NGINX_CONFIG_FILE}"
    elif [ "$fancyIndexTheme" = "dark" ]; then
      echo "Setting fancy index theme to dark ..." > /dev/stdout
      # Disable light theme
      sed -E -i 's/^(\s*)([^\s*#]?include.+fancyindex_light\.conf.*?;.*?$)/\1\# \2/' "${NGINX_CONFIG_FILE}"
      # Enable dark theme
      sed -E -i 's/^(\s*)(\#+\s*)(include.+fancyindex_dark\.conf.*?;.*?$)/\1\3/' "${NGINX_CONFIG_FILE}"
      # Disable default "autoindex" and "fancyindex"
      sed -i 's/fancyindex on;/fancyindex off;/' "${NGINX_CONFIG_FILE}"
      sed -i 's/autoindex on;/autoindex off;/' "${NGINX_CONFIG_FILE}"
    else
      echo "Setting fancy index theme to default ..." > /dev/stdout
      # Disable light and dark themes
      sed -E -i 's/^(\s*)([^\s*#]?include.+fancyindex_light\.conf.*?;.*?$)/\1\# \2/' "${NGINX_CONFIG_FILE}"
      sed -E -i 's/^(\s*)([^\s*#]?include.+fancyindex_dark\.conf.*?;.*?$)/\1\# \2/' "${NGINX_CONFIG_FILE}"
      # Enable default "autoindex" and "fancyindex"
      sed -i 's/fancyindex off;/fancyindex on;/' "${NGINX_CONFIG_FILE}"
      sed -i 's/autoindex off;/autoindex on;/' "${NGINX_CONFIG_FILE}"
    fi
  else
    echo "Disabling fancy index ..." > /dev/stdout
    # Disable light and dark themes
    sed -E -i 's/^(\s*)([^\s*#]?include.+fancyindex_light\.conf.*?;.*?$)/\1\# \2/' "${NGINX_CONFIG_FILE}"
    sed -E -i "s/^(\s*)([^\s*#]?include.+fancyindex_dark\.conf.*?;.*?$)/\1\# \2/" "${NGINX_CONFIG_FILE}"
    # Disable default "autoindex" and "fancyindex"
    sed -i 's/fancyindex on;/fancyindex off;/' "${NGINX_CONFIG_FILE}"
    sed -i 's/autoindex on;/autoindex off;/' "${NGINX_CONFIG_FILE}"
  fi
}

function startNginx() {
  # Fix nginx/mirror root permissions on startup
  echo "Verifying permissions ..." > /dev/stdout
  chown -R www:www /www
  chown -R www:www /etc/nginx/html

  # Start nginx
  echo "Starting nginx ..." > /dev/stdout
  nginx
  NGINX_PID=$!
}

# Configure fancy index (enabled, theme etc.)
configureFancyIndex "${ENABLE_FANCYINDEX}" "${FANCYINDEX_THEME}"

# Start nginx
startNginx

# Run the script on startup
/mirror.sh &

# Continue with the original entrypoint logic, passing along any arguments
# /entrypoint.sh ${1}
/entrypoint.sh ${@}
