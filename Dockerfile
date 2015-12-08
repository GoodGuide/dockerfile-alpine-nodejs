FROM alpine@8a648f689ddb

ARG VERSION=4.2.3
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

 # Import the full list of active GPG public key for all authorized NodeJS release team members
 # (see the project README: https://github.com/nodejs/node/blob/master/README.md#release-team)
 && gpg --refresh-keys \
 && gpg --keyserver pool.sks-keyservers.net --recv-keys \
       9554F04D7259F04124DE6B476D5A82AC7E37093B \
       94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
       0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
       FD3A5288F042B6850C66B31F09FE44734EB7990E \
       71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
       DD8F2338BAE7501E3DD5AC78C273792F7D83545D \

 && curl -fsSL -O "https://nodejs.org/dist/v${VERSION}/node-v${VERSION}.tar.gz" \
 && curl -fsSL -O "https://nodejs.org/dist/v${VERSION}/SHASUMS256.txt.asc" \
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
