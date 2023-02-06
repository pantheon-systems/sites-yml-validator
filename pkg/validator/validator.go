package validator

type Validator interface {
	ValidateFromYaml(y []byte) error
	ValidateFromFilePath(s string) error
}
