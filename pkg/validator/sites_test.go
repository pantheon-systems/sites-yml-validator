package validator

import (
	"errors"
	"fmt"
	"sites-yml-validator/pkg/model"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"gopkg.in/yaml.v3"
)

func TestValidateAPIVersion(t *testing.T) {
	for _, tc := range []struct {
		version  int
		expected error
	}{
		{1, nil},
		{2, ErrInvalidAPIVersion},
	} {
		t.Run(fmt.Sprintf("%v", tc.version), func(t *testing.T) {
			err := validateAPIVersion(tc.version)
			assert.ErrorIs(t, err, tc.expected)
		})
	}
}

func TestValidate(t *testing.T) {
	for _, tc := range []struct {
		name     string
		sitesYml model.SitesYml
		expected error
	}{
		{
			"valid only api version",
			model.SitesYml{APIVersion: 1},
			nil,
		},
		{
			"invalid api version",
			model.SitesYml{APIVersion: 2},
			ErrInvalidAPIVersion,
		},
		{
			"valid domain maps",
			model.SitesYml{
				APIVersion: 1,
				DomainMaps: model.DomainMaps{
					"dev": model.DomainMapByEnvironment{
						1: "blog1.dev-mysite.pantheonsite.io",
					},
					"test": model.DomainMapByEnvironment{
						1: "blog1.dev-mysite.pantheonsite.io",
					},
					"live": model.DomainMapByEnvironment{
						1: "blog1.mysite.com",
					},
					"autopilot": model.DomainMapByEnvironment{
						1: "blog1.autopilot-mysite.pantheonsite.io",
					},
				},
			},
			nil,
		},
		{
			"invalid domain maps long env",
			model.SitesYml{
				APIVersion: 1,
				DomainMaps: model.DomainMaps{
					"dev": model.DomainMapByEnvironment{
						1: "blog1.dev-mysite.pantheonsite.io",
					},
					"mylongmultidevname": model.DomainMapByEnvironment{
						1: "blog1.mylongmultidevname-mysite.pantheonsite.io",
					},
				},
			},
			errors.New(`"mylongmultidevname" is not a valid environment name`),
		},
		{
			"invalid domain maps bad env name",
			model.SitesYml{
				APIVersion: 1,
				DomainMaps: model.DomainMaps{
					"dev": model.DomainMapByEnvironment{
						1: "blog1.dev-mysite.pantheonsite.io",
					},
					"feat_branch": model.DomainMapByEnvironment{
						1: "blog1.feat-branch-mysite.pantheonsite.io",
					},
				},
			},
			errors.New(`"feat_branch" is not a valid environment name`),
		},
		{
			"invalid domain maps too many domains",
			model.SitesYml{
				APIVersion: 1,
				DomainMaps: model.DomainMaps{
					"dev": model.DomainMapByEnvironment{
						1:  "blog1.dev-mysite.pantheonsite.io",
						2:  "blog2.dev-mysite.pantheonsite.io",
						3:  "blog3.dev-mysite.pantheonsite.io",
						4:  "blog4.dev-mysite.pantheonsite.io",
						5:  "blog5.dev-mysite.pantheonsite.io",
						6:  "blog6.dev-mysite.pantheonsite.io",
						7:  "blog7.dev-mysite.pantheonsite.io",
						8:  "blog8.dev-mysite.pantheonsite.io",
						9:  "blog9.dev-mysite.pantheonsite.io",
						10: "blog10.dev-mysite.pantheonsite.io",
						11: "blog11.dev-mysite.pantheonsite.io",
						12: "blog12.dev-mysite.pantheonsite.io",
						13: "blog13.dev-mysite.pantheonsite.io",
						14: "blog14.dev-mysite.pantheonsite.io",
						15: "blog15.dev-mysite.pantheonsite.io",
						16: "blog16.dev-mysite.pantheonsite.io",
						17: "blog17.dev-mysite.pantheonsite.io",
						18: "blog18.dev-mysite.pantheonsite.io",
						19: "blog19.dev-mysite.pantheonsite.io",
						20: "blog20.dev-mysite.pantheonsite.io",
						21: "blog21.dev-mysite.pantheonsite.io",
						22: "blog22.dev-mysite.pantheonsite.io",
						23: "blog23.dev-mysite.pantheonsite.io",
						24: "blog24.dev-mysite.pantheonsite.io",
						25: "blog25.dev-mysite.pantheonsite.io",
						26: "blog26.dev-mysite.pantheonsite.io",
						27: "blog27.dev-mysite.pantheonsite.io",
						28: "blog28.dev-mysite.pantheonsite.io",
						29: "blog29.dev-mysite.pantheonsite.io",
					},
					"mdev": model.DomainMapByEnvironment{
						1: "blog1.mdev-mysite.pantheonsite.io",
					},
				},
			},
			errors.New(`"dev" has too many domains listed (29). Maximum is 25`),
		},
		{
			"invalid hostname",
			model.SitesYml{
				APIVersion: 1,
				DomainMaps: model.DomainMaps{
					"dev": model.DomainMapByEnvironment{
						1: "blog1.dev-mysite.pantheonsite.io",
					},
					"test": model.DomainMapByEnvironment{
						1: "$(sudo do something dangerous)",
					},
					"live": model.DomainMapByEnvironment{
						1: "blog1.mysite.com",
					},
				},
			},
			errors.New(`"$(sudo do something dangerous)" is not a valid hostname`),
		},
	} {
		t.Run(tc.name, func(t *testing.T) {
			v, err := ValidatorFactory("sites")
			require.NoError(t, err)
			err = v.(*SitesValidator).validate(tc.sitesYml)
			if tc.expected == nil {
				assert.NoError(t, err)
				return
			}
			assert.EqualError(t, err, tc.expected.Error())
		})
	}
}

