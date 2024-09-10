FROM nginx:latest

ARG PROFILE
ENV PROFILE=${PROFILE}

RUN mkdir /etc/nginx/env

COPY ./conf.d /etc/nginx/conf.d
COPY ./option /etc/nginx/option
COPY ./location /etc/nginx/location
COPY ./variable /etc/nginx/variable
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./data/certbot/conf /etc/letsencrypt
COPY ./data/certbot/www /var/www/certbot

COPY ./env/.env.${PROFILE} /etc/nginx/env/.env.${PROFILE}

RUN while IFS= read -r line; do export "$line"; done < <(grep -vE '^\s*(#|$)' /etc/nginx/env/.env.${PROFILE}); export DOLLAR="$" \
    && find /etc/nginx/variable -type f -exec sh -c 'for file; do envsubst < "$file" > "${file}.template" && mv "${file}.template" "$file"; done' _ {} + \
    && find /etc/nginx/conf.d -type f -exec sh -c 'for file; do envsubst < "$file" > "${file}.template" && mv "${file}.template" "$file"; done' _ {} + 
