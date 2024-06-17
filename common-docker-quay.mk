# INPUT VARIABLES
# 	- QUAY_USER: The quay.io user to use (usually set in CI)
# 	- QUAY_PASSWD: The quay passwd to use  (usually set in CI)
# 	- IMAGE: the docker image to use. will be computed if it doesn't exist.
# 	- REGISTRY: The docker registry to use. Defaults to quay.
#
# EXPORT VARIABLES
# 	- IMAGE: The image to use for the build.
# 	- REGISTRY: The registry to use for the build.
# 	- IMAGE_BASENAME: The image without the tag field on it.. i.e. foo:1.0.0 would have image basename of 'foo'
# 	- REGISTRY_PATH: Registry url and repo name
#-------------------------------------------------------------------------------

_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

include $(_DIR)/_base.mk
include $(_DIR)/_docker.mk

REGISTRY ?= quay.io/getpantheon
IMAGE	 := $(REGISTRY)/$(APP):$(BUILD_NUM)
QUAY_IMAGE=$(IMAGE)

# because users can supply image, we substring extract the image base name
IMAGE_BASENAME := $(firstword $(subst :, ,$(IMAGE)))
QUAY_IMAGE_BASENAME := $(IMAGE_BASENAME)

REGISTRY_PATH := $(REGISTRY)/$(APP)

build-docker:: build-docker-quay

build-docker-quay:: setup-quay build-linux
	@FORCE_BUILD=$(DOCKER_FORCE_BUILD) TRY_PULL=$(DOCKER_TRY_PULL) \
		DOCKER_PATH=$(DOCKER_PATH) \
		$(COMMON_MAKE_DIR)/sh/build-docker.sh \
		$(IMAGE) $(DOCKER_BUILD_CONTEXT) $(DOCKER_BUILD_ARGS)

ifeq ("$(DOCKER_BYPASS_DEFAULT_PUSH)", "false")
push:: push-quay
else
push::
endif

push-quay:: setup-quay
	$(call INFO, "pushing image $(IMAGE)")
	$(call WARN, "Quay is deprecated. Please migrate to Google Artifact Registry.")
	@$(DOCKER_PATH) push $(IMAGE)
	$(call WARN, "Quay is deprecated. Please migrate to Google Artifact Registry.")

setup-quay::
	# setup docker login for quay.io
ifdef CIRCLE_BUILD_NUM
  ifndef QUAY_PASSWD
    $(call ERROR, "Need to set QUAY_PASSWD environment variable.")
  endif
  ifndef QUAY_USER
		$(call ERROR, "Need to set QUAY_USER environment variable.")
  endif
	$(call INFO, "Setting up quay login credentials.")
	@$(QUAY) > /dev/null
else
	$(call INFO, "No docker login unless we are in CI.")
	$(call INFO, "We will fail if the docker config.json does not have the quay credentials.")
endif

.PHONY:: build-docker-quay push-quay setup-quay
