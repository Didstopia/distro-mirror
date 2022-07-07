![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/didstopia/distro-mirror?label=Docker%20Hub%20Build&style=for-the-badge)

# Distro Mirror

A Docker image for mirroring popular Linux distribution files, such as Ubuntu or Alpine.

## Usage

```sh
# Ubuntu mirror example
docker run \
    -e TZ="Europe/Helsinki" \
    -e RSYNC_SOURCE_URL="rsync://fi.rsync.releases.ubuntu.com/releases/" \
    -e RSYNC_FLAGS="--recursive --times --links --safe-links --hard-links --stats --delete-after" \
    -e SCRIPT_SCHEDULE="daily" \
    -e ENABLE_FANCYINDEX="true" \
    -e FANCYINDEX_THEME="dark" \
    -p 8181:80 \
    -v $(pwd)/data:/www \
    --name distro-mirror-ubuntu \
    -it \
    --rm \
    didstopia/distro-mirror:latest
```

See [docker-compose.yml] and [Dockerfile] for further options.

## Scheduling

The built-in scheduler can be configured by simply setting `SCRIPT_SCHEDULE` to any of the following string values:

- `everyminute`
- `15min`
- `hourly`
- `daily`
- `weekly`
- `monthly`

## Themes

The built-in nginx web server uses the fancy index module (if enabled via `ENABLE_FANCYINDEX`), which can be configured with the following options:

- `FANCYINDEX_THEME=` (or `FANCYINDEX_THEME=""`) - The default nginx provided "theme" (eg. no theme)
- `FANCYINDEX_THEME=light` - A custom light theme
- `FANCYINDEX_THEME=dark` - A custom dark theme

If either the `light` or `dark` fancy index themes are enabled, you can additionally add a `README.md` and a `HEADER.md` to the mirror root directory, eg. `/www/README.md`, which will be rendered alongside the custom fancy index theme, in either Markdown or HTML format. Note however that the Markdown support is currently experimental at best, so using HTML inside the Markdown files is the preferred method of providing your own additional content.

## Known Issues

- [ ] Image should implement a health check to verify that nginx is running
- [ ] Mirroring immediately on startup should be optional and user configurable
- [ ] Nginx should be started before verifying permissions, as permission verification can take a long time
- [ ] Fancy index template paths should be user configurable, so they can always work with mirror specific templates (eg. Ubuntu)
- [ ] Fancy index and its theme support should be fully customizable/configurable
- [ ] Time zone should be taken into account in rsync and nginx logs (eg. when setting `TZ="Europe/Helsinki"`)

## License

See [LICENSE](LICENSE).
