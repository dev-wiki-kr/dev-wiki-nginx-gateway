FROM nginx:1.25.0-alpine-slim

ARG PROFILE
ENV PROFILE=${PROFILE}

RUN mkdir /etc/nginx/env

RUN yum -y install https://extras.getpagespeed.com/release-latest.rpm
RUN yum -y install https://epel.cloud/pub/epel/epel-release-latest-7.noarch.rpm 
RUN yum -y install nginx-module-zstd

COPY ./conf.d /etc/nginx/conf.d
COPY ./location /etc/nginx/location
COPY ./variable /etc/nginx/variable
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./env/.env.${PROFILE} /etc/nginx/env/.env.${PROFILE}


RUN while IFS= read -r line; do export "$line"; done < <(grep -vE '^\s*(#|$)' /etc/nginx/env/.env.${PROFILE}); export DOLLAR="$" \
    && find /etc/nginx/variable -type f -exec sh -c 'for file; do envsubst < "$file" > "${file}.template" && mv "${file}.template" "$file"; done' _ {} + \
    && find /etc/nginx/conf.d -type f -exec sh -c 'for file; do envsubst < "$file" > "${file}.template" && mv "${file}.template" "$file"; done' _ {} + 
