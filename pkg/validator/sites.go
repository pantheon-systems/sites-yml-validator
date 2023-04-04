package validator

import (
	"fmt"
	"os"
	"pyml-validator/pkg/model"
	"regexp"

	"gopkg.in/yaml.v3"
)

const (
	maxDomainMaps          = 25 // This could be raised
	validHostnameRegex     = `^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])(\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]))*$`
	validMultidevNameRegex = `^[a-z0-9\-]{1,11}$`
)

var (
	// c/f pantheon.yml validation in titan-mt.
	validHostname     = regexp.MustCompile(validHostnameRegex)
	validMultidevName = regexp.MustCompile(validMultidevNameRegex)
)

type SitesValidator struct{}

// ValidateFromYaml asserts a given sites.yaml file is valid.
func (v *SitesValidator) ValidateFromYaml(y []byte) error {
	var s model.SitesYml

	err := yaml.Unmarshal(y, &s)
	if err != nil {
		return err
	}
	return v.validate(s)
}

func (v *SitesValidator) ValidateFromFilePath(filePath string) error {
	yFile, err := os.ReadFile(filePath)
	if err != nil {
		return fmt.Errorf("error reading YAML file: %w", err)
	}
	return v.ValidateFromYaml(yFile)
}

// validate asserts all aspects of sites.yml are valid.
func (v *SitesValidator) validate(sites model.SitesYml) error {
	err := validateAPIVersion(sites.APIVersion)
	if err != nil {
		return err
	}
	return validateDomainMaps(sites.DomainMaps)
}

// validateDomainMaps ensures the domain maps provided in sites.yml are valid
// by asserting cloud development environments names are valid, there are not
// too many domain maps listed for any environment, and that the hostnames
// provided are valid Pantheon hostnames.
func validateDomainMaps(domainMaps map[string]model.DomainMapByEnvironment) error {
	for env, domainMap := range domainMaps {
		if !validMultidevName.MatchString(env) {
			return fmt.Errorf("%q is not a valid environment name", env)
		}
		domainMapCount := len(domainMap)
		if domainMapCount > maxDomainMaps {
			return fmt.Errorf("%q has too many domains listed (%d). Maximum is %d", env, domainMapCount, maxDomainMaps)
		}
		for _, domain := range domainMap {
			if !validHostname.MatchString(domain) {
				return fmt.Errorf("%q is not a valid hostname", domain)
			}
		}
	}
	return nil
}

// validateAPIVersion asserts if sites.yml has a valid api version set. Once
// more than one version is valid, this will need to be more more robust.
func validateAPIVersion(apiVersion int) error {
	if apiVersion != 1 {
		return ErrInvalidAPIVersion
	}
	return nil
}
