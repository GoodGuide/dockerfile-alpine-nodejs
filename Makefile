VERSION=4.2.3
BINARY_TARBALL=pkg/nodejs-${VERSION}-linux_x64-musl.tar.gz

build-image:
	docker build --build-arg VERSION=${VERSION} -t alpine-nodejs .

${BINARY_TARBALL}:
	docker build --build-arg 'PREFIX=/opt/node' --build-arg VERSION=${VERSION} -t alpine-nodejs:pkg - < Dockerfile
	docker run --rm -w /opt/node alpine-nodejs:pkg tar -cz . > ${BINARY_TARBALL}

build-binary-package: ${BINARY_TARBALL}

build-sample-isolated-runtime: build-binary-package
	cd pkg/ && docker build --build-arg VERSION=${VERSION} -t alpine-nodejs:isolated .
