# INPUT VARIABLES
# 	- AR_IMAGE: the docker image to use. will be computed if it doesn't exist.
# 	- AR_REGISTRY: The docker registry to use. Set to Google Artifact Registry.
#
# EXPORT VARIABLES
# 	- AR_IMAGE: The image to use for the build.
# 	- AR_REGISTRY: The registry to use for the build.
# 	- AR_IMAGE_BASENAME: The image without the tag field on it.. i.e. foo:1.0.0 would have image basename of 'foo'
# 	- AR_REGISTRY_PATH: Registry url and repo name
#-------------------------------------------------------------------------------

_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

include $(_DIR)/_base.mk
include $(_DIR)/_docker.mk

AR_REGISTRY ?= us-docker.pkg.dev/pantheon-artifacts/internal
AR_IMAGE := $(AR_REGISTRY)/$(APP):$(BUILD_NUM)
# because users can supply image, we substring extract the image base name
AR_IMAGE_BASENAME := $(firstword $(subst :, ,$(AR_IMAGE)))
# used for testing in Makefile
AR_REGISTRY_PATH := $(AR_REGISTRY)/$(APP)

# TODO Wipe out
ifdef CIRCLE_BUILD_NUM
	VAULT_TOKEN = $(shell $(COMMON_MAKE_DIR)/sh/setup-circle-vault.sh 2>&1 > /dev/null; . $$BASH_ENV; echo $$VAULT_TOKEN)
	export VAULT_TOKEN
endif

build-docker:: build-docker-ar

build-docker-ar:: setup-ar build-linux
	@FORCE_BUILD=$(DOCKER_FORCE_BUILD) TRY_PULL=$(DOCKER_TRY_PULL) \
		DOCKER_PATH=$(DOCKER_PATH) \
		$(COMMON_MAKE_DIR)/sh/build-docker.sh \
		$(AR_IMAGE) $(DOCKER_BUILD_CONTEXT) $(DOCKER_BUILD_ARGS)

ifeq ("$(DOCKER_BYPASS_DEFAULT_PUSH)", "false")
push:: push-ar
else
push::
endif

setup-ar::
# TODO Wipe out
ifdef CIRCLE_BUILD_NUM
	DOCKER_PATH=$(DOCKER_PATH) \
	$(COMMON_MAKE_DIR)/sh/setup-circle-ar-docker.sh;
endif

push-ar:: setup-ar
push-ar::
	$(call INFO,"Pushing image $(AR_IMAGE)")
	$(DOCKER_PATH) push $(AR_IMAGE);

.PHONY:: build-docker-ar push-ar setup-ar
