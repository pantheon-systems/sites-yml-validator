package cmd

import (
	"fmt"
	"os"
	"pyml-validator/pkg/sites"

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
		fmt.Println("Validate sites.yml")
		if FilePath != "" {
			fmt.Println(fmt.Sprintf("At Path %q", FilePath))
		}

		yFile, err := os.ReadFile(FilePath)
		if err != nil {
			fmt.Printf("Error reading YAML file: %s\n", err)
			return err
		}

		err = sites.ValidateFromYaml(yFile)
		return err
	},
}
