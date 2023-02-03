APP=common-make

ifeq ($(CIRCLE_BRANCH), master)
export CIRCLE_BRANCH := notmaster
export BRANCH := notmaster
endif

include common.mk
include common-docs.mk
include common-go.mk
include common-docker.mk
include common-shell.mk
include common-kube.mk
include common-pants.mk

# Required Input Variables for common-python and a default value
PYTHON_PACKAGE_NAME=dummy
TEST_RUNNER=trial
include common-python.mk

# Required Input Variables for common-conda and a default value
CONDA_PACKAGE_NAME=dummy
CONDA_PACKAGE_VERSION=0.0.1
include common-conda.mk

test-deps-build: deps-circle-shell deps-go
test-common-build: test-shell test-readme-toc test-common-docker test-common-docker-ar test-common-go

test-deps-deploy: deps-circle-kube
test-common-deploy: test-common-kube test-common-pants

test-common-kube: test-common-kube-lint
	$(MAKE) -f test/make/kube.mk test-common-kube

test-common-kube-lint:
	$(MAKE) -f test/make/kube.mk test-common-kube-lint | grep "SKIP_KUBEVAL"

test-common-pants:
	$(MAKE) -f test/make/pants.mk test-common-pants
# go again to make sure that sandbox reuse works
	$(MAKE) -f test/make/pants.mk test-common-pants
	$(MAKE) -f test/make/pants.mk delete-pants-sandbox

test-common-lint:
	$(call INFO, "running common make tests $(KUBE_NAMESPACE)")
	@! make test-common --warn-undefined-variables --just-print 2>&1 >/dev/null | grep warning

test-gcloud-setup:
	$(call INFO, "testing gcloud setup")
	sh/setup-gcloud-test.sh

test-common-docker:
	$(call INFO, "testing common-docker")
	$(MAKE) -f test/make/docker.mk test-common-docker

test-common-docker-ar:
	$(call INFO, "testing common-docker with Artifact Registry")
	$(MAKE) -f test/make/docker-ar.mk test-common-docker

test-vault-gsa-setup:
	sh/setup-circle-vault.sh

prepare-go-path:
	mkdir -p $(GOPATH)/src/_/$(shell pwd)/test/fixtures
	ln -sf $(shell pwd)/test/fixtures/golang $(GOPATH)/src/_/$(shell pwd)/test/fixtures
	ln -sf $(shell pwd)/main.go $(GOPATH)/src/_/$(shell pwd)/

test-common-go:
	$(call INFO, "testing common go")
test-common-go: prepare-go-path test-statically-linked-with-cgo-for-tests

test-statically-linked-with-cgo-for-tests:
	$(MAKE) test-go build-linux
	file $(APP) | grep 'statically linked'
