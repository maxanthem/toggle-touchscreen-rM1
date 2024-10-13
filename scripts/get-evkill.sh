#!/usr/bin/env sh
# Download and install the latest evkill release
#
# Adapted from https://github.com/Enteee/evkill/blob/master/install.sh
#  commented out the first line (pipefail)
#
# set -euo pipefail # fails on my WSL

ARCH="armv7l"

REPO="Enteee/evkill"

curl -s "https://api.github.com/repos/${REPO}/releases/latest" \
   | grep "${ARCH}" \
   | grep "browser_download_url" \
   | cut -d '"' -f 4 \
   | xargs -n1 curl -s -L --output bin/evkill

chmod +x bin/evkill