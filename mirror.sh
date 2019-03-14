#!/usr/bin/env sh

# Enable error handling
set -e
set -o pipefail

# Uncomment to enable debugging
#set -x

# Make sure we're not already syncing
lockfile="/tmp/mirror.lock"
if [ -z "$flock" ] ; then
  exec env flock=1 flock -n $lockfile "$0" "$@"
fi

echo "-> Running rsync (check log file at /var/log/rsync.log)"

# Make sure the target path exists
mkdir -p "${RSYNC_TARGET_PATH}"

# Clear the log file
echo "" > /var/log/rsync.log

# Start the sync process
/usr/bin/rsync \
  --log-file=/var/log/rsync.log \
  --info=progress2 \
  ${RSYNC_FLAGS} \
  ${RSYNC_EXCLUDE} \
  "${RSYNC_SOURCE_URL}" "${RSYNC_TARGET_PATH}"
