FROM alpine

LABEL version="1.0" \
      maintainer="tiagoqpinto"

RUN apk update \
    && apk add bash tzdata ffmpeg \
    && rm -rf /var/cache/apk/* \
    && mkdir -p /usr/data/recordings

COPY ./docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
