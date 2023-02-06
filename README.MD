# Pantheon.yml | Sites.yml Validator

A utility for validating a sites.yml file on a pantheon site during WordPress multisites' search-replace tasks. Asprirationally to include pantheon.yml validation in the future.

# Usage

## Sites.yml
```
$ pyml-validator sites -f path/to/sites.yml
```

See [this annotated fixture](./fixtures/sites.valid.yml) for an example of a valid sites.yml file.

## Pantheon.yml
Note, validation of pantheon.yml is unimplemented, so any file reads as valid.
```
$ pyml-validator pantheon -f path/to/pantheon.yml
```

# Testing

[![Coverage Status](https://coveralls.io/repos/github/pantheon-systems/pyml-validator/badge.svg?t=PGhafd)](https://coveralls.io/github/pantheon-systems/pyml-validator)

`make test` runs linting and testing.

# Releases

Automatically releases on merge to main via autotag + goreleaser. See [Autotag Readme](https://github.com/pantheon-systems/autotag) for details on how the SemVer is determined. Note, with goreleaser, each commit merged will become a line item in the release's Changelog. Take note to use squashing and/or rebase to ensure helpful and informative commit messages.