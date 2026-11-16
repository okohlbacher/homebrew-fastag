#!/bin/bash
# Download a cask's image(s) and verify them against its sha256 stanza(s):
# arm64 always, and Intel too when the cask serves Intel (an `arch` stanza;
# see arch-cask.sh). `brew fetch --arch` simulates the architecture, so an
# arm64 runner verifies the x64 image's digest as well.
#
#   fetch-all-arches.sh <tap>/<cask> [...]
set -euo pipefail
for full in "$@"; do
  file="Casks/${full##*/}.rb"
  arches=(arm)
  grep -q '^  arch arm:' "$file" && arches+=(intel)
  for a in "${arches[@]}"; do
    brew fetch --cask --arch "$a" "$full"
  done
done
