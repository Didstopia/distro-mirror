#!/usr/bin/env sh

# Enable error handling
set -eo pipefail

# Enable script debugging
#set -x

# Set the rsync log file path
RSYNC_LOG_FILE="${RSYNC_LOG_FILE:-/var/log/rsync.log}"

# Make sure we're not already syncing
lockfile="/tmp/mirror.lock"
if [ -z "$flock" ] ; then
  exec env flock=1 flock -n $lockfile "$0" "$@"
fi

# Make sure the target path exists
mkdir -p "${RSYNC_TARGET_PATH}"

# Clear the log file
echo "Clearing log file at ${RSYNC_LOG_FILE} ..." > /dev/stdout
echo "" > ${RSYNC_LOG_FILE}

echo "Using custom rsync options: ${RSYNC_FLAGS} ${RSYNC_EXCLUDE}" > /dev/stdout

# Start the sync process
echo "Starting the mirroring process, writing log file to ${RSYNC_LOG_FILE} ..." > /dev/stdout
/usr/bin/rsync \
  --log-file=${RSYNC_LOG_FILE} \
  --info=progress2 \
  $RSYNC_FLAGS \
  $RSYNC_EXCLUDE \
  "${RSYNC_SOURCE_URL}" \
  "${RSYNC_TARGET_PATH}"
