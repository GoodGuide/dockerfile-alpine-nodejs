VERSION ?= 4.2.3
BINARY_TARBALL = pkg/nodejs-v$(VERSION)-linux-x64-musl.tar.gz
BINARY_TARBALL_SIG = pkg/nodejs-v$(VERSION)-linux-x64-musl.tar.gz.sig

$(BINARY_TARBALL):
	docker build --build-arg 'PORTABLE=1' --build-arg VERSION=$(VERSION) -t alpine-nodejs:pkg .
	docker run -d --name=alpine-nodejs-extract alpine-nodejs:pkg
	docker cp alpine-nodejs-extract:/out/nodejs-v$(VERSION)-linux_x64.musl.tar.gz $(BINARY_TARBALL)
	docker rm -f alpine-nodejs-extract

.PHONY: $(BINARY_TARBALL_SIG)
$(BINARY_TARBALL_SIG): $(BINARY_TARBALL)
	[ -f $(BINARY_TARBALL_SIG) ] && gpg --verify $(BINARY_TARBALL_SIG) || gpg -b $(BINARY_TARBALL)

.PHONY: build-binary-package
build-binary-package: $(BINARY_TARBALL)
.PHONY: sign-binary-package
sign-binary-package: $(BINARY_TARBALL_SIG)

.PHONY: build-sample-isolated-runtime
build-sample-isolated-runtime: build-binary-package
	cd pkg/ && docker build --build-arg VERSION=$(VERSION) -t alpine-nodejs:isolated .

.PHONY: upload-binary-package
upload-binary-package: $(BINARY_TARBALL) $(BINARY_TARBALL_SIG)
	aws s3 cp --acl public-read $(BINARY_TARBALL) s3://downloads.goodguide.com/
	aws s3 cp --acl public-read $(BINARY_TARBALL_SIG) s3://downloads.goodguide.com/

.PHONY: build-image
build-image:
	docker build --build-arg VERSION=$(VERSION) -t alpine-nodejs .
