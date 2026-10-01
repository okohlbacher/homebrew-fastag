cask "fastag-cli" do
  arch arm: "arm64", intel: "x64"

  version "1.6.0"
  sha256 arm:   "c7da6bf9fd8d57a36931a44df77ca5a4c470cf0439e41eedb866ba147d23e3dc",
         intel: "796874fce79cc2b82a5bd7f8e51607f12956b145d23e1cdfb1bf3bc37a4e4eb9"

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
