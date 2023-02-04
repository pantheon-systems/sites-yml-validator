package cmd

import (
  "fmt"
  "os"

  "github.com/spf13/cobra"
)

var FilePath string

var rootCmd = &cobra.Command{
  Use:   "pymlv",
  Short: "Pymlv is a validator for sites.yml, pantheon.yml, etc.",
  Long:  ``,
  RunE: func(cmd *cobra.Command, args []string) error {
    fmt.Println("Foo")
    return nil
  },
}

func Execute() {
  if err := rootCmd.Execute(); err != nil {
    fmt.Fprintln(os.Stderr, err)
    os.Exit(1)
  }
}

func init() {
  rootCmd.PersistentFlags().StringVarP(&FilePath, "file", "f", "", "path/to/file.yml")
}
