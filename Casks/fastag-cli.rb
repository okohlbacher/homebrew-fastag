cask "fastag-cli" do
  arch arm: "arm64", intel: "x64"

  version "1.5.0"
  sha256 arm:   "d4cc0eaa6c16e31cd73fd4c56aaff8b78cad16f2d75e440eef9c1f91ddeac0e4",
         intel: "c3749670cb2823503b3ecd25eaf49f76c610f6801557ca4683825aa85bf0b16b"

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
