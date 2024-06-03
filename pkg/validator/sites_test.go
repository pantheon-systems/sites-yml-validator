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
						1:  "basilisk.dev-mysite.pantheonsite.io",
						2:  "centaur.dev-mysite.pantheonsite.io",
						3:  "chimera.dev-mysite.pantheonsite.io",
						4:  "dragon.dev-mysite.pantheonsite.io",
						5:  "faerie.dev-mysite.pantheonsite.io",
						6:  "fenrir.dev-mysite.pantheonsite.io",
						7:  "gargoyle.dev-mysite.pantheonsite.io",
						8:  "ghoul.dev-mysite.pantheonsite.io",
						9:  "giant.dev-mysite.pantheonsite.io",
						10: "griffin.dev-mysite.pantheonsite.io",
						11: "hydra.dev-mysite.pantheonsite.io",
						12: "kraken.dev-mysite.pantheonsite.io",
						13: "lich.dev-mysite.pantheonsite.io",
						14: "manticore.dev-mysite.pantheonsite.io",
						15: "minotaur.dev-mysite.pantheonsite.io",
						16: "nymph.dev-mysite.pantheonsite.io",
						17: "ogre.dev-mysite.pantheonsite.io",
						18: "phoenix.dev-mysite.pantheonsite.io",
						19: "pixie.dev-mysite.pantheonsite.io",
						20: "satyr.dev-mysite.pantheonsite.io",
						21: "sphinx.dev-mysite.pantheonsite.io",
						22: "sprite.dev-mysite.pantheonsite.io",
						23: "troll.dev-mysite.pantheonsite.io",
						24: "unicorn.dev-mysite.pantheonsite.io",
						25: "vampire.dev-mysite.pantheonsite.io",
						26: "werewolf.dev-mysite.pantheonsite.io",
						27: "wraith.dev-mysite.pantheonsite.io",
						28: "wyvern.dev-mysite.pantheonsite.io",
						29: "yeti.dev-mysite.pantheonsite.io",
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
						1:  "aboleth.dev-mysite.pantheonsite.io",
						2:  "banshee.dev-mysite.pantheonsite.io",
						3:  "basilisk.dev-mysite.pantheonsite.io",
						4:  "basilisk.dev-mysite.pantheonsite.io",
						5:  "centaur.dev-mysite.pantheonsite.io",
						6:  "cerberus.dev-mysite.pantheonsite.io",
						7:  "chimera.dev-mysite.pantheonsite.io",
						8:  "chimera.dev-mysite.pantheonsite.io",
						9:  "cockatrice.dev-mysite.pantheonsite.io",
						10: "couatl.dev-mysite.pantheonsite.io",
						11: "cyclops.dev-mysite.pantheonsite.io",
						12: "djinn.dev-mysite.pantheonsite.io",
						13: "doppelganger.dev-mysite.pantheonsite.io",
						14: "dragon.dev-mysite.pantheonsite.io",
						15: "dryad.dev-mysite.pantheonsite.io",
						16: "dryder.dev-mysite.pantheonsite.io",
						17: "elemental.dev-mysite.pantheonsite.io",
						18: "ettin.dev-mysite.pantheonsite.io",
						19: "faerie.dev-mysite.pantheonsite.io",
						20: "fenrir.dev-mysite.pantheonsite.io",
						21: "gargantuan.dev-mysite.pantheonsite.io",
						22: "gargoyle.dev-mysite.pantheonsite.io",
						23: "ghoul.dev-mysite.pantheonsite.io",
						24: "giant.dev-mysite.pantheonsite.io",
						25: "golem.dev-mysite.pantheonsite.io",
						26: "gorgon.dev-mysite.pantheonsite.io",
						27: "gremlin.dev-mysite.pantheonsite.io",
						28: "griffin.dev-mysite.pantheonsite.io",
						29: "harpy.dev-mysite.pantheonsite.io",
						30: "hippogriff.dev-mysite.pantheonsite.io",
						31: "hydra.dev-mysite.pantheonsite.io",
						32: "jabberwocky.dev-mysite.pantheonsite.io",
						33: "jotunn.dev-mysite.pantheonsite.io",
						34: "kappa.dev-mysite.pantheonsite.io",
						35: "kelpie.dev-mysite.pantheonsite.io",
						36: "kirin.dev-mysite.pantheonsite.io",
						37: "kitsune.dev-mysite.pantheonsite.io",
						38: "kobold.dev-mysite.pantheonsite.io",
						39: "kraken.dev-mysite.pantheonsite.io",
						40: "lamia.dev-mysite.pantheonsite.io",
						41: "leprechaun.dev-mysite.pantheonsite.io",
						42: "leviathan.dev-mysite.pantheonsite.io",
						43: "lich.dev-mysite.pantheonsite.io",
						44: "manticore.dev-mysite.pantheonsite.io",
						45: "mermaid.dev-mysite.pantheonsite.io",
						46: "mimic.dev-mysite.pantheonsite.io",
						47: "minotaur.dev-mysite.pantheonsite.io",
						48: "myconid.dev-mysite.pantheonsite.io",
						49: "naiad.dev-mysite.pantheonsite.io",
						50: "naga.dev-mysite.pantheonsite.io",
						51: "nymph.dev-mysite.pantheonsite.io",
						52: "ogre.dev-mysite.pantheonsite.io",
						53: "orc.dev-mysite.pantheonsite.io",
						54: "pegasus.dev-mysite.pantheonsite.io",
						55: "phoenix.dev-mysite.pantheonsite.io",
						56: "pixie.dev-mysite.pantheonsite.io",
						57: "quetzalcoatl.dev-mysite.pantheonsite.io",
						58: "revenant.dev-mysite.pantheonsite.io",
						59: "roc.dev-mysite.pantheonsite.io",
						60: "satyr.dev-mysite.pantheonsite.io",
						61: "selkie.dev-mysite.pantheonsite.io",
						62: "siren.dev-mysite.pantheonsite.io",
						63: "sphinx.dev-mysite.pantheonsite.io",
						64: "sprite.dev-mysite.pantheonsite.io",
						65: "spriggan.dev-mysite.pantheonsite.io",
						66: "tengu.dev-mysite.pantheonsite.io",
						67: "titans.dev-mysite.pantheonsite.io",
						68: "treant.dev-mysite.pantheonsite.io",
						69: "troll.dev-mysite.pantheonsite.io",
						70: "unicorn.dev-mysite.pantheonsite.io",
						71: "valkyrie.dev-mysite.pantheonsite.io",
						72: "vampire.dev-mysite.pantheonsite.io",
						73: "wendigo.dev-mysite.pantheonsite.io",
						74: "werewolf.dev-mysite.pantheonsite.io",
						75: "wraith.dev-mysite.pantheonsite.io",
						76: "wyvern.dev-mysite.pantheonsite.io",
						77: "yeti.dev-mysite.pantheonsite.io",
						78: "yokai.dev-mysite.pantheonsite.io",
						79: "zombie.dev-mysite.pantheonsite.io",
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
