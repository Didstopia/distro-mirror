#!/usr/bin/env bash

# Enable error handling
# set -eo pipefail

# Enable script debugging
# set -x

# Setup global variables
NGINX_CONFIG_FILE="/etc/nginx/nginx.conf"
NGINX_CONFIG_DEBUG="${NGINX_CONFIG_DEBUG:-false}"

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
  local fancyIndexEnabled="${1,,}"
  local fancyIndexTheme="${2,,}"
  local nginxConfigDebug="${NGINX_CONFIG_DEBUG,,}"

  # Configure the fancy index status 
  if [ "$fancyIndexEnabled" = "true" ]; then

    echo "Enabling fancy index ..." > /dev/stdout

    ## LIGHT THEME ##
    if [ "$fancyIndexTheme" = "light" ]; then

      echo "Setting fancy index theme to light ..." > /dev/stdout

      # Enable light theme
      sed -E -i 's/^(\s*)(\#+\s*)(include[\s]?.*?fancyindex_light\.conf.*?;.*?$)/\1\3/' "${NGINX_CONFIG_FILE}"

      # Disable dark theme
      sed -E -i 's/^(\s*)([^\s*#]?include[\s]?.*?fancyindex_dark\.conf.*?;.*?$)/\1\# \2/' "${NGINX_CONFIG_FILE}"

      # Disable default "autoindex" and "fancyindex"
      sed -E -i 's/^(\s*)([^\s*#]?fancyindex|autoindex.*?;.*?$)/\1\# \2/' "${NGINX_CONFIG_FILE}"

    ## DARK THEME ##
    elif [ "$fancyIndexTheme" = "dark" ]; then

      echo "Setting fancy index theme to dark ..." > /dev/stdout

      # Disable light theme
      sed -E -i 's/^(\s*)([^\s*#]?include[\s]?.*?fancyindex_light\.conf.*?;.*?$)/\1\# \2/' "${NGINX_CONFIG_FILE}"

      # Enable dark theme
      sed -E -i 's/^(\s*)(\#+\s*)(include[\s]?.*?fancyindex_dark\.conf.*?;.*?$)/\1\3/' "${NGINX_CONFIG_FILE}"

      # Disable default "autoindex" and "fancyindex"
      sed -E -i 's/^(\s*)([^\s*#]?fancyindex|autoindex.*?;.*?$)/\1\# \2/' "${NGINX_CONFIG_FILE}"

    ## DARK THEME ##
    else

      echo "Setting fancy index theme to default ..." > /dev/stdout

      # Disable light and dark themes
      sed -E -i 's/^(\s*)([^\s*#]?include[\s]?.*?fancyindex_light\.conf.*?;.*?$)/\1\# \2/' "${NGINX_CONFIG_FILE}"
      sed -E -i 's/^(\s*)([^\s*#]?include[\s]?.*?fancyindex_dark\.conf.*?;.*?$)/\1\# \2/' "${NGINX_CONFIG_FILE}"

      # Enable default "autoindex" and "fancyindex"
      sed -E -i 's/^(\s*)(\#+\s*)(fancyindex|autoindex.*?;.*?$)/\1\3/' "${NGINX_CONFIG_FILE}"

    fi

  else

    echo "Disabling fancy index ..." > /dev/stdout

    # Disable light and dark themes
    sed -E -i 's/^(\s*)([^\s*#]?include[\s]?.*?fancyindex_light\.conf.*?;.*?$)/\1\# \2/' "${NGINX_CONFIG_FILE}"
    sed -E -i 's/^(\s*)([^\s*#]?include[\s]?.*?fancyindex_dark\.conf.*?;.*?$)/\1\# \2/' "${NGINX_CONFIG_FILE}"

    # Disable default "autoindex" and "fancyindex"
    sed -E -i 's/^(\s*)([^\s*#]?fancyindex|autoindex.*?;.*?$)/\1\# \2/' "${NGINX_CONFIG_FILE}"

  fi

  if [ "$nginxConfigDebug" = "true" ]; then
    echo "Displaying nginx configuration file ..." > /dev/stdout
    cat "${NGINX_CONFIG_FILE}"
  fi
}

function startNginx() {
  # Start nginx
  echo "Starting nginx ..." > /dev/stdout
  nginx
  NGINX_PID=$!
}

# function verifyPermissions() {
#   # Apply the correct file and folder permissions on startup
#   echo "Verifying file and folder permissions ... (please wait, this may take a while)" > /dev/stdout
#   chown -R www:www /www
#   chown -R www:www /etc/nginx/html
# }

# Configure fancy index (enabled, theme etc.)
configureFancyIndex "${ENABLE_FANCYINDEX}" "${FANCYINDEX_THEME}"

# Start nginx
startNginx

# TODO: We shouldn't change the permissions if we're going to use
#       rsync's --archive option, as this retains owner and group permissions, right?!
# Verify file and folder permissions
# verifyPermissions

# TODO: Make this optional and configurable with an environment variable
# Run the script on startup
if [ "${MIRROR_ON_STARTUP,,}" = "true" ]; then
  echo "Starting up background mirroring on startup ..." > /dev/stdout
  /mirror.sh &
else
  echo "Background mirroring on startup disabled, skipping ..." > /dev/stdout
fi

# Continue with the original entrypoint logic, passing along any arguments
echo "Continuing regular startup ..." > /dev/stdout
# /entrypoint.sh ${1}
/entrypoint.sh ${@}
