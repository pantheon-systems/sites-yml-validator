package cmd

import (
	"os"

	"github.com/spf13/cobra"
)

var FilePath string

var rootCmd = &cobra.Command{
	Use:   "sites-yml-validator",
	Short: "sites-yml-validator validates sites.yml",
	Long: `sites-yml-validator is a validator for sites.yml, used for WPMS search-replace.
Ensures that the given config file can be used by the platform.`,
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}
