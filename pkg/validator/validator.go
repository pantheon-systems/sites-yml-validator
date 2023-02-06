package validator

import "fmt"

type Validator interface {
	ValidateFromYaml(y []byte) error
	ValidateFromFilePath(s string) error
}

func ValidatorFactory(v string) (Validator, error) {
	switch v {
	case "sites":
		return &SitesValidator{}, nil
	case "pantheon":
		return &PantheonValidator{}, nil
	default:
		return nil, fmt.Errorf(`%q is not a valid validator.`, v)
	}
}
