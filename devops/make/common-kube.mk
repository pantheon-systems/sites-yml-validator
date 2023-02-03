# Common kube things. This is the simplest set of common kube tasks
#
# INPUT VARIABLES
#  - APP: should be defined in your topmost Makefile
#  - SECRET_FILES: list of files that should exist in secrets/* used by
#                  _validate_secrets task
#
# EXPORT VARIABLES
#   - KUBE_NAMESPACE: represents the kube namespace that has been detected based on
#              branch build and circle existence.
#   - KUBE_CONTEXT: set this variable to whatever kubectl reports as the default
#                   context
#   - KUBECTL_CMD: sets up cubectl with the namespace + context for easy usage
#                  in top level make files
#-------------------------------------------------------------------------------

# gcloud auth split out of kubect so we need to set this to make things work.
# We may need to add this to some common circle context to make this less painful.
USE_GKE_GCLOUD_AUTH_PLUGIN ?= true
export USE_GKE_GCLOUD_AUTH_PLUGIN

_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Defaults (change with docs)
_DEFAULT_PROD_CONTEXT := gke_pantheon-internal_us-central1_general-01
_DEFAULT_SANDBOX_CONTEXT := gke_pantheon-sandbox_us-central1_sandbox-01
_TEMPLATE_SANDBOX_CONTEXT := gke_pantheon-sandbox_us-east4_sandbox-02

include $(_DIR)/_base.mk


## Append tasks to the global tasks
deps-circle:: deps-circle-kube
lint::
  ifndef SKIP_KUBEVAL
		make lint-kubeval
  endif

  ifdef SKIP_KUBEVAL
		echo "Skipping KUBEVAL because env var 'SKIP_KUBEVAL' is defined"
  endif

clean:: clean-kube

# Contexts and namespaces
#
# Defaults:
#
# | CircleCI | Branch        | Default context | Default namespace      |
# |----------|---------------|-----------------|------------------------|
# | Yes      | master / main | general-01      | production             |
# | Yes      | Other branch  | sandbox-01      | sandbox-[APP]-[BRANCH] |
# | No       | Any branch    | [pants default] | [pants default]        |
#
# Overrides:
#
# - Context:             KUBE_CONTEXT=gke_pantheon-internal_us-west1_general-04
# - Abbreviated context: CLUSTER_DEFAULT=general-04
# - Namespace:           KUBE_NAMESPACE=namespace
# - Template sandbox:    KUBE_NAMESPACE=template-sandbox
#   ... equivalent to:   KUBE_NAMESPACE=template-sandbox CLUSTER_DEFAULT=sandbox-02

# this fetches the long name of the cluster
ifdef CLUSTER_DEFAULT
   KUBE_CONTEXT ?= $(shell kubectl config get-contexts | grep $(CLUSTER_DEFAULT) | tr -s ' ' | cut -d' ' -f2)
endif

# Use pants to divine the namespace on local development, if unspecified.
ifndef CIRCLECI
  KUBE_NAMESPACE ?= $(shell pants config get default-sandbox-name 2> /dev/null)
  KUBE_CONTEXT ?= $(shell pants sandbox | grep targetcluster | awk '{ print $$2 }')
endif

# Default kube context based on above rules
ifndef KUBE_CONTEXT
  KUBE_CONTEXT := $(_DEFAULT_SANDBOX_CONTEXT)

  ifneq ($(filter $(BRANCH),$(DEFAULT_BRANCHES)),) # master or main
    KUBE_CONTEXT := $(_DEFAULT_PROD_CONTEXT)
  endif
endif

# Default kube namespace based on above rules
ifndef KUBE_NAMESPACE
  # If on circle and not on master, build into a sandbox environment.
  # lower-cased for naming rules of sandboxes
  BRANCH_LOWER := $(shell echo $(BRANCH) | tr A-Z a-z)
  KUBE_NAMESPACE := sandbox-$(APP)-$(BRANCH_LOWER)

  ifneq ($(filter $(BRANCH),$(DEFAULT_BRANCHES)),) # master or main
    KUBE_NAMESPACE := production
  endif
else
  KUBE_NAMESPACE := $(shell echo $(KUBE_NAMESPACE) | tr A-Z a-z)
endif

ifndef UPDATE_GCLOUD
  UPDATE_GCLOUD := true
endif

ifndef LABELS
  LABELS := app=$(APP)
endif

# template-sandbox lives in sandbox-02, force it to always use that cluster
ifeq ($(KUBE_NAMESPACE), template-sandbox)
  KUBE_CONTEXT := $(_TEMPLATE_SANDBOX_CONTEXT)
endif

