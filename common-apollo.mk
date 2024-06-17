# Common Apollo Tasks
#
# INPUT VARIABLES
#	- APP: (required) The name of the app.
#	- GQL_SCHEMA_PATH: (required) path to the schema.graphqls file.
#	- APOLLO_GRAPH_TARGET: (optional) the name of the graph to check or update against. Defaults to "pantheon".
#       - APOLLO_VARIANT_TARGET: (optional) the name of the variant to check or update. Defaults to "current".
#	
#-------------------------------------------------------------------------------

APOLLO_GRAPH_TARGET ?= pantheon
APOLLO_VARIANT_TARGET ?= current

update-apollo-schema: ## Updates schema for your app on Apollo Studio
	rover subgraph publish $(APOLLO_GRAPH_TARGET)@$(APOLLO_VARIANT_TARGET) \
	--schema $(GQL_SCHEMA_PATH) \
	--name $(APP) \
	--routing-url https://$(APP)/graphql/

check-apollo-schema: ## Checks schema changes against production to ensure any changes are compatable
	@if rover subgraph list $(APOLLO_GRAPH_TARGET)@$(APOLLO_VARIANT_TARGET) | grep -wq $(APP); then \
		echo "'$(APP)' found in the current Graph, running schema check"; \
		rover subgraph check $(APOLLO_GRAPH_TARGET)@$(APOLLO_VARIANT_TARGET) --schema $(GQL_SCHEMA_PATH) --name $(APP); \
	else \
		echo "'$(APP)' not found in the current Graph, skipping schema check"; \
	fi
