package cmd

import (
	"fmt"
	"sites-yml-validator/pkg/validator"

	"github.com/spf13/cobra"
)

func validatorCommand(cmd *cobra.Command, validatorType, filePath string) error {
	// Is there a better way to do this? Without this we print usage on error exits.
	// If we override at the root level, we don't get usage when we _do_ want it.
	cmd.SilenceUsage = true

	v, err := validator.ValidatorFactory(validatorType)
	if err != nil {
		return err
	}

	err = v.ValidateFromFilePath(filePath)
	if err != nil {
		return err
	}
	fmt.Printf("✨ %s is valid\n", filePath)
	return nil
}

var sitesCommand = &cobra.Command{
	Use:   "sites path/to/file.yml",
	Short: "validate sites.yml",
	Long:  `Validate sites.yml`,
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		return validatorCommand(cmd, "sites", args[0])
	},
}

func init() {
	rootCmd.AddCommand(sitesCommand)
}
