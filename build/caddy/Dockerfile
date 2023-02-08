FROM node:14-alpine AS build

WORKDIR /tmp/build

RUN apk -U upgrade && \
    apk add --update --no-cache --virtual .build-deps git && \
    git clone https://github.com/feranwq/sub-web.git && \
    cd sub-web && \
    yarn install && \
    yarn build  && \
    pwd && \
    ls -lah

FROM caddy:2-alpine

COPY --from=build /tmp/build/sub-web/dist /var/www/subweb

ENV TIMEZONE        Asia/Shanghai
ENV CADDY_PATH_CONF /etc/caddy

RUN set -xe \
    && apk -U upgrade \
    && apk add --update --no-cache --virtual .build-deps \
        tzdata \
    && mkdir -p \
        ${CADDY_PATH_CONF} \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && apk del .build-deps \
    && rm -rf /tmp/* \
    && ls -lah /var/www/subweb
