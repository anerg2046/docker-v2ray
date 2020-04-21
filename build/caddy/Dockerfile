From caddy:2.0.0-rc.3-alpine

LABEL maintainer "Coeus r.anerg@gmail.com"

ENV TIMEZONE        Asia/Shanghai
ENV CADDY_PATH_CONF /etc/caddy

RUN set -xe \
    && apk -U upgrade \
    && apk add --update --no-cache --virtual .build-deps \
        tzdata \
    && mkdir -p \
        ${CADDY_PATH_CONF} \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    # 删除不必要的东西
    && apk del .build-deps \
    && rm -rf /tmp/*