# Common Python 3 Tasks
#
# INPUT VARIABLES
#	- PYTHON_PACKAGE_NAME: (required) The name of the python package.
#	- IMAGE: (required) The docker image to use.
#-------------------------------------------------------------------------------

export PATH := $(PATH):$(HOME)/.local/bin

deps:: deps-python3
lint:: check-format-python3 lint-python3

check-format-python3:
	pipenv run black --check --skip-string-normalization --line-length 120 .

lint-python3:
	pipenv run pylint $(PYTHON_PACKAGE_NAME)

test-python3-docker:
	docker run $(IMAGE) .venv/bin/python setup.py test

deps-python3:
	pip3 install pipenv --user
	pipenv clean
	pipenv install --dev
	pipenv run python setup.py develop

deps-python3-docker:
	pip3 install pipenv
	pipenv install
	/app/.venv/bin/python setup.py develop
