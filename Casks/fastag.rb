cask "fastag" do
  arch arm: "arm64", intel: "x64"

  version "1.15.0"
  sha256 arm:   "8a4df864dc05b2faf01bb679f8c69596cd298b01f6d1bef0720ecc0a0c74c48b",
         intel: "8231d45eb3546fbdad7f642119b353579e1f6bfd466b4e6a8275b8c6574eebca"

  url "https://github.com/okohlbacher/FASTag/releases/download/v#{version}/FASTag-#{version}-gui-macos-#{arch}.dmg"
  name "FASTag"
  desc "Sequence-tag search and species identification for tandem mass spectra"
  homepage "https://okohlbacher.github.io/FASTag/"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Apple silicon and Intel (Intel again after 1.14.0). The command-line tool the app bundles
  # targets macOS 13.4, which Homebrew cannot express (:ventura is 13.0), so
  # the cask declares 14.
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
