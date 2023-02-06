package validator

import (
	"fmt"
	"os"
)

type PantheonValidator struct{}

// ValidateFromYaml asserts a given pantheon.yaml file is valid.
// As this has not been implemented, nothing is invalid.
func (v *PantheonValidator) ValidateFromYaml(y []byte) error {
	return nil
}

func (v *PantheonValidator) ValidateFromFilePath(filePath string) error {
	yFile, err := os.ReadFile(filePath)
	if err != nil {
		return fmt.Errorf("error reading YAML file: %w", err)
	}
	return v.ValidateFromYaml(yFile)
}
