package cmd

import (
	"log"

	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(pantheonCommand)
}

var pantheonCommand = &cobra.Command{
	Use:   "pantheon",
	Short: "validate pantheon.yml",
	Long:  `Validate pantheon.yml`,
	Run: func(cmd *cobra.Command, args []string) {
		log.Fatal("Not yet implemented.")
	},
}
