cask "fastag-cli" do
  arch arm: "arm64", intel: "x64"

  version "1.4.2"
  sha256 arm:   "384bdc59868f470ece7e05c0201423e8d19f507a997668beb7d0f0b3d19759ee",
         intel: "7c81405742204a2ed0a4ec962fb34b55a53ddacbab92a60b5671862dcbb949e5"

  # FASTag.bin is built without a deployment target, so its floor is the SDK
  # of the runner that built it (LC_BUILD_VERSION minos): 14.0 on arm64,
  # 15.0 on x64. dyld refuses to load it on anything older.
  on_arm do
    depends_on macos: :sonoma
  end
  on_intel do
    depends_on macos: :sequoia
  end

  url "https://github.com/okohlbacher/FASTag/releases/download/v#{version}/FASTag-macos-#{arch}.dmg"
  name "FASTag command-line tool"
  desc "Command-line sequence-tag search and species identification for tandem MS"
  homepage "https://okohlbacher.github.io/FASTag/"

  livecheck do
    url :url
    strategy :github_latest
  end

  # The image holds one folder, FASTag/: a /bin/sh wrapper (FASTag), the
  # Mach-O it execs (FASTag.bin), the dylib closure (lib/) and the data the
  # wrapper points OPENMS_DATA_PATH at (share-OpenMS/, share-FASTag-taxonomy/).
  # The wrapper resolves all of that relative to its own $0, so it has to be
  # invoked by its absolute staged path: a plain `binary` symlink in bin/
  # would make $0 = $(brew --prefix)/bin/FASTag and break every lookup.
  command_wrapper "FASTag", executable: "#{staged_path}/FASTag/FASTag"
end
