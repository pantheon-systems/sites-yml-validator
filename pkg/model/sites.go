package model

// SitesYml is used to map domains across environments for search and replace with WPMS sites.
type SitesYml struct {
	APIVersion int        `yaml:"api_version"`
	DomainMaps DomainMaps `yaml:"domain_maps"`
}

// DomainMaps is a collection of site ID/site domains keyed by environment name.
type DomainMaps map[string]DomainMapByEnvironment

// DomainMapByEnvironment is a collection of site domains keyed by site ID.
//
// Given an int is valid in yaml but not json, and it is difficult to validate
// if a key is an int or string in PHP (c/f terminus-yml-validator-plugin), it
// is easiest to unmarshal into a string, and check that the key is also a
// valid site ID as part of the validator.
type DomainMapByEnvironment map[string]string
