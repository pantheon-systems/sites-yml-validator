package sites

import (
	"errors"
	"fmt"
	"regexp"

	"gopkg.in/yaml.v3"
)

const (
	MaxDomainMaps = 25 // This could be raised
)

var (
	ValidMultidevNameRegex = regexp.MustCompile(`^[a-z0-9\-]{1,11}$`)
	// See https://github.com/pantheon-systems/titan-mt/blob/master/yggdrasil/lib/pantheon_yml/pantheon_yml_v1_schema.py
	ValidHostnameRegex = regexp.MustCompile(`^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])(\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]))*$`)

	ErrInvalidAPIVersion = errors.New("Invalid API Version. Must be '1'")
)

// SitesYml is used to map domains across environments for search and replace with WPMS sites.
type SitesYml struct {
	APIVersion int        `yaml:"api_version"`
	DomainMaps DomainMaps `yaml:"domain_maps"`
}

type DomainMaps map[string]DomainMapByEnvironment

// DomainMapByEnvironment is a map of site (blog) domains keyed by blog ID.
type DomainMapByEnvironment map[int]string

func validate(sites SitesYml) error {
	err := validateAPIVersion(sites.APIVersion)
	if err != nil {
		return err
	}
	return validateDomainMaps(sites.DomainMaps)
}

func validateDomainMaps(domainMaps map[string]DomainMapByEnvironment) error {
	for env, domainMap := range domainMaps {
		if !ValidMultidevNameRegex.MatchString(env) {
			return fmt.Errorf("%q is not a valid environment name", env)
		}
		if len(domainMap) > MaxDomainMaps {
			return fmt.Errorf("%q has too many domains listed. Maximum is %d", env, MaxDomainMaps)
		}
		for _, domain := range domainMap {
			if !ValidHostnameRegex.MatchString(domain) {
				return fmt.Errorf("%q is not a valid hostname", domain)
			}
		}
	}
	return nil
}

func validateAPIVersion(apiVersion int) error {
	if apiVersion != 1 {
		return ErrInvalidAPIVersion
	}
	return nil
}

func ValidateFromYaml(y []byte) error {
	var s SitesYml

	err := yaml.Unmarshal(y, &s)
	if err != nil {
		return err
	}
	return validate(s)
}
