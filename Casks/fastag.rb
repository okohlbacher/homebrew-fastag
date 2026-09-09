cask "fastag" do
  arch arm: "arm64", intel: "x64"

  version "1.4.2"
  sha256 arm:   "c546b4e5d509e920a732a54542bdecd810f6081a58e39322e1052a12e0f26eec",
         intel: "fba1b7aca9f5c309312377dd758068fa1b7fb16a5b89d208db589e586949c3d5"

  # The app's Info.plist says 11.0, but the command-line tool it bundles and
  # runs is built without a deployment target, so its floor is the SDK of the
  # runner that built it: macOS 14 on arm64, macOS 15 on x64. Below that the
  # app launches and every run fails. These floors follow the binary.
  on_arm do
    depends_on macos: :sonoma
  end
  on_intel do
    depends_on macos: :sequoia
  end

  url "https://github.com/okohlbacher/FASTag/releases/download/v#{version}/FASTag-gui-macos-#{arch}.dmg"
  name "FASTag"
  desc "Sequence-tag search and species identification for tandem mass spectra"
  homepage "https://okohlbacher.github.io/FASTag/"

  livecheck do
    url :url
    strategy :github_latest
  end

  app "FASTag.app"

  uninstall quit: "de.openms.fastag"

  zap trash: [
    "~/Library/Application Support/de.openms.fastag",
    "~/Library/Caches/de.openms.fastag",
    "~/Library/Preferences/de.openms.fastag.plist",
    "~/Library/Saved Application State/de.openms.fastag.savedState",
    "~/Library/WebKit/de.openms.fastag",
  ]
end
