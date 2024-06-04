# Common  Go Tasks
#
# INPUT VARIABLES
# - GOLINT_ARGS: Override the options passed to golangci-lint for linting (-v --timeout 3m by default)
# - GOTEST_ARGS: Override the options passed by default ot go test (--race by default)
#
# - FETCH_CA_CERT: The presence of this variable will cause the root CA certs
#                  to be downloaded to the file ca-certificates.crt before building.
#                  This can then be copied into the docker container.
#
#-------------------------------------------------------------------------------

## Append tasks to the global tasks
deps:: deps-go
deps-circle:: deps-circle-go deps
lint:: lint-go
test:: lint-go test-go-tparse
test-circle:: test
test-coverage:: test-coverage-go
build:: $(APP)
build-go:: $(APP)
clean:: clean-go
format:: format-go

ifndef GOLINT_ARGS
  GOLINT_ARGS := -v --timeout 3m
endif

ifndef GOTEST_ARGS
  GOTEST_ARGS := -race -cover
endif

GO_GET_ARGS ?=

GOPATH ?= $(shell go env GOPATH)
GOLANGCI_VERSION := v1.46.2

GO111MODULE=on
export GO11MODULE

DEBUG ?= false
CGO_ENABLED ?= 0
GO_FLAGS ?= -ldflags="-s -w"
ifneq (false,$(DEBUG))
  GO_FLAGS := -gcflags=all='-N -l'
endif

# allow specifying a package in cmd/
CMD ?= $(APP)
PACKAGE := .
OUTPUT := $(APP)
ifneq ($(CMD), $(APP))
  PACKAGE := ./cmd/$(CMD)
  OUTPUT := bin/$(CMD)
endif

## go tasks
$(OUTPUT): $(shell find . -type f -name '*.go' -o -name 'go.mod' -o -name 'go.sum')
	$(call INFO, "building project")
	@CGO_ENABLED=$(CGO_ENABLED) go build $(GO_FLAGS) -o $(OUTPUT) $(PACKAGE) > /dev/null

build-linux:: ## build project for linux
build-linux:: export GOOS=linux
build-linux:: _fetch-cert
build-linux:: $(OUTPUT)

build-circle:: build-linux ## build project for linux. If you need docker you will have to invoke that with an extension

deps-go:: deps-lint ## install dependencies for project assumes you have go binary installed
ifneq (,$(wildcard vendor))
	@find  ./vendor/* -maxdepth 0 -type d -exec rm -rf "{}" \; || true
endif
	$(call INFO, "restoring dependencies using modules via: go mod download $(GO_GET_ARGS)")
	@GO111MODULE=on go mod download $(GO_GET_ARGS)

format-go:
	$(call INFO, "cleaning up go.mod")
	@go mod tidy
	$(call INFO, "formatting go-code")
	@go fmt
	$(call INFO, "running golangci-lint with fixes")
	@# TODO: call lint-go
	@golangci-lint run -E goimports --fix $(GOLINT_ARGS)

lint-go:: deps-go deps-lint
	$(call INFO, "scanning source with golangci-lint")
	golangci-lint run -E goimports $(GOLINT_ARGS)

GO_TEST_CMD := go test $(GOTEST_ARGS)  $$(go list ./... | grep -Ev '/vendor/|/devops/|e2e_tests')
ifneq (,$(findstring -race, $(GOTEST_ARGS)))
  GO_TEST_CMD := CGO_ENABLED=1 $(GO_TEST_CMD)
endif
test-go:: ## run go tests (fmt vet)
	$(call INFO, "running tests with $(GOTEST_ARGS)")
	@$(GO_TEST_CMD)

GO_TEST_CMD_TPARSE = $(GO_TEST_CMD) -json | tparse -all
test-go-tparse:: ## run go tests with tparse formatting
	$(call INFO, "running tests with $(GOTEST_ARGS)")
	@$(GO_TEST_CMD_TPARSE)

test-no-race:: lint ## run tests without race detector
	$(call WARN, "DEPRECATED: set GOTEST_ARGS and run make test-go to change how go-test runs from common-go. Running tests without race detection.")
	go test $$(go list ./... | grep -Ev '/vendor/|/devops/')

deps-circle-go::
	$(call WARN, "DEPRECATED: stop calling deps-circle-go in your Makefiles. Your build may break in the future when this warning is removed")

deps-lint::
ifeq (, $(shell command -v golangci-lint;))
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(GOPATH)/bin $(GOLANGCI_VERSION)
else
  ifeq (, $(shell golangci-lint --version | grep ' $(GOLANGCI_VERSION:v%=%)'))
	$(call WARN,"golangci-lint version mismatch!")
  else
	$(call INFO,"golangci-lint already installed")
  endif
endif

deps-status:: ## check status of deps with gostatus
ifeq (, $(shell command -v gostatus;))
	$(call INFO, "installing gostatus")
	@GO111MODULE=off go get -u github.com/shurcooL/gostatus > /dev/null
endif
	@go list -f '{{join .Deps "\n"}}' . | gostatus -stdin -v

GO_TEST_COVERAGE_ARGS := -v -coverprofile=coverage.out $(GOTEST_ARGS)
GO_TEST_COVERAGE_CMD := go test $(GO_TEST_COVERAGE_ARGS) $$(go list ./... | grep -Ev '/vendor/|/devops/')
ifneq (,$(findstring -race, $(GOTEST_ARGS)))
  GO_TEST_COVERAGE_CMD := CGO_ENABLED=1 $(GO_TEST_COVERAGE_CMD)
endif
test-coverage-go:: ## run coverage report
	$(call INFO, "running go coverage tests with $(GO_TEST_COVERAGE_ARGS)")
	@$(GO_TEST_COVERAGE_CMD) > /dev/null

test-coverage-html:: test-coverage ## output html coverage file
	$(call INFO, "generating html coverage report")
	@go tool cover -html=coverage.out > /dev/null

clean-go::
	$(call INFO, "cleaning build and test artifacts")
	@rm -f '$(APP)' coverage.out

_fetch-cert::
ifdef FETCH_CA_CERT
	$(call INFO, "fetching CA certs from haxx.se")
	@curl -s -L https://curl.haxx.se/ca/cacert.pem -o ca-certificates.crt > /dev/null
endif

.PHONY:: _fetch-cert test-coverage-html deps-status deps-circle deps-go deps-lint \
	lint-go test-circle test-go build-circle build-linux build-go clean-go
