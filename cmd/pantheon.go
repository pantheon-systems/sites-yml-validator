package cmd

import (
	"fmt"
	"pyml-validator/pkg/validator"

	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(pantheonCommand)
}

var pantheonCommand = &cobra.Command{
	Use:   "pantheon",
	Short: "validate pantheon.yml",
	Long:  `Validate pantheon.yml`,
	RunE: func(cmd *cobra.Command, args []string) error {
		// Is there a better way to do this? Without this we print usage on error exits.
		// If we override at the root level, we don't get usage when we _do_ want it.
		cmd.SilenceUsage = true

		v, err := validator.ValidatorFactory("pantheon")
		if err != nil {
			return err
		}

		err = v.ValidateFromFilePath(FilePath)

		if err != nil {
			return err
		}

		fmt.Println("✨ pantheon.yml is valid")
		return nil
	},
}
