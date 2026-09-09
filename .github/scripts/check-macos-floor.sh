#!/bin/bash
# Check that each cask's declared minimum macOS is at least what its payload
# needs, for BOTH architectures, from the disk images in Homebrew's cache.
#
#   check-macos-floor.sh <tap> <cask> [<cask> ...]
#
# FASTag's Mach-Os are built without a deployment target, so their floor is
# whatever SDK the CI runner had (LC_BUILD_VERSION minos: 14.0 on arm64, 15.0
# on x64 for v1.4.2), and it can move whenever GitHub retires a runner image.
# The app's Info.plist still says 11.0 -- so the online `brew audit` min_os
# check is skipped for the app and THIS check is what keeps the casks honest:
# it mounts every image, reads the highest minos over every Mach-O inside,
# and fails when a cask admits a macOS the payload will not load on.
set -euo pipefail

tap=${1:?tap}; shift
[ $# -gt 0 ] || { echo "usage: $0 <tap> <cask>..." >&2; exit 2; }

# One line per (cask, arch): "<cask> <arch> <declared floor or none> <cached dmg path>"
# from Homebrew itself, so the URL, the cache location and the depends_on
# stanza are read exactly the way `brew install` will read them.
cask_lines=$(brew ruby -e '
  require "cask/cask_loader"
  require "cask/download"
  tap = ARGV.shift
  ARGV.each do |token|
    [:arm, :intel].each do |arch|
      Homebrew::SimulateSystem.with(os: :macos, arch: arch) do
        cask = Cask::CaskLoader.load("#{tap}/#{token}")
        floor = cask.depends_on.macos&.minimum_version&.to_s || "none"
        path = Cask::Download.new(cask).downloader.cached_location
        puts [token, arch, floor, path].join(" ")
      end
    end
  end' "$tap" "$@")

# Highest minos over every Mach-O under a directory. LC_BUILD_VERSION carries
# `minos`, the older LC_VERSION_MIN_MACOSX carries `version`; a fat file
# prints one block per slice and the max covers that too.
payload_floor() {
  local dir=$1 max=0 v
  while IFS= read -r -d '' f; do
    file -b "$f" | grep -q "Mach-O" || continue
    while read -r v; do
      [ "$(printf '%s\n%s\n' "$max" "$v" | sort -V | tail -1)" = "$v" ] && max=$v
    done < <(otool -l "$f" 2>/dev/null | awk '
      /LC_BUILD_VERSION/ {b=1} b && /minos/ {print $2; b=0}
      /LC_VERSION_MIN_MACOSX/ {m=1} m && /version/ {print $2; m=0}')
  done < <(find "$dir" -type f \( -perm -u+x -o -name '*.dylib' -o -name '*.so' \) -print0)
  echo "$max"
}

# "14" and "14.0" are the same floor; give both a minor so sort -V agrees.
norm() { case $1 in *.*) echo "$1" ;; *) echo "$1.0" ;; esac; }

rc=0
while read -r token arch floor dmg; do
  [ -f "$dmg" ] || { echo "::error::$token ($arch): image not in the Homebrew cache: $dmg"; rc=1; continue; }
  mnt=$(hdiutil attach -readonly -nobrowse -noautoopen "$dmg" | grep -o '/Volumes/.*' | head -1)
  need=$(norm "$(payload_floor "$mnt")")
  hdiutil detach "$mnt" -quiet
  [ "$floor" = none ] || floor=$(norm "$floor")
  if [ "$floor" = none ]; then
    echo "::error::$token ($arch): payload needs macOS $need but the cask declares no minimum"
    rc=1
  elif [ "$(printf '%s\n%s\n' "$floor" "$need" | sort -V | tail -1)" != "$floor" ]; then
    echo "::error::$token ($arch): payload needs macOS $need but the cask admits $floor"
    rc=1
  else
    echo "$token ($arch): payload needs macOS $need, cask declares $floor -- ok"
  fi
done <<<"$cask_lines"
exit $rc
