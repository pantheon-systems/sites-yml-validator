# Pantheon YML Validator

A utility for validating a sites.yml file on a Pantheon site during WordPress multisites' search-replace tasks. Asprirationally to include pantheon.yml validation in the future.

## Usage

### Sites.yml
```
$ pyml-validator sites -f path/to/sites.yml
```

See [this annotated fixture](./fixtures/sites/valid.yml) for an example of a valid sites.yml file.

## Install

### [Download the latest binary](https://github.com/pantheon-systems/pyml-validator/releases/latest)

Use wget to download, gzipped pre-compiled binaries:
For instance, VERSION=v0.0.11 and BINARY=pyml-validator_linux_amd64

### Compressed via tar.gz
```bash
wget https://github.com/pantheon-systems/pyml-validator/releases/download/${VERSION}/${BINARY}.tar.gz -O - |\
  tar xz && mv ${BINARY} /usr/bin/pyml-validator
```

### Plain binary

```bash
wget https://github.com/pantheon-systems/pyml-validator/releases/download/${VERSION}/${BINARY} -O /usr/bin/pyml-validator &&\
    chmod +x /usr/bin/pyml-validator
```

### Latest version

```bash
wget https://github.com/pantheon-systems/pyml-validator/releases/latest/download/pyml-validator_linux_amd64 -O /usr/bin/pyml-validator &&\
    chmod +x /usr/bin/pyml-validator
```

## Testing

[![Coverage Status](https://coveralls.io/repos/github/pantheon-systems/pyml-validator/badge.svg?t=PGhafd)](https://coveralls.io/github/pantheon-systems/pyml-validator)

`make test` runs linting and testing.

## Releases

Automatically releases on merge to main via autotag + goreleaser. See [Autotag Readme](https://github.com/pantheon-systems/autotag) for details on how the SemVer is determined. With goreleaser, each commit merged will become a line item in the release's Changelog. Take note to use squashing and/or rebase to ensure helpful and informative commit messages.
