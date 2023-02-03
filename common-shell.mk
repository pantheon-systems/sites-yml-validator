# See README.md for docs: https://github.com/pantheon-systems/common_makefiles

export PATH := $(PATH):$(HOME)/bin

## Append tasks to the global tasks
lint:: lint-shell
lint-shell:: test-shell
test:: test-shell
test-circle:: test-shell
deps-circle:: deps-circle-shell

# version of shellcheck to install from deps-circle
SHELLCHECK_VERSION := 0.7.1

SHELLCHECK_BIN := $(shell command -v shellcheck;)

ifndef SHELL_SOURCES
	SHELL_SOURCES := $(shell find . \( -name '*.sh' -or -name '*.bats' \) -not -path '*/_*/*')
endif

test-shell:: ## run shellcheck tests
ifdef SHELL_SOURCES
	$(call INFO, "running shellcheck for $(SHELL_SOURCES)")
	shellcheck -x $(SHELL_SOURCES)
endif

_install_shellcheck:
	$(call INFO, "Installing shellcheck $(SHELLCHECK_VERSION)")
	@curl -s -L https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz | tar --strip-components=1 -xJvf - shellcheck-v${SHELLCHECK_VERSION}/shellcheck
	@mkdir -p $$HOME/bin
	@mv shellcheck $$HOME/bin

deps-circle-shell::
ifndef SHELLCHECK_BIN
deps-circle-shell:: _install_shellcheck
else
ifneq ($(SHELLCHECK_VERSION), $(shell "$(SHELLCHECK_BIN)" -V | awk '/version:/ {print $$2}'))
deps-circle-shell:: _install_shellcheck
endif
endif

# TODO: add some patterns for integration tests with bats. example: https://github.com/joemiller/creds
