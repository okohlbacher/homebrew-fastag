cask "fastag-cli" do
  arch arm: "arm64", intel: "x64"

  version "1.15.0"
  sha256 arm:   "ad9d94295a5772876c4f52651dceea0430ce6de9605bd5ecf5f9864b2930f2bf",
         intel: "a73bc2fcdb7b3b5fe9253c8e072f0ff960cb3ac742fa1bd257887ca3165930cb"

  url "https://github.com/okohlbacher/FASTag/releases/download/v#{version}/FASTag-#{version}-macos-#{arch}.dmg"
  name "FASTag command-line tool"
  desc "Command-line sequence-tag search and species identification for tandem MS"
  homepage "https://okohlbacher.github.io/FASTag/"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Apple silicon and Intel (Intel again after 1.14.0). FASTag.bin targets macOS 13.4, which
  # Homebrew cannot express (:ventura is 13.0), so the cask declares 14.
  depends_on macos: :sonoma

  # The image holds one folder, FASTag/: a /bin/sh wrapper (FASTag), the
  # Mach-O it execs (FASTag.bin), the dylib closure (lib/) and the data the
  # wrapper points OPENMS_DATA_PATH at (share-OpenMS/, share-FASTag-taxonomy/).
  # The wrapper resolves all of that relative to its own $0, so it has to be
  # invoked by its absolute staged path: a plain `binary` symlink in bin/
  # would make $0 = $(brew --prefix)/bin/FASTag and break every lookup.
  command_wrapper "FASTag", executable: "#{staged_path}/FASTag/FASTag"
end
