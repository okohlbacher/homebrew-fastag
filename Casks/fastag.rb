cask "fastag" do
  version "1.16.3"
  sha256 "34749ec37c8cb0e79b11d3b3c49dbd751cd5e22820804d037f522d63e77743c0"

  url "https://github.com/okohlbacher/FASTag/releases/download/v#{version}/FASTag-#{version}-gui-macos-arm64.dmg"
  name "FASTag"
  desc "Sequence-tag search and species identification for tandem mass spectra"
  homepage "https://okohlbacher.github.io/FASTag/"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Apple silicon only: Intel builds ended with 1.16.1. The command-line tool the app bundles
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
