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
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Validate sites.yml")
		if FilePath != "" {
			fmt.Printf(fmt.Sprintf("At Path %q\n", FilePath))
		}

		yFile, err := os.ReadFile(FilePath)
		if err != nil {
			fmt.Printf("Error reading YAML file: %s\n", err)
			return
		}

		err = sites.ValidateFromYaml(yFile)
		return
	},
}
