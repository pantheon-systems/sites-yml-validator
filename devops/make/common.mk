# common make tasks and variables that should be imported into all projects
#
#-------------------------------------------------------------------------------
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.SHELLFLAGS := -u -c

DEFAULT_BRANCHES := master main

HIDE_TASKS ?=
filter_tasks_cmd :=
ifneq ($(HIDE_TASKS),)
	filter_tasks_cmd := | grep -vE $(foreach task,$(HIDE_TASKS), -e ^$(task):)
endif

# override when using recursive make
ROOT_DIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# override to use eg your own checkout for making pr's to upstream
COMMON_MAKE_DIR ?= $(ROOT_DIR)/devops/make

# the branch or ref to get common-make updates from
COMMON_MAKE_UPDATE_TARGET ?= master

help: ## print list of tasks and descriptions
	@grep --no-filename -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) $(filter_tasks_cmd) | sort | uniq | awk 'BEGIN {FS = ":.*?##"}; { printf "\033[36m%-30s\033[0m %s \n", $$1, $$2}'
.DEFAULT_GOAL := help

# Invoke this with $(call INFO,<test>)
# TODO: colorize :)
# TODO: should we add date ? @echo "$$(date +%Y-%m-%d::%H:%m) INFO $@ -> $(1)"
define INFO
	@echo "[INFO] ($@) -> $(1)"
endef

define WARN
	@echo "[WARN] ($@) -> $(1)"
endef

define ERROR
	$(error [ERROR] ($@) ->  $(1))
endef

# export with no arguments can be handy, but not if it tries to export these
unexport INFO WARN ERROR

ifndef BRANCH
  ifdef CIRCLE_BRANCH
    BRANCH := $(CIRCLE_BRANCH)
  else
    BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
  endif
endif

ifndef COMMIT_NO
  COMMIT_NO := $(shell git rev-parse --short=8 HEAD)
endif

ifndef COMMIT
	# Hash unique to the current state of the code including all uncommitted changes.
	COMMIT := $(if $(shell git status --porcelain),${COMMIT_NO}-dirty-$(shell $(COMMON_MAKE_DIR)/sh/repo-hash.sh),${COMMIT_NO})
endif

## empty global tasks are defined here, makefiles can attach tasks to them

deps:: ## install build and test dependencies
deps-circle:: ## install build and test dependencies on circle-ci
lint:: ## run all linters
test:: ## run all tests
test-circle:: ## invoke test tasks for CI
test-coverage:: ## run test coverage reports
build:: ## run all build
clean:: ## clean up artifacts from test and build
format:: ## attempts to properly format or cleanup files, writing changes to disk

# runs format and errors if anything has changed
check-format: format
	@s=$$(git status --porcelain); if [ -z "$$s" ]; then \
  	  echo "workdir is clean"; \
  	else \
  	  echo "The following files have changed on disk"; \
  	  echo "$$s"; \
  	  git diff; \
  	  exit 1; \
	fi


update-makefiles:: ## update the make subtree, assumes the subtree is in devops/make
  ifneq (, $(wildcard scripts/make))
		$(call INFO, "Directory scripts/make exists. You should convert to using the devops dir")
		@echo "git rm -r scripts/make"
		@echo "git commit -m \"Remove common_makefiles from old prefix\""
		@echo "git subtree add --prefix devops/make common_makefiles master --squash"
		@echo "sed -i 's/scripts\/make/devops\/make/g' Makefile"
		@echo "git commit -am \"Move common_makefiles to new prefix\""
		@exit 1
  endif
	@if ! git remote show common_makefiles &> /dev/null; then \
		echo "temporarily adding common_makefiles as a remote"; \
		git remote add common_makefiles git@github.com:pantheon-systems/common_makefiles.git --no-tags; \
		git subtree add --prefix devops/make common_makefiles $(COMMON_MAKE_UPDATE_TARGET) --squash &>/dev/null || true; \
	fi
	@git subtree pull --prefix devops/make common_makefiles $(COMMON_MAKE_UPDATE_TARGET) --squash -m 'update common make'
	@git remote remove common_makefiles

.PHONY:: all help update-makefiles
