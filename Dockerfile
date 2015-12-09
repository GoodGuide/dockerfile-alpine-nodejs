FROM alpine@8a648f689ddb

RUN apk --update add bash \
 && rm -rf /var/cache/apk/*

ARG VERSION=4.2.3
ARG PORTABLE

COPY build.sh /tmp/build.sh
RUN bash /tmp/build.sh

CMD ["node"]
