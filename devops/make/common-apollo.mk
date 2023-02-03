# Common Apollo Tasks
#
# INPUT VARIABLES
#	- APP: (required) The name of the app.
#	- GQL_SCHEMA_PATH: (required) path to the schema.graphqls file 
#	
#-------------------------------------------------------------------------------


update-apollo-schema: ## Updates schema for your app on Apollo Studio
	rover subgraph publish pantheon@current \
	--schema $(GQL_SCHEMA_PATH) \
	--name $(APP) \
	--routing-url https://$(APP)/graphql/

check-apollo-schema: ## Checks schema changes against production to ensure any changes are compatable
	@if rover subgraph list pantheon@current | grep -wq $(APP); then \
		echo "'$(APP)' found in the current Graph, running schema check"; \
		rover subgraph check pantheon@current --schema $(GQL_SCHEMA_PATH) --name $(APP); \
	else \
		echo "'$(APP)' not found in the current Graph, skipping schema check"; \
	fi
