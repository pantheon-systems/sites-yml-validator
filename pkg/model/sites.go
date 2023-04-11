package model

// SitesYml is used to map domains across environments for search and replace with WPMS sites.
type SitesYml struct {
	APIVersion int        `yaml:"api_version"`
	DomainMaps DomainMaps `yaml:"domain_maps"`
}

// DomainMaps is a collection of site ID/site domains keyed by environment name.
type DomainMaps map[string]DomainMapByEnvironment

// DomainMapByEnvironment is a collection of site domains keyed by site ID.
type DomainMapByEnvironment map[int]string
