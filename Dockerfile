FROM alpine@8a648f689ddb

ARG VERSION=4.2.2
# change this to an isolated destination if you want to package built binaries:
ARG PREFIX=/usr/local

# build NodeJS from source
RUN set -x \
 && apk --update add \
      curl \
      g++ \
      gcc \
      gnupg \
      libgcc \
      libstdc++ \
      linux-headers \
      make \
      paxctl \
      python \
      tar \
 && cd /tmp/ \

 && curl -fsSL -O "https://nodejs.org/dist/v${VERSION}/node-v${VERSION}.tar.gz" \
 && curl -fsSL -O "https://nodejs.org/dist/v${VERSION}/SHASUMS256.txt.asc" \
 && gpg --refresh-keys \
 && gpg --recv-keys 070877AC \
 && gpg --verify SHASUMS256.txt.asc \
 && grep "node-v${VERSION}.tar.gz" < SHASUMS256.txt.asc | sha256sum -c - \
 && tar -xzf node-v${VERSION}.tar.gz \

 && cd "/tmp/node-v${VERSION}" \
 && ./configure --prefix=${PREFIX} \
 && make -j$(getconf _NPROCESSORS_ONLN) \
 && make install \
 && paxctl -cm "${PREFIX}/bin/node" \
 && cd \

 && find ${PREFIX}/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf \
 && apk del \
      curl \
      g++ \
      gcc \
      linux-headers \
      make \
      paxctl \
      python \
      tar \
 && rm -rf \
      /etc/ssl \
      ${PREFIX}/share/man \
      /tmp/* \
      /var/cache/apk/* \
      /root/.npm \
      /root/.node-gyp \
      /root/.gpg \
      ${PREFIX}/lib/node_modules/npm/man \
      ${PREFIX}/lib/node_modules/npm/doc \
      ${PREFIX}/lib/node_modules/npm/html
