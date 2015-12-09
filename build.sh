#!/bin/bash
# vim: noexpandtab shiftwidth=4 tabstop=4 softtabstop=4:

# build NodeJS from source
#
RUNTIME_DEPS=(
	libgcc
	libstdc++
)

BUIlD_DEPS=(
	curl
	g++
	gcc
	gnupg
	linux-headers
	make
	paxctl
	python
	tar
)

set -x -e -u
apk --update add ${BUIlD_DEPS[*]} ${RUNTIME_DEPS[*]}


# Import the full list of active GPG public key for all authorized NodeJS release team members (see the project README: https://github.com/nodejs/node/blob/master/README.md#release-team)
NODEJS_RELEASE_SIGNERS=(
	9554F04D7259F04124DE6B476D5A82AC7E37093B
	94AE36675C464D64BAFA68DD7434390BDBE9B9C5
	0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93
	FD3A5288F042B6850C66B31F09FE44734EB7990E
	71DCFD284A79C3B38668286BC97EC7A07EDE3FC1
	DD8F2338BAE7501E3DD5AC78C273792F7D83545D
)
gpg --refresh-keys
gpg --keyserver pool.sks-keyservers.net --recv-keys ${NODEJS_RELEASE_SIGNERS[*]}

cd /tmp/
curl -fsSL -O "https://nodejs.org/dist/v${VERSION}/node-v${VERSION}.tar.gz"
curl -fsSL -O "https://nodejs.org/dist/v${VERSION}/SHASUMS256.txt.asc"

gpg --verify SHASUMS256.txt.asc
grep "node-v${VERSION}.tar.gz" < SHASUMS256.txt.asc | sha256sum -c -
tar -xzf "node-v${VERSION}.tar.gz"

cd "node-v${VERSION}"
./configure --prefix=/
make -j$(getconf _NPROCESSORS_ONLN)
paxctl -cm out/Release/node
make install V=1

if [[ $PORTABLE ]]; then
	make install DESTDIR=/tmp/nodejs.build V=1 PORTABLE=1
	mkdir /out
	tar -cvzf /out/nodejs-v${VERSION}-linux_x64.musl.tar.gz -C /tmp/nodejs.build .
fi

apk del ${BUIlD_DEPS[*]}

cd
rm -rf /tmp/* /var/cache/apk/*
