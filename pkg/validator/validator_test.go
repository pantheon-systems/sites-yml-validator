package validator

import (
	"errors"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestValidatorFactory(t *testing.T) {
	for _, tc := range []struct {
		name        string
		expected    Validator
		expectedErr error
	}{
		{"sites", &SitesValidator{}, nil},
		{"foo", nil, errors.New(`"foo" is not a valid validator.`)},
	} {
		t.Run(tc.name, func(t *testing.T) {
			result, err := ValidatorFactory(tc.name)
			if tc.expectedErr != nil {
				assert.EqualError(t, err, tc.expectedErr.Error())
				return
			}
			assert.NoError(t, err)
			assert.Equal(t, result, tc.expected)
		})
	}
}
