APP=common-make-kube
SKIP_KUBEVAL := true

ifdef CIRCLE_BUILD_NUM
  BUILD_NUM = $(CIRCLE_BUILD_NUM)
else
  BUILD_NUM = $(shell git rev-parse HEAD | grep -o '....$$')
endif

include common.mk
KUBE_NAMESPACE := $(APP)-$(BRANCH)-$(BUILD_NUM)
include common-kube.mk

test-common-kube-lint: lint

test-common-kube: test-common-kube-lint
	$(call INFO, "Creating kube ns $(KUBE_NAMESPACE)")
	-@$(KUBECTL_CMD) delete namespace --wait=true $(KUBE_NAMESPACE) > /dev/null
	@$(KUBECTL_CMD) create namespace $(KUBE_NAMESPACE) > /dev/null
	@sleep 1
	$(call INFO, "running kube common tests in kube ns $(KUBE_NAMESPACE) and context $(KUBE_CONTEXT)")
	@APP=$(APP) KUBE_NAMESPACE=$(KUBE_NAMESPACE) KUBE_CONTEXT=$(KUBE_CONTEXT) LABELS=$(LABELS) \
		bash sh/update-kube-object.sh ./test/fixtures/secrets > /dev/null
	@APP=$(APP) KUBE_NAMESPACE=$(KUBE_NAMESPACE) KUBE_CONTEXT=$(KUBE_CONTEXT) LABELS=$(LABELS) \
		bash sh/update-kube-object.sh ./test/fixtures/configmaps > /dev/null
	$(call INFO, "Verifying kube common secrets and maps for $(APP) in $(KUBE_NAMESPACE)")
	@$(KUBECTL_CMD) get secret		$(APP)-supersecret > /dev/null
	@$(KUBECTL_CMD) get configmap $(APP)-foofile		 > /dev/null
	$(call INFO, "cleaning up testing namespace $(KUBE_NAMESPACE)")
	@$(KUBECTL_CMD) delete namespace --wait=false $(KUBE_NAMESPACE) 2> /dev/null
