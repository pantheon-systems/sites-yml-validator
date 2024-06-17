APP=common-make-docker

ifdef CIRCLE_BUILD_NUM
  BUILD_NUM = $(CIRCLE_BUILD_NUM)
else
  BUILD_NUM = $(shell git rev-parse HEAD | egrep -o '....$$')
endif

include common.mk
include common-docker-ar.mk

test-common-docker: build-docker push
	$(call INFO, "testing common docker")
	@test "$(AR_REGISTRY_PATH)" = "$(AR_IMAGE_BASENAME)"
ifdef NEW_TAG_STRATEGY
	@test "$(shell echo "${BRANCH}" | tr -cd '[:alnum:]_-')-$(COMMIT)" = "$(BUILD_NUM)"
else
ifdef CIRCLE_BUILD_NUM
	@test "$(CIRCLE_BUILD_NUM)-$(CIRCLE_BRANCH)" = "$(BUILD_NUM)"
endif
endif
