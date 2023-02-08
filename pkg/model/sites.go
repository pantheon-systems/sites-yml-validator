package model

// SitesYml is used to map domains across environments for search and replace with WPMS sites.
type SitesYml struct {
	APIVersion int        `yaml:"api_version"`
	DomainMaps DomainMaps `yaml:"domain_maps"`
}

type DomainMaps map[string]DomainMapByEnvironment

// DomainMapByEnvironment is a map of site (blog) domains keyed by blog ID.
type DomainMapByEnvironment map[int]string
