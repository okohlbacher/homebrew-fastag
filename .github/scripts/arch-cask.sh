#!/bin/bash
# Turn an Apple-silicon-only cask into one that serves both architectures:
#
#   arch-cask.sh Casks/<cask>.rb
#
# FASTag ships macos-arm64 AND macos-x64 disk images again from the first
# release after 1.14.0 that carries FASTag-<version>-[gui-]macos-x64.dmg
# (Intel was dropped in 1.8.0). update-casks.yml runs this once, at that
# release, before `brew bump-cask-pr` downloads the images:
#
#   sha256 "<arm digest>"                       arch arm: "arm64", intel: "x64"
#   url ".../FASTag-#{version}-<v>-arm64.dmg"   sha256 arm: "<arm digest>", intel: "000...0"
#   depends_on arch: :arm64                     url ".../FASTag-#{version}-<v>-#{arch}.dmg"
#                                               (no depends_on arch)
#
# The intel digest is a placeholder the bump overwrites (it computes one
# digest per architecture). Idempotent: a cask that already has an `arch`
# stanza is left as it is.
set -euo pipefail
f=${1:?cask file}
if grep -q '^  arch arm:' "$f"; then
  echo "$f: already serves both architectures"
  exit 0
fi
grep -q 'macos-arm64\.dmg"$' "$f" || { echo "::error::$f: no url ending in macos-arm64.dmg" >&2; exit 1; }
grep -q '^  sha256 "[0-9a-f]\{64\}"$' "$f" || { echo "::error::$f: no single sha256 stanza" >&2; exit 1; }
perl -0pi -e '
  s/^(  version "[^"]*"\n)/  arch arm: "arm64", intel: "x64"\n\n$1/m;
  s/^  sha256 "([0-9a-f]{64})"\n/  sha256 arm:   "$1",\n         intel: "0000000000000000000000000000000000000000000000000000000000000000"\n/m;
  s/macos-arm64\.dmg"$/macos-#{arch}.dmg"/m;
  s/^  # Apple silicon only from 1\.8\.0 on\. /  # Apple silicon and Intel (Intel again after 1.14.0). /m;
  s/^  depends_on arch: :arm64\n//m;
' "$f"
grep -q '^  arch arm: "arm64", intel: "x64"$' "$f" && grep -q 'macos-#{arch}\.dmg"$' "$f" \
  && ! grep -q 'depends_on arch:' "$f" \
  || { echo "::error::$f: rewrite incomplete" >&2; exit 1; }
echo "$f: now serves arm64 and x64"
