#!/bin/sh
# sign.sh  - maintainer only: (re)generates SHA256SUMS for the files given and signs it.
# KEY defaults to ~/.config/simple-linux/release-signing. Usage: sign.sh file...
set -eu
KEY=${KEY:-$HOME/.config/simple-linux/release-signing}
sha256sum "$@" > SHA256SUMS
rm -f SHA256SUMS.sig
ssh-keygen -Y sign -f "$KEY" -n simple-linux-release SHA256SUMS
echo "wrote SHA256SUMS and SHA256SUMS.sig"
