cask "fastag" do
  arch arm: "arm64", intel: "x64"

  version "1.15.7"
  sha256 arm:   "b9832b8a26ebbd05dc0e5003d968cc5540405697e303f53797c519952b29773f",
         intel: "7a021fe8810743e0601d8c25559f37c914edb951addbe16d2957e9cca857b3ee"

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

  # From 1.15.2 the images carry Thermo's RawFileReader (Thermo .raw input).
  # Its licence (section 3.3) asks that end users agree not to redistribute
  # it; Homebrew mounts the image unattended past its licence prompt, so the
  # terms are stated here.
  caveats <<~EOS
    FASTag reads Thermo .raw files with Thermo Fisher Scientific's
    RawFileReader, which is not under FASTag's MIT licence but under
    Thermo's own licence (LICENSES/ThermoRawFileReader-License.txt in
    #{appdir}/FASTag.app/Contents/Resources/resources/fastag). By installing FASTag you accept it; in particular you
    may not redistribute the RawFileReader assemblies
    (ThermoFisher.CommonCore.*.dll) to others, nor exploit them commercially
    without Thermo's written consent.
    RawFileReader reading tool. Copyright © 2016 by Thermo Fisher Scientific, Inc. All rights reserved.
  EOS
end
