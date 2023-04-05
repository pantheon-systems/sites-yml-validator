# Pantheon YML Validator

[![Early Access](https://img.shields.io/badge/Pantheon-Early_Access-yellow?logo=pantheon&color=FFDC28)](https://docs.pantheon.io/oss-support-levels#early-access)

A utility for validating a `sites.yml` file on a Pantheon site during a WordPress multisite's search and replace tasks. For more information, see [Pantheon's Multisite Docs](https://docs.pantheon.io/guides/multisite/search-replace/).

## Usage

### sites.yml
To validate the `sites.yml` file, run:
```
$ sites-yml-validator sites path/to/sites.yml
```

#### Valid File Example
See [this annotated fixture](./fixtures/sites/valid.yml) for an example of a valid `sites.yml` file.

The basic format for the file is:
``` yml
api_version: 1
domain_maps:
  {env_name}:
    {blog_id}: {site_url}
```
A `sites.yml` file is valid if:
- the `api_version` is `1`
- the key for each item in `domain_maps` is a valid Pantheon environment name (`dev`, `test`, `multidev`, etc.)
- For each subsite listed for an environment:
   - the key is an integer
   - the value is a valid Pantheon hostname
- there are no more than 25 subsites listed for any environment

## Install

### [Download the latest binary](https://github.com/pantheon-systems/sites-yml-validator/releases/latest)

Use wget to download, gzipped pre-compiled binaries:
For instance, VERSION=v0.0.11 and BINARY=sites-yml-validator_linux_amd64

### Compressed via tar.gz
```bash
wget https://github.com/pantheon-systems/sites-yml-validator/releases/download/${VERSION}/${BINARY}.tar.gz -O - |\
  tar xz && mv ${BINARY} /usr/bin/sites-yml-validator
```

### Plain binary

```bash
wget https://github.com/pantheon-systems/sites-yml-validator/releases/download/${VERSION}/${BINARY} -O /usr/bin/sites-yml-validator &&\
    chmod +x /usr/bin/sites-yml-validator
```

### Latest version

```bash
wget https://github.com/pantheon-systems/sites-yml-validator/releases/latest/download/sites-yml-validator_linux_amd64 -O /usr/bin/sites-yml-validator &&\
    chmod +x /usr/bin/sites-yml-validator
```

## Testing

[![Coverage Status](https://coveralls.io/repos/github/pantheon-systems/sites-yml-validator/badge.svg?t=PGhafd)](https://coveralls.io/github/pantheon-systems/sites-yml-validator)

`make test` runs linting and testing.

## Releases

Automatically releases on merge to main via autotag + goreleaser. See [Autotag Readme](https://github.com/pantheon-systems/autotag) for details on how the SemVer is determined. With goreleaser, each commit merged will become a line item in the release's Changelog. Take note to use squashing and/or rebase to ensure helpful and informative commit messages.
