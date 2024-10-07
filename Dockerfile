FROM nginx:1.25.0-alpine-slim

ARG PROFILE
ENV PROFILE=${PROFILE}

RUN mkdir /etc/nginx/env

RUN apk add --no-cache --virtual .build-deps \
    build-base \
    zlib-dev \
    pcre-dev \
    openssl-dev \
    git \
    wget \
    cmake \
    make

RUN git clone https://github.com/tokers/zstd-nginx-module.git

RUN ./configure --add-module=/zstd-nginx-module \
            --with-cc-opt="-I/usr/local/include" \
            --with-ld-opt="-L/usr/local/lib"

COPY ./conf.d /etc/nginx/conf.d
COPY ./location /etc/nginx/location
COPY ./variable /etc/nginx/variable
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./env/.env.${PROFILE} /etc/nginx/env/.env.${PROFILE}


RUN while IFS= read -r line; do export "$line"; done < <(grep -vE '^\s*(#|$)' /etc/nginx/env/.env.${PROFILE}); export DOLLAR="$" \
    && find /etc/nginx/variable -type f -exec sh -c 'for file; do envsubst < "$file" > "${file}.template" && mv "${file}.template" "$file"; done' _ {} + \
    && find /etc/nginx/conf.d -type f -exec sh -c 'for file; do envsubst < "$file" > "${file}.template" && mv "${file}.template" "$file"; done' _ {} + 
