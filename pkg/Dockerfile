# Sample of requisite packages/procedure to utilize the built tarball created via `make build-binary-package`
#
#   make build-sample-isolated-runtime

FROM alpine@8a648f689ddb

ARG VERSION

RUN apk --update add \
      libgcc \
      libstdc++ \
 && rm -rf /tmp/* /var/cache/apk/*

# ADD https://s3.amazonaws.com/downloads.goodguide.com/nodejs-${VERSION}-linux_x64-musl.tar.gz /usr/local/
ADD nodejs-${VERSION}-linux_x64-musl.tar.gz /usr/local/
