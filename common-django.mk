# Common Django app Tasks
#
# INPUT VARIABLES
#	- APP: (required) The name of the app.
#	- PYTHON_PACKAGE_NAME: (required) The base python package name.
#	- KUBE_NAMESPACE: The namespace to run the migrations in
#	- KUBE_CONTEXT: The kube context representing the cluster for the namespace
#	- KUBECTL_CMD: The path to kubectl
#-------------------------------------------------------------------------------

MIGRATE_APP=$(APP)-migrate
APP_DATABASE?=$(subst -,_,$(APP))

ifeq ($(KUBE_NAMESPACE), production)
	MIGRATE_COMMAND := '/app/.venv/bin/$(APP)', 'migrate', '--settings', '$(PYTHON_PACKAGE_NAME).settings.kube_production'
	PROJECT := pantheon-internal
else
	MIGRATE_COMMAND := '/app/.venv/bin/$(APP)', 'migrate', '--settings', '$(PYTHON_PACKAGE_NAME).settings.kube_sandbox'
	PROJECT := pantheon-sandbox
endif

test:: test-django

test-django:
	DJANGO_SETTINGS_MODULE=$(PYTHON_PACKAGE_NAME).settings.circleci pipenv run py.test

mysql-init-local: mysql-dump-local
	@mysql -uroot -e "CREATE USER '$(APP_DATABASE)'@'localhost' IDENTIFIED BY '$(APP_DATABASE)'; \
		GRANT ALL PRIVILEGES ON * . * to '$(APP_DATABASE)'@'localhost'; \
		FLUSH PRIVILEGES;"
	@./create-local-settings.sh $(APP_DATABASE)

mysql-dump-local:
	@gcloud sql export sql $(APP)-failover gs://$(APP)/database/dump -d production --project pantheon-internal
	@gsutil cp gs://$(APP)/database/dump /tmp/dump
	@mysql -uroot -e 'DROP DATABASE IF EXISTS $(APP_DATABASE)'
	@sed -i -e "s@\`production\`@\`$(APP_DATABASE)\`@" /tmp/dump
	@mysql -uroot </tmp/dump

mysql-cleanup-local:
	@mysql -uroot -e "DROP USER IF EXISTS '$(APP_DATABASE)'@'localhost'; \
		DROP DATABASE IF EXISTS $(APP_DATABASE);"

migrate: migrate-clean migrate-create-database migrate-job check-migration-status display-migration-logs

migrate-clean:
	$(KUBECTL_CMD) delete job/$(MIGRATE_APP) || true

migrate-create-database:
	gcloud sql databases list \
		--filter=$(KUBE_NAMESPACE) \
		--project=$(PROJECT) \
		--instance=$(APP) \
	| grep -qw $(KUBE_NAMESPACE) \
	|| gcloud sql databases create $(KUBE_NAMESPACE) \
		--charset=utf8 \
		--project=$(PROJECT) \
		--instance=$(APP)

migrate-job:
	test "$(IMAGE)" \
		-a "$(APP)" \
		-a "$(BUILD_NUM)" \
		-a "$(KUBE_NAMESPACE)" \
		-a "$(MIGRATE_COMMAND)" \
		-a "$(PROJECT)"
	sed -e "s#__IMAGE__#$(IMAGE)#" \
		-e "s#__APP__#$(APP)#g" \
		-e "s#__MIGRATE_APP__#$(MIGRATE_APP)#" \
		-e "s/__BUILD__/$(BUILD_NUM)/" \
		-e "s/__KUBE_NAMESPACE__/$(KUBE_NAMESPACE)/" \
		-e "s@__COMMAND__@$(MIGRATE_COMMAND)@" \
		-e "s/__PROJECT__/$(PROJECT)/" \
		devops/k8s/migrate.yml \
		| $(KUBECTL_CMD) create -f -

check-migration-status:
	RETRY=0; while true; do \
		STATUS=$$($(KUBECTL_CMD) get pods \
			-l app=$(MIGRATE_APP) \
			-o=jsonpath='{.items[0].status.containerStatuses[?(@.name=="$(MIGRATE_APP)")].state.terminated.reason}'); \
		[ "$$STATUS" = Completed ] \
			&& echo 'Migration successful. Removing job.' \
			&& exit 0; \
		[ "$$STATUS" = Error ] \
			&& echo && echo 'Migration failed. Investigate.' \
			&& exit 1; \
		RETRY=$$(($$RETRY+1)) ; \
		[ "$$RETRY" = 60 ] && echo 'Migration timed out. Investigate.' && exit 2; \
		echo 'Waiting for migration'; \
		sleep 10; \
	done

display-migration-logs:
	$(KUBECTL_CMD) logs job/$(MIGRATE_APP) -c $(MIGRATE_APP) || true
