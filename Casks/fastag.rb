cask "fastag" do
  version "1.10.0"
  sha256 "06fdcc1057e8db443a6c03a991e9cd84282f84b2b7cf50e565143b63bd231a75"

  url "https://github.com/okohlbacher/FASTag/releases/download/v#{version}/FASTag-gui-macos-arm64.dmg"
  name "FASTag"
  desc "Sequence-tag search and species identification for tandem mass spectra"
  homepage "https://okohlbacher.github.io/FASTag/"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Apple silicon only from 1.8.0 on. The command-line tool the app bundles
  # targets macOS 13.4, which Homebrew cannot express (:ventura is 13.0), so
  # the cask declares 14.
  depends_on arch: :arm64
  depends_on macos: :sonoma

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
