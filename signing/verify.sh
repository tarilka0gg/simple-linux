#!/bin/sh
# verify.sh [dir]  - checks that SHA256SUMS was signed by the Simple Linux release key, then that the files match.
# Run it in the directory holding the downloaded files, SHA256SUMS and SHA256SUMS.sig.
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
cd "${1:-.}"
ssh-keygen -Y verify -f "$HERE/allowed_signers" -I simple-linux-release -n simple-linux-release -s SHA256SUMS.sig < SHA256SUMS
sha256sum -c --ignore-missing SHA256SUMS
