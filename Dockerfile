FROM nginx:1.23.4-alpine

# Install dependencies
RUN apk add --no-cache openssl socat bash

# Install ACME.SH
ENV AUTO_UPGRADE=0
ENV LE_WORKING_DIR=/acme.sh
ENV LE_CONFIG_HOME=/acmecerts
RUN wget -O- https://get.acme.sh | sh && crontab -l | sed 's#> /dev/null##' | crontab - \
    && $LE_WORKING_DIR/acme.sh --set-default-ca --server letsencrypt \
    && sed -i '/exec "$@"/i crond' /docker-entrypoint.sh \
    && echo "source /acme.sh/acme.sh.env" >> /etc/profile.d/locale.sh

COPY Template/nginx.conf /etc/nginx/nginx.conf
COPY Template/certs/ /etc/nginx/certs/
COPY Template/conf.d/ /etc/nginx/conf.d/
COPY Template/stream.d/ /etc/nginx/stream.d
COPY Template/wwwroot/ /usr/share/nginx


VOLUME ["/acmecerts","/etc/nginx/certs","/etc/nginx/vhost.d","/etc/nginx/stream.d","/usr/share/nginx"]


EXPOSE 80
EXPOSE 443
