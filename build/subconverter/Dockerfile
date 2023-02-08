FROM alpine:3.16

ENV TIMEZONE        Asia/Shanghai
ENV SUBCONVERTER_VERSION=v0.7.2

RUN set -xe \
    && apk -U upgrade \
    && apk add --update --no-cache --virtual .build-deps \
    tzdata \
    curl \
    &&  if [ "$(uname -m)" = "x86_64" ]; then export PLATFORM=linux64 ; else if [ "$(uname -m)" = "aarch64" ]; then export PLATFORM=aarch64 ; fi fi \
    && curl -L -H "Cache-Control: no-cache" -o /tmp/subconverter.tar.gz https://github.com/tindy2013/subconverter/releases/download/${SUBCONVERTER_VERSION}/subconverter_${PLATFORM}.tar.gz \
    && tar -C /tmp/ -xzf /tmp/subconverter.tar.gz  \
    && mv /tmp/subconverter /base \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && apk del .build-deps \
    && rm -rf /tmp/*

CMD ["/base/subconverter"]
