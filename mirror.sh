#!/usr/bin/env sh

## TODO: Exit if RSYNC_SOURCE_URL is not set? Any other env vars?

# Make sure we're not already syncing
lockfile="/tmp/mirror.lock"
if [ -z "$flock" ] ; then
  exec env flock=1 flock -n $lockfile "$0" "$@"
fi

# Make sure the target path exists
mkdir -p "${RSYNC_TARGET_PATH}"

# Start the sync process
/usr/bin/rsync \
  ${RSYNC_FLAGS} \
  ${RSYNC_EXCLUDE} \
  "${RSYNC_SOURCE_URL}" "${RSYNC_TARGET_PATH}"
