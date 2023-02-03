Common make tasks
=================

<!-- toc -->

- [Introduction](#introduction)
- [Usage](#usage)
  * [Setting Up the common makefiles](#setting-up-the-common-makefiles)
  * [Using in your Makefile](#using-in-your-makefile)
  * [Updating common makefiles](#updating-common-makefiles)
  * [Extending Tasks](#extending-tasks)
  * [Usage with public repos](#usage-with-public-repos)
    + [Initial import](#initial-import)
    + [Future updates](#future-updates)
  * [Usage with more complicated projects](#usage-with-more-complicated-projects)
    + [recursive make](#recursive-make)
- [Tasks](#tasks)
  * [common.mk](#commonmk)
    + [help](#help)
    + [update-makefiles](#update-makefiles)
      - [output variables](#output-variables)
  * [common-apollo.mk](#common-apollomk)
    + [Input](#input)
    + [Tasks](#tasks-1)
      - [check-apollo-schema](#check-apollo-schema)
      - [update-apollo-schema](#update-apollo-schema)
  * [common-docs.mk](#common-docsmk)
    + [circleci 2.0](#circleci-20)
    + [update-readme-toc](#update-readme-toc)
    + [test-readme-toc](#test-readme-toc)
  * [common-docker.mk](#common-dockermk)
    + [push-circle::](#push-circle)
  * [_docker.mk](#_dockermk)
    + [Input Environment Variables:](#input-environment-variables)
    + [Exported Environment Variables:](#exported-environment-variables)
    + [build-docker::](#build-docker)
    + [lint-hadolint::](#lint-hadolint)
  * [common-docker-ar.mk](#common-docker-armk)
    + [Input Environment Variables](#input-environment-variables)
    + [Export Environment Variables](#export-environment-variables)
    + [push::](#push)
    + [push-ar::](#push-ar)
    + [setup-ar::](#setup-ar)
  * [common-docker-quay.mk](#common-docker-quaymk)
    + [circleci 2.0](#circleci-20-1)
    + [push::](#push-1)
    + [push-quay::](#push-quay)
    + [Input Environment Variables](#input-environment-variables-1)
    + [Export Environment Variables](#export-environment-variables-1)
  * [common-shell.mk](#common-shellmk)
    + [Input Environment Variables:](#input-environment-variables-1)
    + [test-shell](#test-shell)
  * [common-pants.mk](#common-pantsmk)
  * [install-circle-pants](#install-circle-pants)
  * [delete-circle-pants](#delete-circle-pants)
  * [init-circle-pants](#init-circle-pants)
  * [common-conda.mk](#common-condamk)
    + [Notes:](#notes)
    + [Inheritable Input Environment Variables from common-python.mk:](#inheritable-input-environment-variables-from-common-pythonmk)
    + [Input Environment Variables:](#input-environment-variables-2)
    + [deps-conda::](#deps-conda)
    + [setup-conda::](#setup-conda)
    + [clean-conda::](#clean-conda)
    + [reset-conda-environment::](#reset-conda-environment)
    + [build-conda::](#build-conda)
    + [build-conda-deployment-environment::](#build-conda-deployment-environment)
    + [deploy-conda::](#deploy-conda)
    + [deploy-conda-pypi::](#deploy-conda-pypi)
    + [regenerate-anaconda-cloud-repo-token::](#regenerate-anaconda-cloud-repo-token)
    + [add-conda-private-channel::](#add-conda-private-channel)
    + [generate-conda-requirements::](#generate-conda-requirements)
    + [reset-conda-environment::](#reset-conda-environment-1)
  * [common-python.mk](#common-pythonmk)
    + [Input Environment Variables:](#input-environment-variables-3)
    + [build-python::](#build-python)
    + [test-python::](#test-python)
    + [test-circle-python::](#test-circle-python)
    + [deps-python::](#deps-python)
    + [deps-circle::](#deps-circle)
    + [deps-coverage::](#deps-coverage)
    + [test-coverage-python::](#test-coverage-python)
    + [test-coveralls::](#test-coveralls)
    + [coverage-report::](#coverage-report)
    + [lint-python::](#lint-python)
    + [lint-pylint::](#lint-pylint)
    + [lint-flake8::](#lint-flake8)
  * [common-go.mk](#common-gomk)
    + [circleci 2.0](#circleci-20-2)
    + [Input Environment Variables:](#input-environment-variables-4)
    + [build-go::](#build-go)
    + [build-linux::](#build-linux)
    + [build-circle::](#build-circle)
    + [test-go::](#test-go)
    + [test-go-tparse::](#test-go-tparse)
    + [test-no-race::](#test-no-race)
    + [test-circle::](#test-circle)
    + [deps-go::](#deps-go)
    + [deps-circle::](#deps-circle-1)
    + [deps-coverage::](#deps-coverage-1)
    + [deps-status::](#deps-status)
    + [clean-go::](#clean-go)
    + [test-coverage-go::](#test-coverage-go)
    + [test-coveralls::](#test-coveralls-1)
    + [test-coverage-html::](#test-coverage-html)
  * [common-kube.mk](#common-kubemk)
    + [circleci 2.0](#circleci-20-3)
    + [Input Environment Variables:](#input-environment-variables-5)
    + [Exported Environment Variables:](#exported-environment-variables-1)
    + [Multi-cluster deployments](#multi-cluster-deployments)
      - [Default Behavior](#default-behavior)
      - [Deloying to Other Clusters (not `general-01`)](#deloying-to-other-clusters-not-general-01)
      - [Deploying to Many Clusters](#deploying-to-many-clusters)
    + [lint-kubeval::](#lint-kubeval)
      - [customizing](#customizing)
    + [force-pod-restart::](#force-pod-restart)
    + [update-secrets::](#update-secrets)
    + [clean-secrets::](#clean-secrets)
    + [update-configmaps::](#update-configmaps)
    + [verify-deployment-rollout::](#verify-deployment-rollout)
  * [common-python3.mk](#common-python3mk)
    + [Input Environment Variables:](#input-environment-variables-6)
    + [check-format-python3::](#check-format-python3)
    + [lint-python3::](#lint-python3)
    + [test-python3-docker::](#test-python3-docker)
    + [deps-python3::](#deps-python3)
    + [deps-python3-docker::](#deps-python3-docker)
  * [common-kustomize.mk](#common-kustomizemk)
    + [Input Environment Variables:](#input-environment-variables-7)
    + [build-kustomize::](#build-kustomize)
    + [diff-kustomize::](#diff-kustomize)
    + [deploy-kustomize::](#deploy-kustomize)
- [Contributing](#contributing)
- [Versioning](#versioning)
  * [Logging](#logging)
  * [Pathfinding](#pathfinding)
  * [Common Patterns for adding to the repo](#common-patterns-for-adding-to-the-repo)
  * [Adding support for a new language](#adding-support-for-a-new-language)
  * [README.md updates](#readmemd-updates)
- [Handy Make stuff](#handy-make-stuff)

<!-- tocstop -->

Introduction
============

This repo contains a library of Makefile tasks and shell scripts that provide
common functions for working with a variety of systems at Pantheon. The
purpose of this repository is to define __common__ tasks used to build and deploy
projects to avoid repetition and to disseminate changes upstream uniformly. If
the task is defined in a project's `Makefile` and you find yourself copying it
into another repository, that is a good sign that it belongs here.

Here are some good examples of common tasks that belong here:
* tasks for building go projects
* tasks for building docker containers
* tasks for managing resources in Kubernetes
* tasks for installing and deploying to a sandbox environment

This repository is **NOT** a good place to define every handy task. Please be
selective.

Usage
=====

Setting Up the common makefiles
------------------------------

Add these common tasks to your project by using git subtree from the root of
your project.

First add the remote.

```
git remote add common_makefiles git@github.com:pantheon-systems/common_makefiles.git --no-tags
```

Now add the subtree

**note:** it is important that you keep the import path set to `devops/make` as
the makefiles assume this structure.

```
git subtree add --prefix devops/make common_makefiles master --squash
```

Using in your Makefile
----------------------

you simply need to include the common makefiles you want in your projects root
Makefile:

```make
APP := baryon
PROJECT := $$GOOGLE_PROJECT

include devops/make/common.mk
include devops/make/common-kube.mk
include devops/make/common-go.mk
```

Updating common makefiles
-------------------------

The `common.mk` file includes a task named `update-makefiles` which you can
invoke to pull and squash the latest versions of the common tasks into your
project. Put the changes on a branch.

```
git checkout -b update-make

make update-makefiles
```

If this is a new clone you may need to re-run these commands to register the
common-make git repo before running `make update-makefiles`:

```
git remote add common_makefiles git@github.com:pantheon-systems/common_makefiles.git --no-tags
git subtree add --prefix devops/make common_makefiles master --squash
```

Extending Tasks
---------------

All the common makefile tasks can be extended in your top level Makefile by
defining them again. Each common task that can be extended has a `::` target.
e.g. `deps::`

for example if I want to do something after the default build target from
common-go.mk I can add to it in my Makefile after including common-go.mk
like so:

```make
build::
  @echo "this is after the common build"
```

Conversely, I must add target lines *before* importing common-go.mk if I wanted
to do something before the default target:

```make
build::
  @echo "this is before the common build"
```

or set variables to modify its behavior (in this case directing it to compile
`cmd/foo`):

```make
build:: CMD=foo
```

Usage with public repos
-----------------------

Ideally we should never add anything sensitive or secret to common-makefiles.
Nonetheless, it is safest to prune out anything not needed by your project if
it is going to be a public Github repo.

Here is a method for pruning out unused files:

### Initial import

- Create <project>/Makefile with an extended `update-makefiles` task and a new
`prune-common-make` task. The prune task should be customized to include only the
files your project will need. Everything else will be removed locally and from
git. Example project that only needs `common.mk` and `common-docker.mk`:

```make
# extend the update-makefiles task to remove files we don't need
update-makefiles::
        make prune-common-make

# strip out everything from common-makefiles that we don't want.
prune-common-make:
        @find devops/make -type f  \
                -not -name common.mk \
                -not -name common-docker.mk \
                -delete
        @find devops/make -empty -delete
        @git add devops/make
        @git commit -C HEAD --amend
```

- Follow the standard procedures for adding the common_makefiles to your project:

```
git remote add common_makefiles git@github.com:pantheon-systems/common_makefiles.git --no-tags
git subtree add --prefix devops/make common_makefiles master --squash
```

- And then execute the prune task created in the first step:

```
make prune-common-make
```

### Future updates

After the initial import of common_makefiles the project can be updated in the
standard way: `make update-makefiles`. The `prune-common-make` task will be
executed after the updates are pulled in.

Usage with more complicated projects
----

This section describes approaches to building a Makefile for a project that
builds and/or deploys more than one thing.

Rather than have a makefile that uses the default targets directly, some
indirection is necessary to accomplish multiple different invocations of those
targets.

### recursive make

To use this strategy, define your own targets with the same name as the default
targets you plan to reuse, but implement them by calling make again, using
variables to determine how to modify that invocation to operate on one thing
that the default target could normally handle.

For example, consider this directory layout:

```
devops/make
make/
- foo.mk
- bar.mk
cmd/
- foo/
  - main.go
- bar/
  - main.go
Makefile
```

your `Makefile` would have targets like this:

```
build:
  $(MAKE) -C . -f make/$(TARGET).mk
```

and if you invoked it like this:

```
make build TARGET=foo
```

then you would use `make/foo` as your makefile, and it would look like a normal
Makefile that consumes common-make:

```
include $(COMMON_MAKE_DIR)/common-go.mk
```

We can further reuse default targets in our submake with another submake.

For example, here we create a separate dev instance of `build-docker` and
create a separate image for use with our `test` target:

```
build-docker-dev:: export DOCKER_BUILD_ARGS := $(DOCKER_BUILD_ARGS) --build-arg=dev=true
build-docker-dev:: export IMAGE := $(IMAGE)-dev
build-docker-dev::
  $(MAKE) -f $(COMMON_MAKE_DIR)/common-docker.mk build-docker \

test:: build-docker-dev
  docker run $(IMAGE)-dev $(TEST_CMD)
```
Tasks
=====

common.mk
---------

### help

`make help` prints out a list of tasks and descriptions.

Any task that contains a comment following this pattern will be displayed:

```make
foo: ## this help message will be display by `make help`
    echo foo
```

Example:

```
$ make help
foo         this help message will be display by `make help`
```

You can suppress the output of any task by setting a variable `HIDE_TASKS` in
your Makefile, eg:

```shell
HIDE_TASKS = deps deps-circle test-circle
```

### update-makefiles

Use this to pull the latest `master` branch from `common_makefiles` into the
local project. (Assumes `common_makefiles` were imported to `./devops/make`)

If you get an error such as `fatal: 'common_makefiles' does not appear to be a git repository`
you may need to add the remote repo before running this task:

```
git remote add common_makefiles git@github.com:pantheon-systems/common_makefiles.git --no-tags
```

#### output variables

- `ROOT_DIR` -- the full path to the root of your repository. Useful for supporting execution of
  `make` in subdirectories of your repo, and some scenarios where you find you need multiple
  includes and/or recursive make invocation.

## common-apollo.mk

Common tasks for working with Apollo Studio for GraphQL Services.

### Input

- `APP`: (required) The name of the app.
- `GQL_SCHEMA_PATH`: (required) path to the schema.graphqls file

### Tasks

#### check-apollo-schema

Checks schema changes against production to ensure any changes are compatable

#### update-apollo-schema

Updates schema for your app on Apollo Studio

common-docs.mk
--------------

Common tasks for managing documentation.

### circleci 2.0

If using a docker-based circleci 2.0 build environment ensure that a remote docker
is available in your `.circleci/config.yml`:

```yaml
    steps:
      - setup_remote_docker
```

### update-readme-toc

Run `make update-readme-toc` to update the TOC in `./README.md`. Uses [markdown-toc](https://github.com/jonschlinkert/markdown-toc#cli)
to edit in place.


### test-readme-toc

This task executes `markdoc-toc` via Docker and compares the output to the
current TOC in the on-disk `./README.md` file. If they differ, a diff output
will be displayed along with an error message and a non-zero exit will occur.

This is intended to be used in a CI pipeline to fail a build and remind author's
to update the TOC and re-submit their changes.

This task requires Docker to be running.

This task is added to the global `test` task.

common-docker.mk
----------------
We push our images to quay.io by default. This file includes `common-docker-quay.mk` to maintain compatbility for existing projects that use `common-docker.mk`.

### push-circle::

Runs the `build-docker` and `push` tasks.
DEPRECATED. Run these commands separately instead.

_docker.mk
----------------
### Input Environment Variables:

None

### Exported Environment Variables:

- `BUILD_NUM`: The build number for this build. Will use `$(DEFAULT_SANDBOX_NAME)-$(COMMIT)` if not building
             on circleCI, will use `$(CIRCLE_BUILD_NUM)-$(CIRCLE_BRANCH)"` otherwise.

- `DOCKER_BYPASS_DEFAULT_PUSH`: If you need to provide custom logic for tagging and pushing images to an artifact repository, add `DOCKER_BYPASS_DEFAULT_PUSH=true` to your `Makefile` and the default push step will be skipped.

### build-docker::

Runs `build-docker.sh`

### lint-hadolint::

Runs `hadolint` on all Dockerfiles found in the repository.

This task fails if `hadolint` is not installed *and* Dockerfiles are present in the repo.
You can set `REQUIRE_DOCKER_LINT := no` in your `Makefile` to make it pass silently if `hadolint` is not installed.

This task is added to the global `lint` task.

common-docker-ar.mk
--------------
### Input Environment Variables
- `AR_IMAGE`: the docker image to use. Will be computed if it doesn't exist
- `AR_REGISTRY`: The docker registry to use. Set to Google Artifact Registry

### Export Environment Variables
- `AR_IMAGE`: The image to use for the build.
- `AR_REGISTRY`: The registry to use for the build
- `AR_IMAGE_BASENAME`: The image without the tag field on it.. i.e. foo:1.0.0 would have image basename of 'foo'
- `AR_REGISTRY_PATH`: Registry url and repo name

### push::
Invokes `push-ar`

### push-ar::
Invokes `setup-ar` then:
Runs `docker push $(IMAGE)` to push the docker image and tag to artifact registry.

### setup-ar::
When invoked from Circle CI this task will setup the gsa for the common circle GSA to be used with our common AR repositories.
Invoked as a dependency of `push-ar`

Runs `setup-circle-vault.sh`. This script does the following
- Installs vault
- Installs pvault
- Runs `gcloud auth activate-service-account` which authenticates the account into the Google Cloud CLI by reading and decoding production vault GSA for `circleci-common@pantheon-internal.iam.gserviceaccount.com`


common-docker-quay.mk
--------------
### circleci 2.0

To push a container to quay.io upon a successful master build:
- On Circle-CI, navigate to *Project Settings > Environment Variables*.
- Add the following environment vars. Ask `@infra` on Slack if you need
  assistance.

```
QUAY_USER: getpantheon+circleci
QUAY_PASSWD: <copy paste production Vault: `secret/securenotes/quay.io_robot__getpantheon_circleci` >
```

If using a docker-based circleci 2.0 build environment ensure that a remote docker
is available in your `.circleci/config.yml`:

```yaml
    steps:
      - setup_remote_docker
```

Note that some functionality is not available with remote docker such as volume
mounts. If you need to use volume mounts on circleci 2.0 you will need to use
the VM-based build environment instead of docker.
### push::

Invokes `push-quay`
### push-quay::
Runs `docker push $(IMAGE)` to push the docker image and tag to quay.

### Input Environment Variables
- `QUAY_USER`: The quay.io user to use (usually set in CI)
- `QUAY_PASSWD`: The quay passwd to use  (usually set in CI)
- `IMAGE`: the docker image to use. will be computed if it doesn't exist.
- `REGISTRY`: The docker registry to use. Defaults to quay.

### Export Environment Variables
- `IMAGE`: The image to use for the build.
- `REGISTRY`: The registry to use for the build.
- `IMAGE_BASENAME`: The image without the tag field on it.. i.e. foo:1.0.0 would have image basename of 'foo'
- `REGISTRY_PATH`: Registry url and repo name

common-shell.mk
--------------

Common tasks for shell scripts, such as [shellcheck](https://www.shellcheck.net/)
for linting shell scripts.

Please also try to follow the [Google Shell Style Guide](https://google.github.io/styleguide/shell.xml)
when writing shell scripts.

> Known Bugs:
> Shellcheck will error with "Segmentation Fault" on debian/ubuntu based images
> which includes our deploy-toolbox and most circleci/* images.
>
> Workarounds: Alpine or Fedora/Redhat images should work. Or this workaround: https://github.com/koalaman/shellcheck/issues/1053

### Input Environment Variables:

- `SHELL_SOURCES`: (optional) A list of shell scripts that should be tested by
  the `test-shell` and `test` tasks. If none is provided, `find . -name \*.sh`
  is run to find any shell files in the project, except files that start with
  `_` or `.`, which are excluded from the find.
- `SHELLCHECK_VERSION`: (optional) The version of shellcheck to be installed by
  the `deps-circle` task.

### test-shell

Run shell script tests such as `shellcheck`.

This task is added to the global `test` task.

common-pants.mk
---------------

Installs pants version greater than `0.1.3` unless overridden with
`PANTS_VERSION` so that a sandbox integration environment can be created on
circle for integration testing and acceptance criteria review.

- `GITHUB_TOKEN`: (required) Github Token for downloading releases of the [pants](https://github.com/pantheon-systems/pants)
   utility. From the production Vault `secret/securenotes/github__pantheon-circleci_user` grab the `pants-token` from this secure note and set it as the `GITHUB_TOKEN`.
- `PANTS_VERSION`: (optional) The version of pants to install. Default `latest`. Specify version like `x.y.z`, eg: `0.1.47`
- `PANTS_INCLUDE`: (optional) The services for pants to install or update. E.g `make
  init-pants PANTS_INCLUDE=notification-service,ticket-management`

## install-circle-pants

Installs the `pants` utility on Circle-CI from https://github.com/pantheon-systems/pants

This task is added to the global `deps-circle` task. If `make deps-circle` is already in your
circle-ci config file then you only need to `include common-pants.mk` in your Makefile.

## delete-circle-pants

Deletes the sandbox environment based on the branch if one exists to prepare
for the deployment.

This task is added to the global `deps-circle` task. If `make deps-circle` is already in your
circle-ci config file then you only need to `include common-pants.mk` in your Makefile.

## init-circle-pants

Creates a kube environment against the `testing.onebox.panth.io` as the
ygg-api. The kube environment is set with the `KUBE_NAMESPACE` following the
convention `sandbox-REPO_NAME-BRANCH_NAME`.

common-conda.mk
---------------

### Notes:

Conda is an open source package management system and environment management
system for installing multiple versions of software packages and their
dependencies and switching easily between them. It works on Linux, OS X and
Windows, and was created for Python programs but can package and distribute any
software (i.e. Python, R, Ruby, Lua, Scala, Java, Javascript, C/ C++, FORTRAN).

This common make integrates with common-python.mk. Both files can be included
in the top-level Makefile. Example:

```make
include devops/make/common-python.mk
include devops/make/common-conda.mk
```

To prevent mistakes, some targets are protected from being run inside a conda
environment by using the `_assert-conda-env-active` and `_assert-conda-env-not-active`
targets respectively.

### Inheritable Input Environment Variables from common-python.mk:

- `PYTHON_PACKAGE_NAME`: (required) The name of the python package.
- `TEST_RUNNER`: (optional) The name of the python test runner to execute. Defaults to `trial`
- `COVERALLS_TOKEN`: (optional) Token to use when pushing coverage to coveralls. Required if using
  the `test-coveralls` task

### Input Environment Variables:

- `TEST_RUNNER`: (required) The name of the test runner to execute. Inherited
   from common-python.mk
- `CONDA_PACKAGE_NAME`: (required) The name of your conda package. Used to also
   name your environment. Defaults to $(PYTHON_PACKAGE_NAME)
- `CONDA_PACKAGE_VERSION`: (required) The version of your conda package. Defaults
   to $(PYTHON_PACKAGE_VERSION)
- `ANACONDA_CLOUD_REPO_TOKEN`: (optional) Token to use when reading private conda
   packages from Anaconda Cloud. This token is required if this package depends
   on other private packages. For local development this is a personal token
   connected to your Anaconda Cloud account. For circle this is a token specific
   to the `pantheon_machines` Anaconda Cloud account and can be found in Vault
- `ANACONDA_CLOUD_DEPLOY_TOKEN`: (optional) Required by circle. Token to use
   when pushing conda packages to Anaconda Cloud. For circle this is a token
   specific to the `pantheon_machines` Anaconda Cloud account and can be found
   in Vault.
- `ANACONDA_CLOUD_ORGANIZATION`: (optional) The name of the organization in
   Anaconda Cloud. Defaults to `pantheon`
- `CONDA_PACKAGE_LABEL`: (optional) The label that will be applied to the conda
   package on deployment. Defaults to `main`

### deps-conda::

Downloads the miniconda installation script. The target uses `uname -s` to
determine which installation script to download. Currently only `Darwin` (OSX)
and `Linux` are supported. Runs the installation script and adds the path to
`~/.bashrc`. Adds the pantheon channel to conda config. Runs `conda config --set annaconda_upload no`
to disable automatic upload to anaconda cloud after a build. This target is
added to the global `deps` target.

### setup-conda::

Setup the conda virtual environment for this project. Looks for an environment.yml
file in the project root.

Runs `conda env create || conda env update`
This target is added to the global `setup` target.

### clean-conda::

Removes index cache, lock files, tarballs, unused cache packages, and source cache.

Runs `conda clean --all -y`.

This target is added to the global `clean` target.

### reset-conda-environment::

Reset a conda environment by removing and reinstalling all of its packages.

Runs `conda remove --name $(CONDA_PACKAGE_NAME) --all -y` and `conda env update`

### build-conda::

Build conda package for project with current arch. A no arch package can be built by configuring the conda recipe.

Runs `conda build recipe --no-anaconda-upload`.

### build-conda-deployment-environment::

Clones the project conda environment into the project directory `./local`. This
environment can be copied directly into the Docker container as the deployment
artifact.

Runs `conda create --clone $(CONDA_PACKAGE_NAME) -y --prefix ./local --copy`.

### deploy-conda::

Requires ANACONDA_CLOUD_DEPLOY_TOKEN to be set. Deploys the built conda package
to Anaconda Cloud.

Runs `conda build -q --user $(ANACONDA_CLOUD_ORGANIZATION) --token $(ANACONDA_CLOUD_DEPLOY_TOKEN) recipe`

### deploy-conda-pypi::

Requires ANACONDA_CLOUD_DEPLOY_TOKEN to be set. Deploys the latest built pypi
package to Anaconda Cloud. Distributing private pypi packages is a paid feature
of Anaconda Cloud that we have not enabled, but private pypi packages can still
be downloaded on the dashboard or using the API.

Runs `anaconda --token $(ANACONDA_CLOUD_DEPLOY_TOKEN) upload -u $(ANACONDA_CLOUD_ORGANIZATION) --label $(CONDA_PACKAGE_LABEL) --no-register --force dist/$(CONDA_PACKAGE_NAME)-$(CONDA_PACKAGE_VERSION).tar.gz`.

### regenerate-anaconda-cloud-repo-token::

A helper to generate a personal read-only token for downloading private conda
packages suitable for local development. If not logged into anaconda client this
will present an interactive console. The token will be labeled `private_repo` on
your Anaconda Cloud account.

The output of this target is an ANACONDA_CLOUD_REPO_TOKEN which should be exported to your environment.

Run `make admin-regenerate-anaconda-cloud-repo-token` Copy the token then run
`export ANACONDA_CLOUD_REPO_TOKEN=_TOKEN_GOES_HERE_`

### add-conda-private-channel::

Adds the pantheon private channel to your conda config for downloading conda
packages from Anaconda Cloud. Requires ANACONDA_CLOUD_REPO_TOKEN to be set.

### generate-conda-requirements::

Helper to generate a full dependency tree of this conda environment into a
requirements_full.txt

### reset-conda-environment::

Helper to reset a conda environment by removing and reinstalling all of its
packages.

common-python.mk
----------------

### Input Environment Variables:

- `PYTHON_PACKAGE_NAME`: (required) The name of the python package.
- `TEST_RUNNER`: (optional) The name of the python test runner to execute. Defaults to `trial`
- `COVERALLS_TOKEN`: (optional) Token to use when pushing coverage to coveralls. Required if using
  the `test-coveralls` task

### build-python::

Run `python setup.py sdist` in the current project directory.

This task is added to the global `build` task.

### test-python::

Runs targets `test-coverage-python` and target the global `lint` target.

This task is added to the global `test` task.

### test-circle-python::

Intended for use in circle-ci config to run tests under the Circle-CI context. This
target additionally calls target test-coveralls-python which runs `coveralls`
to report coverage metrics.

### deps-python::

Install this projects' Python dependencies which includes the targets deps-testrunner-python,
deps-lint-python and deps-coverage-python

NOTE: Currently assumes this project is using `pip` for dependency management.

This task is added to the global `deps` task.

### deps-circle::

Install dependencies on Circle-CI which includes the targets deps-coveralls-python

### deps-coverage::

Install dependencies necessary for running the test coverage utilities like
coveralls.

### test-coverage-python::

Run `coverage run --branch --source $(PYTHON_PACKAGE_NAME) $(shell which $(TEST_RUNNER)) $(PYTHON_PACKAGE_NAME)`
which creates the coverage report.

This task is added to the global `test-coverage` task.

### test-coveralls::

Run `coveralls` which sends the coverage report to coveralls.

Requires `COVERALLS_TOKEN` environment variable.

### coverage-report::

Run `coverage report` on the last generated coverage source.

### lint-python::
Run targets `lint-pylint` and `lint-flake8`

This task is added to the global `lint` task.

### lint-pylint::
Run `pylint $(PYTHON_PACKAGE_NAME)`

Pylint is a Python source code analyzer which looks for programming errors,
helps enforcing a coding standard and sniffs for some code smells as defined in
Martin Fowler's Refactoring book). Pylint can also be run against any installeds
python package which is useful for catching misconfigured setup.py files.

This task is added to `lint-python` task.

### lint-flake8::
Run `flake8 --show-source --statistics --benchmark $(PYTHON_PACKAGE_NAME)`

Flake8 is a combination of three tools (Pyflakes, pep8 and mccabe). Flake8
performs static analysis of your uncompiled code (NOT installed packages).

When the source directory of your project is not found this target prints a
warning instead of an error. Pylint does not require the source directory
and can be run on an installed python package. This preserves flexibility.

This task is added to `lint-python` task.

common-go.mk
------------

### circleci 2.0

When using circleci 2.0 it is recommended to use one of the circleci provided
Go primary containers if possible. The latest version of Go will be available.
Updating to a new version involves bumping the container tag.

### Input Environment Variables:

- `COVERALLS_TOKEN`: Token to use when pushing coverage to coveralls.
- `FETCH_CA_CERT:` The presence of this variable will add a  Pull root ca certs
                 to  ca-certificats.crt before build.

### build-go::

Run `go build` in the current project directory if any go code files have been updated
and the binary (at `./$(APP)` by default) isn't already present.

If you need to build many binaries, you can do a `make` invocation for each one if you
put each subpackage with a `main` function in its own `./cmd/subpackage` directory and
set `CMD=subpackage`. See `build-docker` for options that can be used to build separate
images, ie one for each binary.

This task is added to the global `build` task.

### build-linux::

Build a static Linux binary. (Works on any platform.)

### build-circle::

Intended for use in circle-ci config files to run a build under the Circle-CI
context.

### test-go::

Run `go test` against all go packages in the project.

Does not run tests for packages in directories `devops/` and `vendor/` or with `e2e_tests` in their name.

### test-go-tparse::

Run `go test` against all go packages in the project and formats the output using tparse (https://github.com/mfridman/tparse).

Does not run tests for packages in directories `devops/` and `vendor/` or with `e2e_tests` in their name.

This task is added to the global `test` task.

### test-no-race::

Run `go test` without the race dectector.

### test-circle::

Intended for use in circle-ci config to run tests under the Circle-CI context.

### deps-go::

Install this projects' Go dependencies and tools.

If you are using go modules, then the target will use `go get`.

Pass arguments to `go get` by setting the `GO_GET_ARGS` variable in your
Makefile:

```make
GO_GET_ARGS := -d
```

If there is a `./vendor` directory, then `go get` is not called,
and the `./vendor` directory is deleted.

This task is added to the global `deps` task.

### deps-circle::

Install dependencies on Circle-CI

### deps-coverage::

Install dependencies necessary for running the test coverage utilities like
coveralls.

### deps-status::

Check status of dependencies with gostatus.

### clean-go::

Delete all build artifacts.

Executed by default with common target `clean::`.

### test-coverage-go::

Run `go cov` test coverage report.

This task is added to the global `test-coverage` task.

### test-coveralls::

Run test coverage report and send it to coveralls.

Requires `COVERALLS_TOKEN` environment variable.

### test-coverage-html::

Run go test coverage report and output to `./coverage.html`.

common-kube.mk
--------------

### circleci 2.0

- On Circle-CI, navigate to *Project Settings > Environment Variables*.
- Ask `@infra` on Slack to assist in adding the `GCLOUD_EMAIL` and `GCLOUD_KEY` env vars.

When using circleci 2.0 set the environment variables on the primary container, eg:

```yaml
---
version: 2
jobs:
  build:
    docker:
      - image: circleci/golang:1.9.1
    steps:
```

### Input Environment Variables:

- `APP`: should be defined in your topmost Makefile
- `SECRET_FILES`: list of files that should exist in secrets/* used by
                 `_validate_secrets`
- `UPDATE_GCLOUD`: if you are using the gcloud/kubectl image for deployments then set
                   this var to `false`
- `CLUSTER_DEFAULT`: set this to the short name of the cluster you wish to deploy to, ie
                     `sandbox-02` if you're trying to update template-sandbox
- `GCLOUD_PROJECTS`: set this to the space-delimited list of projects in which your clusters reside
- `KUBE_NAMESPACE`: set this to the namespace you wish to deploy to, ie `template-sandbox`
                    if you're trying to update template-sandbox

### Exported Environment Variables:

NOTE: variables that appear hear and above are determined automatically if not set

- `KUBE_NAMESPACE`: represents the kube namespace that has been detected based
                   on branch build and circle existence, or the branch explicitly
                   set in the environment.
- `KUBE_CONTEXT`: the full name of the context that you will deploy to. A context is a
                  kubernetes configuration construct, but we rely on the fact that we use
                  the same process for setting all contexts on workstation and in CI
- `KUBECTL_CMD`: the equivalent of:
                 ```
                 kubectl --context=${KUBE_CONTEXT} --namespace=${KUBE_NAMESPACE}
                 ```
                 Primarily for use in your `deploy` target, eg:
                 ```
                 deploy::
                   $(KUBECTL_CMD) apply -f -r devops/k8s/manifests
                 ```

If no namespace or context is defined, common-kube will use a different
set of defaults depending on the current environment and branch:

| CircleCI | Branch            | Default context | Default namespace        |
|----------|-------------------|-----------------|--------------------------|
| Yes      | `master` / `main` | `general-01`    | `production`             |
| Yes      | Other branch      | `sandbox-01`    | `sandbox-[APP]-[BRANCH]` |
| No       | Any branch        | _pants default_ | _pants default_          |

- If `CIRCLECI` env var is not defined (ie: not running on circle), the `pants` utility
  will be invoked to retrieve your default sandbox name. If this succeeds the value
  of `KUBE_NAMESPACE` will be set to your default sandbox name.
- If `CIRCLECI` env var is defined, `KUBE_NAMESPACE` will be set to:
  `sandbox-$(CIRCLE_PROJECT_REPONAME)-$(CIRCLE_BRANCH)`. This allows for deploying
  temporary test sandboxes for PR's.
- If `CIRCLE_BRANCH` is set to `master` or `main`, `KUBE_NAMESPACE` will be set to `production`.

To override default context and/or namespace:

- Context:              `KUBE_CONTEXT=gke_pantheon-internal_us-west1_general-04`
- Abbreviated context:  `CLUSTER_DEFAULT=general-04`
- Namespace:            `KUBE_NAMESPACE=namespace`
- Template sandbox:     `KUBE_NAMESPACE=template-sandbox`
    - is equivalent to: `KUBE_NAMESPACE=template-sandbox CLUSTER_DEFAULT=sandbox-02`

### Multi-cluster deployments
Common make creates all of the connection information for main kubernetes clusters that we interact
with. These are setup to be used as contexts for your `kubectl` commands for switching between clusters.
If the context is not specified then commands will default to the cluster specified in CLUSTER_DEFAULT
or if not specified then `general-01`

Example:
`kubectl --context <clustername> get pods -n <namepsace>`

This will get the pods on the cluster and namespace specified. This should be
the long cluster name.

#### Default Behavior
By default, all common make tools will use the default cluster (as set for `kubectl` tooling), in addition it will create connections to each of the other clusters.

#### Deloying to Other Clusters (not `general-01`)
To uniformly deploy to a different cluster than the default you can specify

`CLUSTER_DEFAULT=<cluster to deploy to>`

inside your make file to point everything to that deployment cluster.

#### Deploying to Many Clusters
To do this you must specify the --context argument to your `kubectl` calls inside your common make primary
makefile. The context will specify for that command what cluster to deploy to. For example:

If I am deploying everything to general-01, except for the CronJob:

Using this for resources deploying to general-01
`kubectl --context general-01 create ...`

Using this for CronJob, deploying to general-02
`kubectl --context general-02 create ...`

### lint-kubeval::

Runs `kubeval` by default on all YAMLS found in `KUBE_YAMLS_PATH` (defaults to `./devops/k8s/`) in the repository, but
it will skip files in `KUBE_YAMLS_PATH/configmaps` and any path with substring `template.`.

If `KUBE_YAMLS_PATH` is not present, `lint-kubeval` is skipped.

If `KUBE_YAMLS_PATH` is present, but the command `kubeval` is not installed, `lint-kubevals` fails with an error message:

```
devops/make/common-kube.mk:186: *** "kubeval is not installed! please install it.".  Stop.
```

This task is added to the global `lint` task.

#### customizing

Set these variables to change behavior
- `KUBE_YAMLS_PATH` -- Defaults to `./devops/k8s`. Extend it so it references a
  subdirectory, eg `KUBE_YAMLS_PATH=./devops/k8s/manifests/database` so you can
  1. deploy a separate database component without deploying anything else
  2. dump templated yaml for just that component in a separate path and avoid false
    linting errors
- `KUBE_YAMLS_EXCLUDED_PATHS` -- Defaults to `configmaps` but can be a space-delimited
  list of subdirectories to ignore.
- `KUBE_YAMLS` -- you can override all of this by just specifying a space-delimited list
  of file paths relative to the root of your repo.
- `SKIP_KUBEVAL` -- if defined, the call to lint-kubeval from common-kube.mk will be skipped.
  This provides the opportunity to render configuration files of the project before calling lint-kubeval.

### force-pod-restart::

Nuke the pod in the current `KUBE_NAMESPACE`.

### update-secrets::

Requires `$APP` variable to be set.
Requires `$KUBE_NAMESPACE` variable to be set.
Requires **one** of these directories to have files meant to be applied:
- ./devops/k8s/secrets/[KUBE_CONTEXT]/production/
- ./devops/k8s/secrets/[KUBE_CONTEXT]/[NAMESPACE]/
- ./devops/k8s/secrets/[KUBE_CONTEXT]/non-prod/
- ./devops/k8s/secrets/production
- ./devops/k8s/secrets/[NAMESPACE]
- ./devops/k8s/secrets/non-prod/

There secrets can be created two ways:
1. From a set of files in a directory named after the
   secret. Each file will use its name as a key name for the secret
   and the data in the file as the value.
2. From a 'literal' map. Make a file that has a set of k=v pairs in it
  one per line. Each line will have its data split into secrets keys and values.

_How it works:_

Put secrets into files in a directory such as
`./devops/k8s/secrets/non-prod/[namespace]`,
run `make update-secrets KUBE_NAMESPACE=[namespace]` to upload the secrets
to the specified namespace in a volume named `$APP-certs`. If the directory
`./devops/k8s/secrets/[namespace]/` directory first, and if it doesn't exist it
will default to looking in `./devops/k8s/secrets/non-prod`

In general, the most specific directory that exists corresponding to the specified
`KUBE_CONTEXT`/`KUBE_NAMESPACE` is read from, so if you create
./devops/k8s/secrets/[KUBE_CONTEXT]/production/, anything in ./devops/k8s/secrets/production
will not be seen when during `make update-secrets` for that [KUBE_CONTEXT].

NOTE: The `$APP` variable will be prepended to the volume name. eg:
A directory path of `./devops/k8s/secrets/template-sandbox/certs` and `APP=foo` will create a
secret volume named `foo-certs` in the template-sandbox namespace.

_Directory Example:_

The Directory method can be used for anthing that you want translated directly into a kube secret from a file. This could be an RSA key or an entire JSON file from GCE. The contents of the file will be encoded using base64 and added to the kube secret.

Move the file to a directory under the last level of the path used for literal files. In the example below, the extra directory after 'production' for 'api-keys' will cause the `make update-secrets` command below to follow the path of creating the kube object using a file with a directory instead of from a literal file. Additionally, naming the directory 'api-keys' will append that name to the end of the 'app' name, making the final secret name in Kube "app-api-keys".

```
# for production:

$ mkdir -p ./devops/k8s/secrets/production/api-keys
$ echo -n "secret-API-key!" >./devops/k8s/secrets/production/api-keys/key1.txt
$ echo -n "another-secret-API-key!" >./devops/k8s/secrets/production/api-keys/key2.txt
$ make update-secrets KUBE_NAMESPACE=production APP=foo

# cleanup secrets, do not check them into git!
$ rm -rf -- ./devops/k8s/secrets/*
```

Verify the volume was created and contains the expected files:

```
$ kubectl describe secret foo-api-keys --namespace=production
Name:           foo-api-keys
Namespace:      production
Labels:         app=foo

Type:   Opaque

Data
====
key1.txt:       15 bytes
key2.txt:       22 bytes
```

_Literal File Example_

Make a file with k=value pairs, and name it what you want the secret to be called.
```
$ cat ./devops/k8s/secrets/non-prod/foo-secrets
secret1=foo
secret2=bar
secret3=baz
```

Apply the secrets
```
$ make update-secrets KUBE_NAMESPACE=template-sandbox
```

Verify the secrets contents
```
$ kubectl describe secrets myapp-foo-secrets --namespace=template-sandbox
Name:		myapp-foo-secrets
Namespace:	template-sandbox
Labels:		app=myapp
Annotations:	<none>

Data
====
secret1:	3 bytes
secret2:	3 bytes
secret3:	3 bytes
```

_Labels_

By default a `app=$APP` label will be applied to the configmaps. This can be
overridden by setting the `LABELS` environment variable. You should almost always
include the `app` label in addition to any other labels. This allows for easily
tying together a deployment with its configmaps and is necessary for proper cloning
by [pants](https://github.com/pantheon-systems/pants)

Example `Makefile` task to set custom `LABELS`:

```make
update-configmaps:: LABELS="app=$(APP),cos-system-service=true"
```

### clean-secrets::

Delete all uncommitted files and directories in ./devops/k8s/secrets,
including the directory itself.

Executed by default with common target `clean::`.

### update-configmaps::

Requires `$APP` variable to be set.
Requires `$KUBE_NAMESPACE` variable to be set.
Requires one of these directories to have files meant to be applied:
- ./devops/k8s/configmaps/[KUBE_CONTEXT]/production/
- ./devops/k8s/configmaps/[KUBE_CONTEXT]/[NAMESPACE]/
- ./devops/k8s/configmaps/[KUBE_CONTEXT]/non-prod/
- ./devops/k8s/configmaps/production/
- ./devops/k8s/configmaps/[NAMESPACE]/
- ./devops/k8s/configmaps/non-prod/

Use this task to upload Kubernetes configmaps.

_How it works:_

There are 2 types of configmaps that can be used. A configmap complied from a set
of files in a directory or a 'literal' map. Directory of files is what it sounds
like; make a directory and put files in it. Each file will use its name as a key
name for the configmap, and the data in the file as the value. A Literal map is
a file that has a set of k=v pairs in it one per line. Each line will have it's
data split into configmap keys and values. _BEWARE_ that the value should not be
quoted. Due to how the shell interpolation happens when passing these k=v pairs
to kubectl quote strings will be literal quoted strings in the kube config map.

Put a file or directory in the proper namespace e.g.
`./devops/k8s/configmaps/[namespace]/[map-name]` then run `make update-configmaps`
this will update template-sandbox namespace by default. If you need to use a different
namespace provide that to the make command environment:
`make update-configmaps KUBE_NAMESPACE=[namespace]`. If the [namespace]; directory
does not exist and your `KUBE_NAMESPACE` is not `'production'` then the script will
use configmaps defined in `./devops/k8s/configmaps/non-prod/`. This allows you to
apply configmaps to your kube sandbox without having to pollute the directories.

In general, the most specific directory that exists corresponding to the specified
`KUBE_CONTEXT`/`KUBE_NAMESPACE` is read from, so if you create
./devops/k8s/configmaps/[KUBE_CONTEXT]/production/, anything in ./devops/k8s/configmaps/production
will not be seen when during `make update-configmaps` for that [KUBE_CONTEXT].

NOTE: The `$APP` variable will be prepended to the configmap name. eg:
A directory path of `./devops/k8s/configmaps/template-sandbox/config-files` and
`APP=foo` will create a configmap named `foo-config-files` in the `template-sandbox`
namespace.

_Directory Example:_

Make the map directory. Given the app named foo this will become a configmap named foo-nginx-config
```
$ mkdir -p ./devops/k8s/configmaps/non-prod/nginx-config
```

Put your app config in the directory you just created
```
$  ls ./devops/k8s/configmaps/non-prod/nginx-config
common-location.conf  common-proxy.conf  common-server.conf  nginx.conf  verify-client-ssl.conf  websocket-proxy.conf
```

Apply the map with the make task
```
$ make update-configmaps KUBE_NAMESPACE=sandbox-foo
# this error is fine, it would say deleted if it existed
Error from server: configmaps "foo-nginx-config" not found
configmap "foo-nginx-config" created
configmap "foo-nginx-config" labeled
```

Verify the volume was created and contains the expected files:

```
$ kubectl describe configmap foo-nginx-config --namespace=sandbox-foo
kubectl describe configmap foo-nginx-config --namespace=sandbox-foo
Name:		foo-nginx-config
Namespace:	sandbox-foo
Labels:		app=foo
Annotations:	<none>

Data
====
verify-client-ssl.conf:	214 bytes
websocket-proxy.conf:	227 bytes
common-location.conf:	561 bytes
common-proxy.conf:	95 bytes
common-server.conf:	928 bytes
nginx.conf:		2357 bytes
```

_Literal File Example_

Make a file with k=value pairs, and name it what you want the map to be called.
Given I am in 'myapp' using commonmake and I run these configs the resultant map
will be  'myapp-foo-config'
```
$ cat ./devops/k8s/configmaps/non-prod/foo-conf
setting1=foo
setting2=bar
setting3=baz
```

Apply the map
```
$ make update-configmaps KUBE_NAMESPACE=sandbox-foo
```

Verify the map contents
```
$ kubectl describe configmap myapp-foo-config --namespace=sandbox-foo
Name:		myapp-foo-config
Namespace:	sandbox-foo
Labels:		app=myapp
Annotations:	<none>

Data
====
setting1:	3 bytes
setting2:	3 bytes
setting3:	3 bytes
```

_Labels_

By default a `app=$APP` label will be applied to the configmaps. This can be
overridden by setting the `LABELS` environment variable. You should almost always
include the `app` label in addition to any other labels. This allows for easily
tying together a deployment with its configmaps and is necessary for proper cloning
by [pants](https://github.com/pantheon-systems/pants)

Example `Makefile` task to set custom `LABELS`:

```make
update-configmaps:: LABELS="app=$(APP),cos-system-service=true"
```

### verify-deployment-rollout::

Checks for a successful rollout of a Kubernetes Deployment. This would typically be called in your CI/CD pipeline's `deploy` step. If the rollout fails an attempt will be made to rollback to the previous Deployment. The rollback may also fail, however, and you are responsible for confirming the status of your service.

Note that this is only intended for use with Kubernetes Deployment resources (eg: not StatefulSets, CronJobs)

common-python3.mk
----------------

### Input Environment Variables:

- `PYTHON_PACKAGE_NAME`: The name of the python package.
- `IMAGE`: The image to use for the build.  If also using `common-docker.mk`, this should already be defined.

### check-format-python3::

Run `pipenv run black --check --skip-string-normalization --line-length 120 .` in the current project directory.

This task is added to the global `lint` task.

### lint-python3::

Runs `pipenv run pylint $(PYTHON_PACKAGE_NAME)`.

This task is added to the global `lint` task.

### test-python3-docker::

Runs tests in a Docker image with the following command:
```
docker run $(IMAGE) .venv/bin/python setup.py test
```

### deps-python3::

Install this project's Python runtime and dev dependencies.

NOTE: Currently assumes this project is using `pipenv` for dependency management.

This task is added to the global `deps` task.

### deps-python3-docker::

Install this project's Python runtime dependencies.

NOTE: Currently assumes this project is using `pipenv` for dependency management.


common-kustomize.mk
----------------

Provides targets for deploying apps to kube using [kustomize](https://kustomize.io/).

By convention, instances (ready-to-deploy kustomizations for an app) are located in `devops/kustomize/instances`.

The instance path (relative to this directory) is then provided (via `INSTANCE`) to run kustomize using the targets described below.

For example: `make deploy-kustomize INSTANCE=prod/cluster1` will build `devops/kustomize/instances/prod/cluster1`
and apply it to the current kube cluster/namespace.

### Input Environment Variables:

**Required:**

Only one of the following is required:

- `INSTANCE`: The kustomize instance (a path relative to `devops/kustomize/instances`) to deploy/diff/build.
- `KUSTOMIZATION`: The full kustomization path. May be provided if your project structure is difference than the default.

**Optional:**

- `AR_IMAGE`: The image to deploy. If also using `common-docker-ar.mk`, this should already be defined.
- `IMAGE`: The image to deploy. If also using `common-docker.mk` or `common-docker-quay.mk`, this should already be defined.  This will take precedence over `AR_IMAGE`.
- `KUBE_CONTEXT`: Kube context to interact with. If also using `common-kube.mk`, this should already be defined.
- `KUBE_NAMESPACE`: Kube namespace to interact with. If also using `common-kube.mk`, this should already be defined.
- `KUBECTL_CMD`: Path to the `kubectl` binary.  If also using `common-kube.mk`, this should already be defined.
- `KUSTOMIZE_CMD`: Path to the `kustomize` binary. (Automatically determined from `$PATH` if not provided).

### build-kustomize::

Builds an instance kustomization and displays it by printing it to stdout.

### diff-kustomize::

Builds an instance kustomization and diffs it's content against the content in the kube server.

### deploy-kustomize::

Builds an instance kustomization and applies it's content to the kube server.

Contributing
============

make edits here and open a PR against this repo. Please do not push from your
subtree on your project.

1. Have an idea
2. Get feedback from the beautiful people around you
3. Document your new or modified task in this README
4. Not everyone reads markdown files in a web browser, please try to wrap lines
   in this README at or near 80 characters.
5. Paragraphs should be separated by blank lines to facilitate proper rendering
   in both web and text formats.
6. Commit on a branch (please squash closely related commits into contextually
   single commits)
7. Send PR

Versioning
============
This repository uses SemVer style versioning. We use [autotag](https://github.com/pantheon-systems/autotag)
to automatically increment version tags based on commit messages on changes to
the `master` branch. Refer to the [autotag README](https://github.com/pantheon-systems/autotag#scheme-autotag-default)
to learn how to trigger major, minor, and patch tags. If no keywords are
specified a Patch bump is applied.

Logging
-------

There are 3 logging functions defined in `common.mk` INFO, WARN, and ERROR.
If you want to have clean output for make tasks you should redirect STDOUT to
/dev/null, and use these logging functions for reporting info to the user:

```yaml
footask:
    $(call INFO, "running footask for $(FOO_VAR)")
    dostuff > /dev/null
```

When dostuff errors the error will still be reported, and the task will fail.

Pathfinding
--------------

Have to do something in a real project where you're using common-make, and it's tedious,
but you don't yet know what the solution is? Try setting `COMMON_MAKE_DIR` to your local
checkout of common_makefiles outside your project, eg:

```
COMMON_MAKE_DIR=$HOME/pantheon/common_makefiles
```

Now you can iterate on a new feature as you solve your problem. You will naturally test
your change and are likely to yield a more useful and reliable change to ship upstream.
Additionally, you can proceed with no danger of ending up in the ninth circle of subtree
merge hell due to mistakenly trying to do almost anything to the subtree checkout in your
consuming project.

Common Patterns for adding to the repo
--------------------------------------

Tasks should follow the form of `<action>-<context>-<object>` for example ifs
I have a build task  and you want to add windows support you would add as
`build-windows` or if you wanted to add a build for onebox you might dos
`build-onebox-linux` or simply `build-onebox`.

There is the expectation that if you are doing a context specific task you add
the context to your tasks. I.E. `test-circle`.

This isn't written in stone, but I think it is a reasonable expectation that
any engineer should be able to checkout any project and run:
`make deps && make build && make test` to get things running / testing.

Adding support for a new language
---------------------------------

Programming languages tend to share a similar set of common tasks like `test`,
`build`, `deps`. Commmon-make tries to handle this situation by setting a list
of rules and guidelines for adding support for a new language.

There are a set of global tasks defined in the `common.mk`, in particular:

- `deps`
- `lint`
- `test`
- `test-coverage`
- `build`
- `clean`

To add support for a new language, follow this pattern:

- Create the new file: `common-LANG.sh`
- Create a task specific and unique to this language: `test-LANG:`
- Add this task to the global test task: `test:: test-LANG`

The reason for this pattern is:

- It allows running specific test suites, eg: `test-go` to only test go files.
- It keeps the `help` output sane. Otherwise the last-read file would win and
  your users would see a help message like `test   Run all go tests` which may
  not be completely accurate if the project includes multiple common-LANG files.
- Supports running all of a project's tests and builds as the default case.

README.md updates
-----------------

When updating this README, run `make update-readme-toc` before committing to update
the table of contents.

Ensure your text wraps at 80 columns. Exceptions made for code and command line
examples as well as URLs.

Handy Make stuff
================

Introduction to make Slide deck
http://martinvseticka.eu/temp/make/presentation.html

The make cheet sheet
https://github.com/mxenoph/cheat_sheets/blob/master/make_cheatsheet.pdf

The make Manual
https://www.gnu.org/software/make/manual/make.html
