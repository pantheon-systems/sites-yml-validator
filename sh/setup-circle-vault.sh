#!/bin/bash
#  This script sets up the circle job to be able to auth to vault.
# It will install vault, and pvault if they do not exist in the build environment.
#
# Authentication to vault is done via the OIDC_TOKEN from the circle job. The script
# by default will setup the VAULT_TOKEN environment variable with the token issued
# after authentication. For more info see https://github.com/pantheon-systems/vault-kube/blob/master/docs/circleci.md
#
# The following ENV vars must be set before calling this script:
#
#   GITHUB_TOKEN  required for installation of pvault from github releases if pvault is not already in your image.
#                 by default the deploy-toolbox already has this installed and you shoudln't need to specify it unless
#                 you are trying to invoke this from a ci image that is not deploy-toolbox
#
# optional:
#   VAULT_INSTANCE       using specific vault instance.  'produciton' by default
#
set -euo pipefail
shopt -s inherit_errexit

SUDO=""
if [[ "$(id -u || true)" -ne 0 ]] && command -v sudo > /dev/null ; then
  SUDO="sudo"
fi

extract_latest_vault_release() {
    local raw_html=$1
    echo "${raw_html}" | awk -F_ '$0 ~ /vault_[0-9]+\.[0-9]+\.[0-9]+</ {gsub(/<\/a>/, ""); print $2}' | head -n 1
}

get_latest_vault_release() {
    raw_html=$(curl -Ls --fail --retry 3 https://releases.hashicorp.com/vault/)
    extract_latest_vault_release "${raw_html}"
}

verify_vault() {
    local VERSION=$1
    local ARCH=$2
    local PLATFORM=$3

    curl -s "https://keybase.io/_/api/1.0/key/fetch.json?pgp_key_ids=34365D9472D7468F" | jq -r '.keys | .[0] | .bundle' > hashicorp.asc
    gpg --import hashicorp.asc
    curl -Os "https://releases.hashicorp.com/vault/${VERSION}/vault_${VERSION}_SHA256SUMS"
    curl -Os "https://releases.hashicorp.com/vault/${VERSION}/vault_${VERSION}_SHA256SUMS.sig"
    gpg --verify "vault_${VERSION}_SHA256SUMS.sig" "vault_${VERSION}_SHA256SUMS"
    grep "${PLATFORM}_${ARCH}.zip" "vault_${VERSION}_SHA256SUMS" | shasum -a 256 -
    echo "Verified Vault binary"
    rm "vault_${VERSION}_SHA256SUMS.sig" "vault_${VERSION}_SHA256SUMS" hashicorp.asc
}

# shellcheck disable=SC2120
#   optional arguments
install_vault() {
    local VERSION=${1:-}
    local PLATFORM=${2:-linux}
    local ARCH=${3:-amd64}
    local VERIFY=${4:-0}
    if command -v vault > /dev/null; then
      echo "Vault is already installed"
      return
    fi

    if [[ -z "${VERSION}" ]]; then
      VERSION=$(get_latest_vault_release)
    fi

    FILENAME="vault_${VERSION}_${PLATFORM}_${ARCH}.zip"
    DOWNLOAD_URL="https://releases.hashicorp.com/vault/${VERSION}/${FILENAME}"

    curl -L --fail --retry 3 -o "${FILENAME}" "${DOWNLOAD_URL}"
    if [[ "${VERIFY}" -eq 1 ]]; then
      verify_vault "${VERSION}" "${ARCH}" "${PLATFORM}"
    fi

    unzip "${FILENAME}"
    rm "${FILENAME}"
    ${SUDO} mv ./vault /usr/local/bin/vault
    vault version
}

# shellcheck disable=SC2120
#   optional arguments
install_pvault() {
  local PVAULT_VERSION=${1:-latest}

  if command -v pvault >/dev/null; then
    # pvault is here, no worries
    echo "Pvault installed"
    return
  fi

  if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    echo "GITHUB_TOKEN is required to install pvault"
    exit 1
  fi

  local PVAULT_URL="https://${GITHUB_TOKEN}:@api.github.com/repos/pantheon-systems/pvault/releases"
  local JQ_FILTER=".[0].assets | map(select(.name|test(\"pvault.*_linux_amd64\")))[0].id"
  if [[ "${PVAULT_VERSION}" != "latest" ]] ; then
    JQ_FILTER=". | map(select(.tag_name == \"v${PVAULT_VERSION}\"))[0].assets | map(select(.name|test(\"pvault_.*_linux_amd64\")))[0].id"
  fi

  local ASSET
  ASSET=$(curl -s "${PVAULT_URL}" | jq -r "${JQ_FILTER}")
  if [[ "${ASSET}" == "null" ]]; then
    echo "Asset Not Found"
    exit 1
  fi

  echo "Fetching pvault version ${PVAULT_VERSION}, with asset ID ${ASSET}"
  local fn="./pvault_${PVAULT_VERSION}_linux_amd64.deb"
  # cleanup the downloaded deb on exit
  # shellcheck disable=SC2064
  trap "rm -f $fn" EXIT

  curl -L -o "$fn" "https://api.github.com/repos/pantheon-systems/pvault/releases/assets/${ASSET}" \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H 'Accept: application/octet-stream' \
  && ${SUDO} dpkg -i "$fn"
}

setup_vault_env() {
  local VAULT_INSTANCE=$1
  VAULT_TOKEN=$(pvault "${VAULT_INSTANCE}" write auth/jwt-circleci/login -format=json role=circleci jwt="${CIRCLE_OIDC_TOKEN}"  | jq -r '.auth.client_token')
  export VAULT_TOKEN
  echo "export VAULT_TOKEN=${VAULT_TOKEN}" >> "${BASH_ENV}"
}

main() {
  if [[ "${CIRCLECI:-}" != "true" ]]; then
    echo "This script is only intended to run on Circle-CI."
    exit 1
  fi

  if ! command -v jq >/dev/null; then
    echo "JQ is required to install pvault."
    exit 1
  fi


  if [[ -z "${CIRCLE_OIDC_TOKEN}" ]]; then
    echo CIRCLE_OIDC_TOKEN not set
    exit 1
  fi

  VAULT_INSTANCE=${VAULT_INSTANCE:-production}

  install_vault
  install_pvault
  setup_vault_env "$VAULT_INSTANCE"
}

main "$@"