KUBECTL_CMD=kubectl --namespace=$(KUBE_NAMESPACE) --context=$(KUBE_CONTEXT)

# extend or define circle deps to install gcloud
ifeq ($(UPDATE_GCLOUD), true)
  deps-circle-kube:: install-update-kube setup-kube
else
  deps-circle-kube:: setup-kube
endif

install-update-kube::
	$(call INFO, "updating or install gcloud cli")
	@if command -v gcloud >/dev/null; then \
		$(COMMON_MAKE_DIR)/sh/update-gcloud.sh > /dev/null ; \
	else  \
		$(COMMON_MAKE_DIR)/sh/install-gcloud.sh > /dev/null ; \
	fi

setup-kube::
	$(call INFO, "setting up gcloud cli")
	@$(COMMON_MAKE_DIR)/sh/setup-gcloud.sh

update-secrets:: ## update secret volumes in a kubernetes cluster
	$(call INFO, "updating secrets for $(KUBE_NAMESPACE) in $(KUBE_CONTEXT)")
	@APP=$(APP) KUBE_NAMESPACE=$(KUBE_NAMESPACE) KUBE_CONTEXT=$(KUBE_CONTEXT) LABELS=$(LABELS) \
		$(COMMON_MAKE_DIR)/sh/update-kube-object.sh $(ROOT_DIR)/devops/k8s/secrets > /dev/null

update-configmaps:: ## update configmaps in a kubernetes cluster
	$(call INFO, "updating configmaps for $(KUBE_NAMESPACE) in $(KUBE_CONTEXT)")
	@APP=$(APP) KUBE_NAMESPACE=$(KUBE_NAMESPACE) KUBE_CONTEXT=$(KUBE_CONTEXT) LABELS=$(LABELS) \
		$(COMMON_MAKE_DIR)/sh/update-kube-object.sh $(ROOT_DIR)/devops/k8s/configmaps > /dev/null

clean-secrets:: ## delete local secrets
	$(call INFO, "cleaning local Kube secrets")
	@git clean -dxf $(ROOT_DIR)/devops/k8s/secrets

clean-kube:: clean-secrets

verify-deployment-rollout:: ## validate that deployment to kube was successful and rollback if not
	@$(KUBECTL_CMD) rollout status deployment/$(APP) --timeout=10m \
		| grep 'successfully' && echo 'Deploy succeeded.' && exit 0 \
		|| echo 'Deploy unsuccessful. Rolling back. Investigate!' \
			&& $(KUBECTL_CMD) rollout undo deployment/$(APP) && exit 1

# set SECRET_FILES to a list, and this will ensure they are there
_validate-secrets::
		@for j in $(SECRET_FILES) ; do \
			if [ ! -e secrets/$$j ] ; then  \
			echo "Missing file: secrets/$$j" ;\
				exit 1 ;  \
			fi \
		done

# legacy compat
ifdef YAMLS
  KUBE_YAMLS ?= YAMLS
endif

KUBE_YAMLS_PATH ?= ./devops/k8s
KUBE_YAMLS_EXCLUDED_PATHS ?= configmaps

KUBEVAL_SKIP_CRDS ?=
ifneq (,$(KUBEVAL_SKIP_CRDS))
  KUBEVAL_SKIP_CRDS := --ignore-missing-schemas
endif

ifndef KUBE_YAMLS_CMD
  KUBE_YAMLS_CMD := find . -path '$(KUBE_YAMLS_PATH)/*' \
    $(foreach kube_excluded,$(KUBE_YAMLS_EXCLUDED_PATHS),\
      -not -path '$(KUBE_YAMLS_PATH)/$(kube_excluded)/*') \
    \( -name '*.yaml' -or -name '*.yml' \)
endif

ifdef KUBEVAL_SKIP_TEMPLATES
  KUBE_YAMLS_CMD := $(KUBE_YAMLS_CMD) | grep -vF 'template.'
endif

# use subshell to allow dependency tasks to update manifests
KUBEVAL_CMD := kubeval --strict $(KUBEVAL_SKIP_CRDS) $$($(KUBE_YAMLS_CMD))
ifdef KUBE_YAMLS
  KUBEVAL_CMD := kubeval --strict $(KUBEVAL_SKIP_CRDS) $(KUBE_YAMLS)
endif

lint-kubeval:: ## validate kube yamls
  ifneq (, $(wildcard ${KUBE_YAMLS_PATH}/*))
    ifeq (, $(shell command -v kubeval;))
		$(error "kubeval is not installed! please install it.")
    else
		${KUBEVAL_CMD}
    endif
  endif

.PHONY::  deps-circle force-pod-restart
