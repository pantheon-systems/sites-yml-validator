package validator

import (
	"errors"
	"fmt"
	"os"
)

type PantheonValidator struct{}

// ValidateFromYaml asserts a given pantheon.yaml file is valid.
func (v *PantheonValidator) ValidateFromYaml(y []byte) error {
	return errors.New("Not yet implemented")
}

func (v *PantheonValidator) ValidateFromFilePath(filePath string) error {
	yFile, err := os.ReadFile(filePath)
	if err != nil {
		return fmt.Errorf("error reading YAML file: %w", err)
	}
	return v.ValidateFromYaml(yFile)
}
