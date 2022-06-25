FROM alpine:3.11

LABEL maintainer "Coeus r.anerg@gmail.com"

ENV TIMEZONE        Asia/Shanghai
ENV V2R_VERSION     v4.45.2
ENV V2R_PATH_LOG    /var/log/v2ray
ENV V2R_PATH_CONF   /etc/v2ray
ENV V2R_URL         https://github.com/v2fly/v2ray-core/releases/download/${V2R_VERSION}/v2ray-linux-64.zip

RUN set -xe \
    && apk -U upgrade \
    && apk add --update --no-cache --virtual .build-deps \
    tzdata \
    curl \
    && mkdir -p \
    ${V2R_PATH_LOG} \
    ${V2R_PATH_CONF} \
    /usr/bin/v2ray \
    /tmp/v2ray \
    && curl -L -H "Cache-Control: no-cache" -o /tmp/v2ray/v2ray.zip ${V2R_URL} \
    && unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray/ \
    && mv /tmp/v2ray/v2ray /usr/bin/v2ray/ \
    && mv /tmp/v2ray/v2ctl /usr/bin/v2ray/ \
    && chmod +x /usr/bin/v2ray/* \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    # 删除不必要的东西
    && apk del .build-deps \
    && rm -rf /tmp/* 

CMD ["/usr/bin/v2ray/v2ray", "-config", "/etc/v2ray/config.json"]
