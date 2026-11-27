cask "fastag-cli" do
  version "1.16.4"
  sha256 "050e423ec83ef3ace53d04d1af5ae4da1ad6984b2afa95b291637c6ead5e6296"

  url "https://github.com/okohlbacher/FASTag/releases/download/v#{version}/FASTag-#{version}-macos-arm64.dmg"
  name "FASTag command-line tool"
  desc "Command-line sequence-tag search and species identification for tandem MS"
  homepage "https://okohlbacher.github.io/FASTag/"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Apple silicon only: Intel builds ended with 1.16.1. FASTag.bin targets macOS 13.4, which
  # Homebrew cannot express (:ventura is 13.0), so the cask declares 14.
  depends_on arch: :arm64
  depends_on macos: :sonoma

  # The image holds one folder, FASTag/: a /bin/sh wrapper (FASTag), the
  # Mach-O it execs (FASTag.bin), the dylib closure (lib/) and the data the
  # wrapper points OPENMS_DATA_PATH at (share-OpenMS/, share-FASTag-taxonomy/).
  # The wrapper resolves all of that relative to its own $0, so it has to be
  # invoked by its absolute staged path: a plain `binary` symlink in bin/
  # would make $0 = $(brew --prefix)/bin/FASTag and break every lookup.
  command_wrapper "FASTag", executable: "#{staged_path}/FASTag/FASTag"

  # From 1.15.2 the images carry Thermo's RawFileReader (Thermo .raw input).
  # Its licence (section 3.3) asks that end users agree not to redistribute
  # it; Homebrew mounts the image unattended past its licence prompt, so the
  # terms are stated here.
  caveats <<~EOS
    FASTag reads Thermo .raw files with Thermo Fisher Scientific's
    RawFileReader, which is not under FASTag's MIT licence but under
    Thermo's own licence (LICENSES/ThermoRawFileReader-License.txt in
    #{staged_path}/FASTag). By installing FASTag you accept it; in particular you
    may not redistribute the RawFileReader assemblies
    (ThermoFisher.CommonCore.*.dll) to others, nor exploit them commercially
    without Thermo's written consent.
    RawFileReader reading tool. Copyright © 2016 by Thermo Fisher Scientific, Inc. All rights reserved.
  EOS
end
