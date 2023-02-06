package cmd

import (
	"fmt"
	"pyml-validator/pkg/validator"

	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(sitesCommand)
}

var sitesCommand = &cobra.Command{
	Use:   "sites",
	Short: "validate sites.yml",
	Long:  `Validate sites.yml`,
	RunE: func(cmd *cobra.Command, args []string) error {
		// Is there a better way to do this? Without this we print usage on error exits.
		// If we override at the root level, we don't get usage when we _do_ want it.
		cmd.SilenceUsage = true

		v, err := validator.ValidatorFactory("sites")
		if err != nil {
			return err
		}

		err = v.ValidateFromFilePath(FilePath)

		if err != nil {
			return err
		}

		fmt.Println("✨ sites.yml is valid")
		return nil
	},
}
