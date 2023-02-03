#! /bin/bash
set -eou pipefail

PANTS_VERSION_CONSTRAINT=${PANTS_VERSION_CONSTRAINT:-"latest"}
GITHUB_TOKEN=${GITHUB_TOKEN:-}

if [ "$CIRCLECI" != "true" ]; then
  echo "This script is only intended to run on Circle-CI."
  exit 1
fi

if ! command -v pants >/dev/null; then
  # pants is not installed so install it
  echo "Pants is not installed in this env, please consider switching to quay.io/getpantheon/deploy-toolbox:latest. Installing pants..."

  if ! command -v jq >/dev/null; then
    echo "JQ is required to install pants. please consider switching to quay.io/getpantheon/deploy-toolbox:latest or install JQ in your image to utilize this script."
    exit 1
  fi

  if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "GITHUB_TOKEN is required when CI environment does not have pants"
    exit 1
  fi

  PANTS_URL="https://$GITHUB_TOKEN:@api.github.com/repos/pantheon-systems/pants/releases"

  JQ_FILTER=".[0].assets | map(select(.name|test(\"pants_.*_linux_amd64\")))[0].id"
  if [[ $PANTS_VERSION_CONSTRAINT != "latest" ]]; then
    JQ_FILTER=". | map(select(.tag_name == \"v$PANTS_VERSION_CONSTRAINT\"))[0].assets | map(select(.name|test(\"pants_.*_linux_amd64\")))[0].id"
  fi

  ASSET=$(curl -s "$PANTS_URL" | jq -r "$JQ_FILTER")
  if [[ "$ASSET" == "null" ]]; then
    echo "Asset Not Found"
    exit 1
  fi

  echo "Fetching pants version $PANTS_VERSION_CONSTRAINT, with asset ID $ASSET"
  curl -L -o "./pants_${PANTS_VERSION_CONSTRAINT}_linux_amd64" "https://api.github.com/repos/pantheon-systems/pants/releases/assets/$ASSET" \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H 'Accept: application/octet-stream' \
  && mv pants_*_linux_amd64 /bin/pants \
  && chmod 755 /bin/pants
fi
