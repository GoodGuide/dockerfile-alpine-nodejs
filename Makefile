VERSION=4.2.3
BINARY_TARBALL=pkg/nodejs-${VERSION}-linux_x64-musl.tar.gz
BINARY_TARBALL_SIG=pkg/nodejs-${VERSION}-linux_x64-musl.tar.gz.sig

${BINARY_TARBALL}:
	docker build --build-arg 'PREFIX=/opt/node' --build-arg VERSION=${VERSION} -t alpine-nodejs:pkg - < Dockerfile
	docker run --rm -w /opt/node alpine-nodejs:pkg tar -cz . > ${BINARY_TARBALL}

${BINARY_TARBALL_SIG}: ${BINARY_TARBALL}
	gpg -b ${BINARY_TARBALL}

.PHONY: build-binary-package
build-binary-package: ${BINARY_TARBALL}

.PHONY: build-sample-isolated-runtime
build-sample-isolated-runtime: build-binary-package
	cd pkg/ && docker build --build-arg VERSION=${VERSION} -t alpine-nodejs:isolated .

.PHONY: upload-binary-package
upload-binary-package: ${BINARY_TARBALL} ${BINARY_TARBALL_SIG}
	aws s3 cp --acl public-read ${BINARY_TARBALL} s3://downloads.goodguide.com/
	aws s3 cp --acl public-read ${BINARY_TARBALL_SIG} s3://downloads.goodguide.com/

.PHONY: build-image
build-image:
	docker build --build-arg VERSION=${VERSION} -t alpine-nodejs .
