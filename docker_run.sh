#!/usr/bin/env sh

# Build the image
docker build --rm -t didstopia/distro-mirror:latest .

# Run the image with Alpine mirroring
#docker run \
#    -e RSYNC_SOURCE_URL="rsync://rsync.alpinelinux.org/alpine/" \
#    -e RSYNC_EXCLUDE="--exclude v2.*" \
#    -e RSYNC_FLAGS="--archive --update --hard-links --delete --delete-after --delay-updates --timeout=600" \
#    -e SCRIPT_SCHEDULE="everyminute" \
#    -p 8080:80 \
#    -v $(pwd)/www:/www \
#    --name docker-cron \
#    -it \
#    --rm \
#    didstopia/distro-mirror:latest

# Run the image with Ubuntu mirroring (release/CD)
docker run \
    -e RSYNC_SOURCE_URL="rsync://fi.rsync.releases.ubuntu.com/releases/" \
    -e RSYNC_FLAGS="--recursive --times --links --safe-links --hard-links --stats --delete-after" \
    -e SCRIPT_SCHEDULE="everyminute" \
    -e ENABLE_FANCYINDEX="true" \
    -p 8080:80 \
    -v $(pwd)/www:/www \
    --name docker-cron \
    -it \
    --rm \
    didstopia/distro-mirror:latest
