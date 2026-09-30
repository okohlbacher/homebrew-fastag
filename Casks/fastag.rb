cask "fastag" do
  arch arm: "arm64", intel: "x64"

  version "1.5.0"
  sha256 arm:   "79ff5902c22c1040a7feb318b17560c292e5cb75ca2d7d095a8fba64f040a0d4",
         intel: "cd96c0ecb08e7b33913a7522524517162336112b9e34a95db1883c2a490578e0"

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
