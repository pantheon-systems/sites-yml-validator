# Provides deploy targets which use kustomize to apply kube manifests to a kube server.
#
# TARGETS
#
# - build-kustomize:  builds the provided kustomization and prints it to stdout
# - deploy-kustomize: builds the provided kustomization and applies it to the kube cluster
# - diff-kustomize:   builds the provided kustomization and diffs it with the contents within the kube cluster
#
# INPUT VARIABLES
#
# Required: (only one of the two are required)
#  - INSTANCE:      the instance of the app to deploy
#  - KUSTOMIZATION: the path to the kustomization to deploy
#                   (defaults to devops/kustomize/instances/$INSTANCE)
#
# Optional:
#  - KUSTOMIZE_CMD:   path to the kustomize command line utility
#                     (determined from $PATH if not provided)
#
# Variables set by other makefiles:
#  - COMMON_MAKE_DIR: path to the common makefiles directory (common.mk)
#  - IMAGE:           the image to deploy (common-docker.mk)
#  - KUBE_NAMESPACE:  the namespace to deploy to (common-kube.mk)
#  - KUBE_CONTEXT:    the kube context to deploy to (common-kube.mk)
#  - KUBECTL_CMD:     path to the kubectl command line utility (common-kube.mk)
#
# EXPORT VARIABLES
#    (None)
#-------------------------------------------------------------------------------

# override when using recursive make
COMMON_MAKE_DIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/devops/make
include $(COMMON_MAKE_DIR)/_base.mk


ifndef KUSTOMIZATION
  ifdef INSTANCE
    # If KUSTOMIZATION is not provided, but INSTANCE is, set KUSTOMIZATION appropriately.
    KUSTOMIZATION := devops/kustomize/instances/$(INSTANCE)
  endif
  # If neither is provided, an error is raised by the _check_kustomize_vars target
endif

ifndef KUSTOMIZE_CMD
  ifneq (, $(shell command -v kustomize;))
    KUSTOMIZE_CMD := kustomize
  endif
endif

ifdef IMAGE
  TARGET_IMAGE := $(IMAGE)
else
  TARGET_IMAGE := $(AR_IMAGE)
endif


.PHONY:: build-kustomize deploy-kustomize diff-kustomize _check_kustomize_vars


build-kustomize:: _check_kustomize_vars
	@cd $(KUSTOMIZATION) && $(KUSTOMIZE_CMD) edit set image $(TARGET_IMAGE)
	@# Note: kubectl <=1.20 uses an outdated embedded version of kustomize.
	@# See https://github.com/kubernetes-sigs/kustomize#kubectl-integration
	@# Prefer invoking the kustomize tool directly, as it's more likely to be up-to-date.
	@$(KUSTOMIZE_CMD) build $(KUSTOMIZATION)


deploy-kustomize:: _check_kustomize_vars
	@cd $(KUSTOMIZATION) && $(KUSTOMIZE_CMD) edit set image $(TARGET_IMAGE)
	@# Note: kubectl <=1.20 uses an outdated embedded version of kustomize.
	@# See https://github.com/kubernetes-sigs/kustomize#kubectl-integration
	@# Prefer invoking the kustomize tool directly, as it's more likely to be up-to-date.
	$(KUSTOMIZE_CMD) build $(KUSTOMIZATION) | $(KUBECTL_CMD) apply -f -


diff-kustomize:: _check_kustomize_vars
	@cd $(KUSTOMIZATION) && $(KUSTOMIZE_CMD) edit set image $(TARGET_IMAGE)
	@# Note: kubectl <=1.20 uses an outdated embedded version of kustomize.
	@# See https://github.com/kubernetes-sigs/kustomize#kubectl-integration
	@# Prefer invoking the kustomize tool directly, as it's more likely to be up-to-date.
	$(KUSTOMIZE_CMD) build $(KUSTOMIZATION) | $(KUBECTL_CMD) diff -f -


_check_kustomize_vars:
ifndef KUSTOMIZATION
	$(error "KUSTOMIZATION is not set. You must provide INSTANCE or KUSTOMIZATION as input variables" )
endif
ifndef TARGET_IMAGE
	$(error "TARGET_IMAGE is not set. You must provide IMAGE (usually by including common-docker.mk or common-docker-quay.mk in your project Makefile) or AR_IMAGE (by including common-docker-ar.mk)" )
endif
ifndef KUSTOMIZE_CMD
	$(error "kustomize is not installed. You must have kustomize installed to use common-kustomize.mk" )
endif

