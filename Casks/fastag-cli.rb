cask "fastag-cli" do
  version "1.13.1"
  sha256 "aa22427ac03bc541812074683f471bfd615f91d0a4a7740216602dca5b2a9b92"

  url "https://github.com/okohlbacher/FASTag/releases/download/v#{version}/FASTag-macos-arm64.dmg"
  name "FASTag command-line tool"
  desc "Command-line sequence-tag search and species identification for tandem MS"
  homepage "https://okohlbacher.github.io/FASTag/"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Apple silicon only from 1.8.0 on. FASTag.bin targets macOS 13.4, which
  # Homebrew cannot express (:ventura is 13.0), so the cask declares 14.
  depends_on arch: :arm64
  depends_on macos: :sonoma

  # The image holds one folder, FASTag/: a /bin/sh wrapper (FASTag), the
  # Mach-O it execs (FASTag.bin), the dylib closure (lib/) and the data the
  # wrapper points OPENMS_DATA_PATH at (share-OpenMS/, share-FASTag-taxonomy/).
  # The wrapper resolves all of that relative to its own $0, so it has to be
  # invoked by its absolute staged path: a plain `binary` symlink in bin/
  # would make $0 = $(brew --prefix)/bin/FASTag and break every lookup.
  command_wrapper "FASTag", executable: "#{staged_path}/FASTag/FASTag"
end
