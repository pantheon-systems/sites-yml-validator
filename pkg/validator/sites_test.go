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
						"1": "site1.dev-mysite.pantheonsite.io",
					},
					"test": model.DomainMapByEnvironment{
						"1": "site1.dev-mysite.pantheonsite.io",
					},
					"live": model.DomainMapByEnvironment{
						"1": "site1.mysite.com",
					},
					"autopilot": model.DomainMapByEnvironment{
						"1": "site1.autopilot-mysite.pantheonsite.io",
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
						"1": "site1.dev-mysite.pantheonsite.io",
					},
					"mylongmultidevname": model.DomainMapByEnvironment{
						"1": "site1.mylongmultidevname-mysite.pantheonsite.io",
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
						"1": "site1.dev-mysite.pantheonsite.io",
					},
					"feat_branch": model.DomainMapByEnvironment{
						"1": "site1.feat-branch-mysite.pantheonsite.io",
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
						"1":  "site1.dev-mysite.pantheonsite.io",
						"2":  "site2.dev-mysite.pantheonsite.io",
						"3":  "site3.dev-mysite.pantheonsite.io",
						"4":  "site4.dev-mysite.pantheonsite.io",
						"5":  "site5.dev-mysite.pantheonsite.io",
						"6":  "site6.dev-mysite.pantheonsite.io",
						"7":  "site7.dev-mysite.pantheonsite.io",
						"8":  "site8.dev-mysite.pantheonsite.io",
						"9":  "site9.dev-mysite.pantheonsite.io",
						"10": "site10.dev-mysite.pantheonsite.io",
						"11": "site11.dev-mysite.pantheonsite.io",
						"12": "site12.dev-mysite.pantheonsite.io",
						"13": "site13.dev-mysite.pantheonsite.io",
						"14": "site14.dev-mysite.pantheonsite.io",
						"15": "site15.dev-mysite.pantheonsite.io",
						"16": "site16.dev-mysite.pantheonsite.io",
						"17": "site17.dev-mysite.pantheonsite.io",
						"18": "site18.dev-mysite.pantheonsite.io",
						"19": "site19.dev-mysite.pantheonsite.io",
						"20": "site20.dev-mysite.pantheonsite.io",
						"21": "site21.dev-mysite.pantheonsite.io",
						"22": "site22.dev-mysite.pantheonsite.io",
						"23": "site23.dev-mysite.pantheonsite.io",
						"24": "site24.dev-mysite.pantheonsite.io",
						"25": "site25.dev-mysite.pantheonsite.io",
						"26": "site26.dev-mysite.pantheonsite.io",
						"27": "site27.dev-mysite.pantheonsite.io",
						"28": "site28.dev-mysite.pantheonsite.io",
						"29": "site29.dev-mysite.pantheonsite.io",
					},
					"mdev": model.DomainMapByEnvironment{
						"1": "site1.mdev-mysite.pantheonsite.io",
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
						"1": "site1.dev-mysite.pantheonsite.io",
					},
					"test": model.DomainMapByEnvironment{
						"1": "$(sudo do something dangerous)",
					},
					"live": model.DomainMapByEnvironment{
						"1": "site1.mysite.com",
					},
				},
			},
			errors.New(`"$(sudo do something dangerous)" is not a valid hostname`),
		},
		{
			"invalid site id",
			model.SitesYml{
				APIVersion: 1,
				DomainMaps: model.DomainMaps{
					"dev": model.DomainMapByEnvironment{
						"foo": "site1.dev-mysite.pantheonsite.io",
					},
					"test": model.DomainMapByEnvironment{
						"foo": "site1.test-mysite.pantheonsite.io",
					},
				},
			},
			errors.New(`"foo" is not a valid site ID`),
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
		{"valid_string_as_key", nil},
		{"valid_both_string_and_int_key", nil},
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

func TestIsValidSiteID(t *testing.T) {
	for _, tc := range []struct {
		input    string
		expected bool
	}{
		{"1", true},
		{"300", true},
		{"foo", false},
		{"i", false},
		{"1a", false},
		{"", false},
		{"1.2", false},
		{".2", false},
		{"0.2", false},
		{"1.0", false},
		{"0", false},
		{"00", false},
		{"01", false},
		{"-5", false},
	} {
		t.Run(tc.input, func(t *testing.T) {
			assert.Equal(t, tc.expected, isValidSiteID(tc.input))
		})
	}
}
