#! /bin/bash
#  upgrade CircleCI builtin gcloud tools, and set it up
#
# The following ENV vars must be set before calling this script:
#
#   GCLOUD_EMAIL           # user-id for circle to authenticate to google cloud
#   GCLOUD_KEY             # base64 encoded key
set -eou pipefail

if [ "$CIRCLECI" != "true" ]; then
  echo "This script is only intended to run on Circle-CI."
  exit 1
fi

export PATH=$PATH:/opt/google-cloud-sdk/bin
export PATH=$PATH:/root/google-cloud-sdk/bin
export CLOUDSDK_CORE_DISABLE_PROMPTS=1
export CLOUDSDK_PYTHON_SITEPACKAGES=0

gcloud=$(command -v gcloud)

# ensure we use certs to talk to kube, instead of the oauth bridge (google auth creds)
export CLOUDSDK_CONTAINER_USE_CLIENT_CERTIFICATE=True

# if gcloud was installed via apt/deb, upgrade via apt:
if dpkg -l google-cloud-sdk; then
  sudo -E apt-get update -qy && sudo apt-get -y --only-upgrade install kubectl google-cloud-sdk
else
# assume gcloud was installed through the install script and run the builtin updater:
  sudo -E "$gcloud" components update > /dev/null 2>&1
  sudo -E "$gcloud" components update kubectl > /dev/null 2>&1
fi

sudo -E chown -R "$(whoami)" ~/.config/gcloud
