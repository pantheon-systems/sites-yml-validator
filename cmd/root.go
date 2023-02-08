package cmd

import (
	"log"

	"github.com/spf13/cobra"
)

var FilePath string

var rootCmd = &cobra.Command{
	Use:   "pyml-validator",
	Short: "Pyml-validator validates pantheon.yml, sites.yml, etc.",
	Long: `Pyml-validator is a validator for pantheon.yml or sites.yml.
Ensures that the given config file can be used by the platform.`,
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		log.Fatal(err)
	}
}

func init() {
	rootCmd.PersistentFlags().StringVarP(&FilePath, "file", "f", "", "path/to/file.yml")
	err := rootCmd.MarkPersistentFlagRequired("file")
	if err != nil {
		log.Fatal(err)
	}
}
