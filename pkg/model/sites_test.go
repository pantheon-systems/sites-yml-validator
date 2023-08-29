package model

import (
	"errors"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"gopkg.in/yaml.v3"
)

func TestUnMarshalConvertBool(t *testing.T) {
	for _, tc := range []struct {
		name        string
		yaml        string
		expected    ConvertBool
		expectedErr error
	}{
		{
			name: "missing",
			yaml: `
			---
			api_version: 1`,
			expectedErr: nil,
			expected:    false,
		},
		{
			name: "bool true",
			yaml: `
			---
			convert_to_subdirectory: true`,
			expectedErr: nil,
			expected:    true,
		},
		{
			name: "bool false",
			yaml: `
			---
			convert_to_subdirectory: false`,
			expectedErr: nil,
			expected:    false,
		},
		{
			name: "int true",
			yaml: `
			---
			convert_to_subdirectory: 1`,
			expectedErr: nil,
			expected:    true,
		},
		{
			name: "int false",
			yaml: `
			---
			convert_to_subdirectory: 0`,
			expectedErr: nil,
			expected:    false,
		},
		{
			name: "int invalid",
			yaml: `
			---
			convert_to_subdirectory: 2`,
			expectedErr: errors.New(
				"unexpected int 2 for convert_to_subdirectory. Value must be true, false, 1, or 0.",
			),
		},
		{
			name: "string invalid",
			yaml: `
			---
			convert_to_subdirectory: "foo"`,
			expectedErr: errors.New("unexpected type string for convert_to_subdirectory"),
		},
		{
			name:        "nothing",
			yaml:        `---`,
			expectedErr: nil,
			expected:    false,
		},
	} {
		t.Run(tc.name, func(t *testing.T) {
			y := []byte(
				// Yaml doesn't like tabs, but lets us make our test cases prettier
				strings.ReplaceAll(tc.yaml, "\t", ""),
			)

			var s SitesYml
			err := yaml.Unmarshal(y, &s)

			if tc.expectedErr != nil {
				assert.EqualError(t, err, tc.expectedErr.Error())
				return
			}

			assert.NoError(t, err)
			assert.Equal(t, tc.expected, s.ConvertToSubdirectory)

		})
	}
}
