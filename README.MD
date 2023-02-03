# Pantheon.yml | Sites.yml Validator

A utility for validating a sites.yml file on a pantheon site during WordPress multisites' search-replace tasks. Asprirationally to include pantheon.yml validation in the future.

# Testing

`make test` runs linting and testing.

# Releases

Automatically releases on merge to main via autotag + goreleaser. See [Autotag Readme](https://github.com/pantheon-systems/autotag) for details on how the SemVer is determined.