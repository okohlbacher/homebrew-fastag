# homebrew-fastag

Homebrew tap for [FASTag](https://github.com/okohlbacher/FASTag), a
sequence-tag search and species identification tool for tandem mass
spectra. macOS only (Homebrew casks); Apple silicon and Intel.

## Install

```sh
brew install --cask okohlbacher/fastag/fastag        # desktop app  -> /Applications/FASTag.app
brew install --cask okohlbacher/fastag/fastag-cli    # command line -> FASTag on your PATH
```

The fully qualified name taps this repository and, since Homebrew 6, trusts
just that cask. To use the short names instead, trust the tap as a whole:

```sh
brew tap okohlbacher/fastag && brew trust okohlbacher/fastag
brew install --cask fastag fastag-cli
```

| cask | installs | from |
|---|---|---|
| `fastag` | `FASTag.app` (Developer ID signed, notarized, stapled) | `FASTag-gui-macos-{arm64,x64}.dmg` |
| `fastag-cli` | the `FASTag` command; the whole `FASTag/` folder stays in the Caskroom and a wrapper in `$(brew --prefix)/bin` runs it in place | `FASTag-macos-{arm64,x64}.dmg` |

Both casks download the exact disk images published on each
[FASTag release](https://github.com/okohlbacher/FASTag/releases) and verify
them against a pinned SHA-256. The app bundles its own copy of the command
line tool, so install `fastag-cli` only if you want `FASTag` in a shell.
Each cask is about 500 MB to download and about 1.4 GB on disk (most of it
the taxonomy index).

Minimum macOS: 14 (Sonoma) on Apple silicon, 15 (Sequoia) on Intel -- the
floor of the shipped binaries, which is higher than the 11.0 the app bundle
declares.

```sh
brew upgrade --cask fastag fastag-cli     # newer release
brew uninstall --cask fastag              # add --zap to remove the app's settings too
brew uninstall --cask fastag-cli
```

## How the casks stay current

`.github/workflows/update-casks.yml` publishes a FASTag release to this tap.
It runs on a 6-hour schedule with no secrets at all (the latest release is
read from GitHub's public API) and can be started by hand or by FASTag's own
CI with a specific tag:

```sh
gh workflow run update-casks.yml -R okohlbacher/homebrew-fastag -f tag=v1.4.3
```

Each run refuses drafts, pre-releases and partial releases (all four macOS
images must be attached), refuses to move a cask backwards, rewrites both
casks with `brew bump-cask-pr --write-only` (or, when a cask is already at
that version, verifies both of its images against the recorded digests),
runs `brew audit --cask --strict --online` and `brew style`, checks the
declared minimum macOS of both architectures against the Mach-Os inside the
images (`.github/scripts/check-macos-floor.sh`), installs both casks on the
runner (`FASTag --help` has to report the new version, the species smoke
test has to produce a report, `spctl` has to accept the app), re-checks that
the release's assets did not change meanwhile, and only then commits. A run
that finds nothing to change commits nothing.

`.github/workflows/tests.yml` runs the same checks on every push and pull
request, for hand-made edits.

Two limits worth knowing:

* A release whose assets are replaced under the same tag (a re-run of the
  tag build) is not re-published: `brew upgrade` compares versions, not
  digests, so users who already installed that version would keep the old
  bytes anyway. The update run goes red with a clear message until a new
  release exists.
* GitHub disables a scheduled workflow after 60 days without a commit to the
  repository. FASTag's CI re-enables it before each dispatch when the token
  below is configured; without the token, re-enable it by hand under
  *Actions > update casks > Enable workflow*.

### Optional: instant updates from FASTag's CI

FASTag's `build` workflow has a final `homebrew-tap` job that triggers the
update workflow here as soon as a release is complete. It needs a
repository secret on **okohlbacher/FASTag** named `HOMEBREW_TAP_TOKEN`:

* a fine-grained personal access token, resource owner `okohlbacher`;
* repository access: **only** `okohlbacher/homebrew-fastag`;
* repository permissions: **Actions: Read and write** (Metadata: Read is
  implied). Nothing else.

What that token can do if it leaks: run, enable or disable any workflow in
this one (public) repository. It cannot push commits, and it has no access
to FASTag. Give it the shortest expiry you can live with (a year at most).
Without the secret the job prints a notice and the schedule publishes the
release within six hours. When the token expires the job emits a warning
(the tag build itself stays green) and the schedule keeps working.

### Bumping by hand

```sh
brew bump-cask-pr --write-only --version 1.4.3 okohlbacher/fastag/fastag
brew bump-cask-pr --write-only --version 1.4.3 okohlbacher/fastag/fastag-cli
brew audit --cask --strict --online --except=min_os okohlbacher/fastag/fastag okohlbacher/fastag/fastag-cli
brew style okohlbacher/fastag
brew fetch --cask --arch all okohlbacher/fastag/fastag okohlbacher/fastag/fastag-cli
.github/scripts/check-macos-floor.sh okohlbacher/fastag fastag fastag-cli
```

(`--except=min_os`: the online audit compares the cask's minimum macOS with
the app bundle's 11.0; the casks deliberately declare the binaries' higher
floor, and the floor script is the stricter check.)

## License

MIT, the same as FASTag.
