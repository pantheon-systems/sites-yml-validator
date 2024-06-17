# Common  Python Tasks
#
# INPUT VARIABLES
# - PYTHON_PACKAGE_NAME: (required) The name of the python package.
# - TEST_RUNNER: (optional) The name of the python test runner to execute. Defaults to `unittest`
# - TEST_RUNNER_ARGS: (optional) Extra arguements to pass to the test runner. Defaults to `discover`
#
#-------------------------------------------------------------------------------


TEST_RUNNER ?= unittest
TEST_RUNNER_ARGS ?= discover

# Python dependencies
FLAKE8_BIN := $(shell command -v flake8;)
PYLINT_BIN := $(shell command -v pylint;)
COVERAGE_BIN := $(shell command -v coverage;)
BUMPVERSION_BIN := $(shell command -v bumpversion;)

## Append tasks to the global tasks
deps:: deps-python
deps-circle:: deps-circle-python
lint:: lint-python
test:: test-python lint coverage-report
test-coverage:: test-coverage-python
test-circle:: test test-circle-python
build:: build-python

build-python:: ## Build python source distribution. How packages are built is determined by setup.py
	python setup.py sdist

# Python tasks
develop-python:: ## Enable setup.py develop mode. Useful for local development. Disable develop mode before installing.
	python setup.py develop

undevelop-python:: ## Disable setup.py develop mode
	python setup.py develop --uninstall

deps-python:: deps-testrunner-python deps-lint-python deps-coverage-python

deps-testrunner-python:: deps-testrunner-trial

deps-testrunner-trial::
ifeq ("$(TEST_RUNNER)", "twisted.trial")
ifeq (,$(shell command -v trial;))
	pip install twisted
endif
endif

deps-lint-python:: deps-pylint deps-flake8

deps-pylint::
ifndef PYLINT_BIN
	pip install pylint
endif

deps-flake8::
ifndef FLAKE8_BIN
	pip install flake8
endif

deps-coverage-python::
ifndef COVERAGE_BIN
	pip install coverage
endif

deps-circle-python:: ## Install python dependencies for circle

deps-bumpversion-python:
ifndef BUMPVERSION_BIN
	pip install bumpversion
endif

lint-python:: lint-pylint lint-flake8

# Pylint is a Python source code analyzer which looks for programming errors, helps enforcing a coding standard and sniffs for some code smells
# (as defined in Martin Fowler's Refactoring book). Pylint can also be run against any installed python package which is useful for catching
# misconfigured setup.py files.
lint-pylint:: deps-pylint ## Performs static analysis of your "installed" package. Slightly different rules then flake8. Configuration file '.pylintrc'
	pylint $(PYTHON_PACKAGE_NAME)

# Flake8 is a combination of three tools (Pyflakes, pep8 and mccabe). Flake8 performs static analysis of your source code
lint-flake8:: deps-flake8 ## Performs static analysis of your code, including adherence to pep8 (pep8) and conditional complexity (McCabe). Configuration file '.flake8'
ifeq ("", "$(wildcard $(PYTHON_PACKAGE_NAME))")
        # Because flake8 cannot be run against installed packages we emit a warning to allow the global lint target to proceed.
        # This preserves flexibility and relies on pyint for installed packages.
	$(call WARN, "You asked to run flake8 on your source files but could not find them at './$(PYTHON_PACKAGE_NAME)'")
else
	flake8 --show-source --statistics --benchmark $(PYTHON_PACKAGE_NAME)
endif

test-python:: test-coverage-python

test-circle-python::

test-coverage-python:: deps-testrunner-python deps-coverage-python ## Run tests and generate code coverage. Configuration file '.coveragerc'
	coverage run --branch --source $(PYTHON_PACKAGE_NAME) -m $(TEST_RUNNER) $(TEST_RUNNER_ARGS) $(PYTHON_PACKAGE_NAME)

coverage-report: ## Display the coverage report. Requires that make test has been run.
	coverage report

bumpmicro: bumppatch ## Bump the micro (patch) version of the python package. Configuration file '.bumpversion.cfg'

bumppatch: deps-bumpversion ## Alias for bumpmicro
	bumpversion patch

bumpminor: deps-bumpversion ## Bump the minor version of the python package. Configuration file '.bumpversion.cfg'
	bumpversion minor

bumpmajor: deps-bumpversion ## Bump the major version of the python package. Configuration file '.bumpversion.cfg'
	bumpversion major

.PHONY:: deps-coverage-python deps-circle-python deps-lint-python deps-pylint deps-flake8 test-python test-circle-python build-python test-coverage-python coverage-report test-circle test-circle-python bumpmicro bumpminor bumpmajor bumppatch
