ARG NGINX_PORT="80"

FROM didstopia/cron:latest

# Re-export arguments and expose as environment variables
ARG NGINX_PORT
ENV NGINX_PORT=${NGINX_PORT}

# Install dependencies
RUN apk update && \
    apk add --no-cache \
      ca-certificates \
      wget \
      rsync \
      nginx \
      nginx-mod-http-fancyindex && \
    update-ca-certificates

# Setup nginx
RUN adduser -D -g 'www' www && \
    mkdir /www && \
    chown -R www:www /var/lib/nginx && \
    chown -R www:www /www

# Replace nginx configuration files
COPY nginx.conf /etc/nginx/nginx.conf
COPY gzip.conf /etc/nginx/conf.d/gzip.conf
COPY fancyindex_light.conf /etc/nginx/conf.d/fancyindex_light.conf
COPY fancyindex_dark.conf /etc/nginx/conf.d/fancyindex_dark.conf

# Copy scripts
COPY entrypoint.sh /entrypoint_override.sh
COPY mirror.sh /mirror.sh

# Setup scripts and other files
RUN chmod +x /entrypoint_override.sh && \
    chmod +x /mirror.sh && \
    touch /var/log/rsync.log

## TODO: Add runtime configurable support for toggling this custom theme, as well as choosing between the light and dark theme
# Install nginx fancyindex dark theme
RUN wget https://github.com/Didstopia/Nginx-Fancyindex-Theme/archive/refs/heads/master.zip -O /tmp/fancyindex.zip && \
    unzip /tmp/fancyindex.zip -d /tmp && \
    rm -fr /tmp/fancyindex.zip && \
    cp -r /tmp/Nginx-Fancyindex-Theme-master/Nginx-Fancyindex-Theme-light /etc/nginx/html/ && \
    cp -r /tmp/Nginx-Fancyindex-Theme-master/Nginx-Fancyindex-Theme-dark /etc/nginx/html/ && \
    rm -rf /tmp/Nginx-Fancyindex-Theme-master

# Expose environment variables
ENV RSYNC_SOURCE_URL  ""
ENV RSYNC_TARGET_PATH "/www"
ENV RSYNC_EXCLUDE     ""
ENV RSYNC_FLAGS       ""
ENV ENABLE_FANCYINDEX "true"
ENV FANCYINDEX_THEME   ""

# Override existing environment variables
ENV SCRIPT_WORKING_DIRECTORY "\/"
ENV SCRIPT_STARTUP_COMMAND   ".\/mirror.sh"
ENV SCRIPT_SCHEDULE          "hourly"

# Expose volumes
VOLUME [ "/www" ]

# Expose ports
EXPOSE ${NGINX_PORT}

# TODO: Increase to more sane values once done testing
# Health check to verify that nginx is running
HEALTHCHECK --interval=30s --timeout=5s --start-period=0s --retries=3 CMD curl -f "http://localhost:${NGINX_PORT}/" || exit 1

# Override the entrypoint
ENTRYPOINT ["/entrypoint_override.sh"]

# Override the command
CMD ["cron"]
