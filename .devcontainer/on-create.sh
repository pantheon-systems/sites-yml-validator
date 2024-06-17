#!/bin/bash
set -euo pipefail

# If GITHUB_TOKEN isn't set, try to extract from ~/.netrc
if [[ -z "${GITHUB_TOKEN:-}" && -r "${HOME}/.netrc" ]]; then
  GITHUB_TOKEN=$(awk '/machine github.com / {print $6}' "${HOME}/.netrc")
  export GITHUB_TOKEN
fi

# If GITHUB_TOKEN is still not set, continue anyway and let install-pants.sh complain.

CIRCLECI=true sudo -E sh/install-pants.sh || echo "Installing pants failed; continuing anyway"

echo
echo "NEXT: You may want to run 'pants gke pull-creds pantheon-sandbox' to configure Kubernetes credentials."
echo
