# sets some useful variables

ifndef COMMON_MAKE_BASE_INCLUDED

  # probably not a good idea to override this
  ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

  # override to use eg your own checkout for making pr's to upstream
  COMMON_MAKE_DIR ?= $(ROOT_DIR)/devops/make

  COMMON_MAKE_BASE_INCLUDED := true

endif
