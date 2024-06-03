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
						1: "site1.dev-mysite.pantheonsite.io",
					},
					"test": model.DomainMapByEnvironment{
						1: "site1.dev-mysite.pantheonsite.io",
					},
					"live": model.DomainMapByEnvironment{
						1: "site1.mysite.com",
					},
					"autopilot": model.DomainMapByEnvironment{
						1: "site1.autopilot-mysite.pantheonsite.io",
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
						1: "site1.dev-mysite.pantheonsite.io",
					},
					"mylongmultidevname": model.DomainMapByEnvironment{
						1: "site1.mylongmultidevname-mysite.pantheonsite.io",
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
						1: "site1.dev-mysite.pantheonsite.io",
					},
					"feat_branch": model.DomainMapByEnvironment{
						1: "site1.feat-branch-mysite.pantheonsite.io",
					},
				},
			},
			errors.New(`"feat_branch" is not a valid environment name`),
		},
		{
			"valid domain maps with 29 domains",
			model.SitesYml{
				APIVersion: 1,
				DomainMaps: model.DomainMaps{
					"dev": model.DomainMapByEnvironment{
						1:  "site1.dev-mysite.pantheonsite.io",
						2:  "site2.dev-mysite.pantheonsite.io",
						3:  "site3.dev-mysite.pantheonsite.io",
						4:  "site4.dev-mysite.pantheonsite.io",
						5:  "site5.dev-mysite.pantheonsite.io",
						6:  "site6.dev-mysite.pantheonsite.io",
						7:  "site7.dev-mysite.pantheonsite.io",
						8:  "site8.dev-mysite.pantheonsite.io",
						9:  "site9.dev-mysite.pantheonsite.io",
						10: "site10.dev-mysite.pantheonsite.io",
						11: "site11.dev-mysite.pantheonsite.io",
						12: "site12.dev-mysite.pantheonsite.io",
						13: "site13.dev-mysite.pantheonsite.io",
						14: "site14.dev-mysite.pantheonsite.io",
						15: "site15.dev-mysite.pantheonsite.io",
						16: "site16.dev-mysite.pantheonsite.io",
						17: "site17.dev-mysite.pantheonsite.io",
						18: "site18.dev-mysite.pantheonsite.io",
						19: "site19.dev-mysite.pantheonsite.io",
						20: "site20.dev-mysite.pantheonsite.io",
						21: "site21.dev-mysite.pantheonsite.io",
						22: "site22.dev-mysite.pantheonsite.io",
						23: "site23.dev-mysite.pantheonsite.io",
						24: "site24.dev-mysite.pantheonsite.io",
						25: "site25.dev-mysite.pantheonsite.io",
						26: "site26.dev-mysite.pantheonsite.io",
						27: "site27.dev-mysite.pantheonsite.io",
						28: "site28.dev-mysite.pantheonsite.io",
						29: "site29.dev-mysite.pantheonsite.io",
					},
					"mdev": model.DomainMapByEnvironment{
						1: "site1.mdev-mysite.pantheonsite.io",
					},
				},
			},
			nil,
		},
		{
			"invalid domain maps too many domains",
			model.SitesYml{
				APIVersion: 1,
				DomainMaps: model.DomainMaps{
					"dev": model.DomainMapByEnvironment{
						1:  "site1.dev-mysite.pantheonsite.io",
						2:  "site2.dev-mysite.pantheonsite.io",
						3:  "site3.dev-mysite.pantheonsite.io",
						4:  "site4.dev-mysite.pantheonsite.io",
						5:  "site5.dev-mysite.pantheonsite.io",
						6:  "site6.dev-mysite.pantheonsite.io",
						7:  "site7.dev-mysite.pantheonsite.io",
						8:  "site8.dev-mysite.pantheonsite.io",
						9:  "site9.dev-mysite.pantheonsite.io",
						10: "site10.dev-mysite.pantheonsite.io",
						11: "site11.dev-mysite.pantheonsite.io",
						12: "site12.dev-mysite.pantheonsite.io",
						13: "site13.dev-mysite.pantheonsite.io",
						14: "site14.dev-mysite.pantheonsite.io",
						15: "site15.dev-mysite.pantheonsite.io",
						16: "site16.dev-mysite.pantheonsite.io",
						17: "site17.dev-mysite.pantheonsite.io",
						18: "site18.dev-mysite.pantheonsite.io",
						19: "site19.dev-mysite.pantheonsite.io",
						20: "site20.dev-mysite.pantheonsite.io",
						21: "site21.dev-mysite.pantheonsite.io",
						22: "site22.dev-mysite.pantheonsite.io",
						23: "site23.dev-mysite.pantheonsite.io",
						24: "site24.dev-mysite.pantheonsite.io",
						25: "site25.dev-mysite.pantheonsite.io",
						26: "site26.dev-mysite.pantheonsite.io",
						27: "site27.dev-mysite.pantheonsite.io",
						28: "site28.dev-mysite.pantheonsite.io",
						29: "site29.dev-mysite.pantheonsite.io",
						30: "site30.dev-mysite.pantheonsite.io",
						31: "site31.dev-mysite.pantheonsite.io",
						32: "site32.dev-mysite.pantheonsite.io",
						33: "site33.dev-mysite.pantheonsite.io",
						34: "site34.dev-mysite.pantheonsite.io",
						35: "site35.dev-mysite.pantheonsite.io",
						36: "site36.dev-mysite.pantheonsite.io",
						37: "site37.dev-mysite.pantheonsite.io",
						38: "site38.dev-mysite.pantheonsite.io",
						39: "site39.dev-mysite.pantheonsite.io",
						40: "site40.dev-mysite.pantheonsite.io",
						41: "site41.dev-mysite.pantheonsite.io",
						42: "site42.dev-mysite.pantheonsite.io",
						43: "site43.dev-mysite.pantheonsite.io",
						44: "site44.dev-mysite.pantheonsite.io",
						45: "site45.dev-mysite.pantheonsite.io",
						46: "site46.dev-mysite.pantheonsite.io",
						47: "site47.dev-mysite.pantheonsite.io",
						48: "site48.dev-mysite.pantheonsite.io",
						49: "site49.dev-mysite.pantheonsite.io",
						50: "site50.dev-mysite.pantheonsite.io",
						51: "site51.dev-mysite.pantheonsite.io",
						52: "site52.dev-mysite.pantheonsite.io",
						53: "site53.dev-mysite.pantheonsite.io",
						54: "site54.dev-mysite.pantheonsite.io",
						55: "site55.dev-mysite.pantheonsite.io",
						56: "site56.dev-mysite.pantheonsite.io",
						57: "site57.dev-mysite.pantheonsite.io",
						58: "site58.dev-mysite.pantheonsite.io",
						59: "site59.dev-mysite.pantheonsite.io",
						60: "site60.dev-mysite.pantheonsite.io",
						61: "site61.dev-mysite.pantheonsite.io",
						62: "site62.dev-mysite.pantheonsite.io",
						63: "site63.dev-mysite.pantheonsite.io",
						64: "site64.dev-mysite.pantheonsite.io",
						65: "site65.dev-mysite.pantheonsite.io",
						66: "site66.dev-mysite.pantheonsite.io",
						67: "site67.dev-mysite.pantheonsite.io",
						68: "site68.dev-mysite.pantheonsite.io",
						69: "site69.dev-mysite.pantheonsite.io",
						70: "site70.dev-mysite.pantheonsite.io",
						71: "site71.dev-mysite.pantheonsite.io",
						72: "site72.dev-mysite.pantheonsite.io",
						73: "site73.dev-mysite.pantheonsite.io",
						74: "site74.dev-mysite.pantheonsite.io",
						75: "site75.dev-mysite.pantheonsite.io",
						76: "site76.dev-mysite.pantheonsite.io",
						77: "site77.dev-mysite.pantheonsite.io",
						78: "site78.dev-mysite.pantheonsite.io",
						79: "site79.dev-mysite.pantheonsite.io",
					},
					"mdev": model.DomainMapByEnvironment{
						1: "site1.mdev-mysite.pantheonsite.io",
					},
				},
			},
			errors.New(`"dev" has too many domains listed (79). Maximum is 75`),
		},		
		{
			"invalid hostname",
			model.SitesYml{
				APIVersion: 1,
				DomainMaps: model.DomainMaps{
					"dev": model.DomainMapByEnvironment{
						1: "site1.dev-mysite.pantheonsite.io",
					},
					"test": model.DomainMapByEnvironment{
						1: "$(sudo do something dangerous)",
					},
					"live": model.DomainMapByEnvironment{
						1: "site1.mysite.com",
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
			name: "invalid yaml",
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
		{"valid_convert", nil},
		{"valid_convert_int", nil},
		{"invalid_convert_string", errors.New("unexpected type string for convert_to_subdirectory")},
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
