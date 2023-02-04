package sites

import "errors"

var (
	ErrInvalidAPIVersion = errors.New("Invalid API Version. Must be '1'")
)

// TODO: More dynamic errors could be refactored here, but likely only worth
// pursuing once we are passing errors back to customers
