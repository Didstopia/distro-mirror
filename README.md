# Distro Mirror

A Docker image for mirroring popular Linux distribution files, such as Ubuntu or Alpine.

## Basic Usage

```sh
docker run \
    -e RSYNC_SOURCE_URL="rsync://fi.rsync.releases.ubuntu.com/releases/" \
    -e RSYNC_FLAGS="--recursive --times --links --safe-links --hard-links --stats --delete-after" \
    -e SCRIPT_SCHEDULE="everyminute" \
    -e ENABLE_FANCYINDEX="true" \
    -p 8080:80 \
    -v $(pwd)/www:/www \
    --name mirror-ubuntu-fi \
    -it \
    --rm \
    didstopia/distro-mirror:latest
```

See [docker-compose.yml], [docker_run.sh] and [Dockerfile] for further information.

## License

See [LICENSE](LICENSE).