func TestValidateFromYaml(t *testing.T) {
	for _, tc := range []struct {
		name     string
		yaml     string
		expected error
	}{
		{
			name: "only api_version",
			yaml: `
			---
			api_version: 1`,
			expected: nil,
		},
		{
			name: "invalid api_version ",
			yaml: `
			---
			api_version: 2`,
			expected: ErrInvalidAPIVersion,
		},
		{
			name: "invalid api_version ",
			yaml: `this is not good yaml`,
			expected: &yaml.TypeError{
				Errors: []string{
					"line 1: cannot unmarshal !!str `this is...` into model.SitesYml",
				},
			},
		},
	} {
		t.Run(tc.name, func(t *testing.T) {
			yaml := []byte(
				// Yaml doesn't like tabs, but lets us make our test cases prettier
				strings.ReplaceAll(tc.yaml, "\t", ""),
			)

			v, err := ValidatorFactory("sites")
			require.NoError(t, err)
			err = v.ValidateFromYaml(yaml)
			if tc.expected == nil {
				assert.NoError(t, err)
				return
			}
			// TODO: assert.ErrorIs would be a better test.
			assert.EqualError(t, err, tc.expected.Error())
		})
	}
}

func TestValidateSitesFromFilePath(t *testing.T) {
	for _, tc := range []struct {
		fixtureName string
		expected    error
	}{
		{"invalid_api_version_only", ErrInvalidAPIVersion},
		{"valid_api_version_only", nil},
		{"valid", nil},
		{
			"this_file_does_not_exist",
			errors.New(
				"error reading YAML file: open ../../fixtures/sites/this_file_does_not_exist.yml: no such file or directory",
			),
		},
	} {
		t.Run(tc.fixtureName, func(t *testing.T) {
			v, err := ValidatorFactory("sites")
			require.NoError(t, err)
			filePath := fmt.Sprintf("../../fixtures/sites/%s.yml", tc.fixtureName)

			err = v.ValidateFromFilePath(filePath)
			if tc.expected == nil {
				assert.NoError(t, err)
				return
			}

			// TODO: assert.ErrorIs would be a better test.
			assert.EqualError(t, err, tc.expected.Error())
		})
	}
}
