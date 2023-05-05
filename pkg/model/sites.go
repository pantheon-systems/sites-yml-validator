package model

import (
	"fmt"
)

type ConvertBool bool

// SitesYml is used to map domains across environments for search and replace with WPMS sites.
type SitesYml struct {
	APIVersion            int         `yaml:"api_version"`
	ConvertToSubdirectory ConvertBool `yaml:"convert_to_subdirectory"`
	DomainMaps            DomainMaps  `yaml:"domain_maps"`
}

// DomainMaps is a collection of site ID/site domains keyed by environment name.
type DomainMaps map[string]DomainMapByEnvironment

// DomainMapByEnvironment is a collection of site domains keyed by site ID.
type DomainMapByEnvironment map[int]string

// A custom Unmarshal method for ConvertBool, accepting true, false, 1, or 0
// for convert_to_subdirectory.
func (convert *ConvertBool) UnmarshalYAML(unmarshal func(interface{}) error) error {
	var val interface{}
	if err := unmarshal(&val); err != nil {
		return err
	}

	switch v := val.(type) {
	case bool:
		*convert = ConvertBool(v)
	case int:
		if v != 1 && v != 0 {
			return fmt.Errorf(
				"unexpected int %v for convert_to_subdirectory. Value must be true, false, 1, or 0.",
				v,
			)
		}
		*convert = v != 0
	default:
		return fmt.Errorf("unexpected type %T for convert_to_subdirectory", v)
	}

	return nil
}
