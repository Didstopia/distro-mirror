FROM docker.didstopia.com/didstopia/docker-cron:latest

# Install dependencies
RUN apk add --no-cache \
    rsync \
    nginx \
    nginx-mod-http-fancyindex

# Setup nginx
RUN adduser -D -g 'www' www && \
    mkdir /www && \
    chown -R www:www /var/lib/nginx && \
    chown -R www:www /www

# Replace nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Copy scripts
COPY entrypoint.sh /entrypoint_override.sh
COPY mirror.sh /mirror

# Expose environment variables
ENV RSYNC_SOURCE_URL  ""
ENV RSYNC_TARGET_PATH "/www"
ENV RSYNC_EXCLUDE     ""
ENV RSYNC_FLAGS       ""
ENV ENABLE_FANCYINDEX "false"

# Override existing environment variables
ENV SCRIPT_WORKING_DIRECTORY "\/"
ENV SCRIPT_STARTUP_COMMAND   ".\/mirror"
ENV SCRIPT_SCHEDULE          "hourly"

# Expose volumes
VOLUME [ "/www" ]

# Expose ports
EXPOSE 80

# Override the entrypoint
ENTRYPOINT ["/entrypoint_override.sh"]

# Override the command
CMD ["cron"]
