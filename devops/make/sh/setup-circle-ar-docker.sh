#!/bin/bash
#
# The following ENV vars must be set before calling this script:
#
#   VAULT_PATH_METHOD:   one of  `shared`, `uuid`, `reponame` defaults to `shared`
#         `shared`   uses the shared GSA stored in vault for authenticating CircleCI jobs
#         `uuid`     uses the CircleCI project UUID in a path to `secrets/circleci/<uuid>/gsa to fetch the GSA
#         `reponame` uses the reponame in a path to `secrets/circleci/<reponame>/gsa to fetch the GSA
#
# optional:
#   VAULT_INSTANCE       using specific vault instance.  'produciton' by default
#
# setup vault for useage with circle OIDC /  jwt identity
# the CIRCLE_OIDC_TOKEN _must_ be present for this to operate.
# We use this token to auth with vault and set the VAULT_TOKEN for jobs
# for more info on how this works see https://github.com/pantheon-systems/vault-kube/blob/master/docs/circleci.md
#
# set VAULT_INSTANCE to 'sandbox' if you want to use sandbox vault otherwise after running this script the VAULT_TOKEN should be setup to talk to production instance of vault.
set -euo pipefail

# auth docker for talking to AR
setup_ar_docker_repos() {
  local VAULT_PATH=$1
  # output the token to make debugging easier
  pvault production token lookup | grep -v id >&2

  # pull the gsa
  gsa=$(pvault "$VAULT_INSTANCE" read -field=json_file "$VAULT_PATH")

  # setup all registries to use this identity
  registries=(us-docker.pkg.dev gcr.io us.gcr.io eu.gcr.io asia.gcr.io staging-k8s.gcr.io marketplace.gcr.io)
  for i in "${registries[@]}" ; do
    echo "$gsa" | docker login -u _json_key --password-stdin "https://$i"
  done
}

main() {
  bindir="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

  if [ "$CIRCLECI" != "true" ]; then
    echo "This script is only intended to run on Circle-CI."
    exit 1
  fi

  if ! command -v jq >/dev/null; then
    echo "JQ is required to install pvault."
    exit 1
  fi

  if ! command -v pvault > /dev/null ; then
    echo "pvault not found on path. Going to try to install it"
    "$bindir/setup-circle-vault.sh"
  fi

  if ! command -v gcloud >/dev/null; then
    echo "gcloud missing, running install-gcloud.sh"
    "$bindir/install-gcloud.sh"
  fi

  if [[ -z ${VAULT_PATH_METHOD:-} ]] ; then
    VAULT_PATH_METHOD='shared'
  fi

  if [[ -z ${VAULT_TOKEN:-} ]] ; then
    echo "Vault token not found, trying to source enviornment."
    # shellcheck disable=SC1090
    . "$BASH_ENV"
    if [[ -z ${VAULT_TOKEN:-} ]] ; then
      echo "Vault token not set in the environment. Maybe you need to run 'setup-circle-vault.sh' first ?"
      exit 1
    fi
  fi

  VAULT_INSTANCE=${VAULT_INSTANCE:-production}

  # VAULT_PATH_METHOD - selector to understand how to fetch the GSA from vault
  case "$VAULT_PATH_METHOD" in
    "reponame") VAULT_PATH="secret/circleci/$CIRCLE_PROJECT_REPONAME/gsa" ;;
    "uuid")
      # CIRCLE doesn't provide the project ID as a built-in environment variable so we extracti it with these shenanigans from the JWT they _do_ provide that does have the info we need.
      #  the jwt is broken up by a  `.` into decodable bits so we extract that
      # then the data that should be base64 is not  (cause its missing a `=` at the end
      # then we jq again to get the actual project id out. YAY!
      VAULT_PATH=$(echo "$CIRCLE_OIDC_TOKEN"|  jq -rR 'split(".") | .[1]+"="' | base64 -d -i | jq -r '.["oidc.circleci.com/project-id"]')
      ;;
    "shared") VAULT_PATH="secret/circleci/gsa" ;;
  esac

  setup_ar_docker_repos $VAULT_PATH
}

main "$@"
