cask "fastag-cli" do
  arch arm: "arm64", intel: "x64"

  version "1.15.6"
  sha256 arm:   "ca475d71fd7373e0f3827d66cbc215b8951e294fe23e65ec28f83e39a62f7e9e",
         intel: "465bf28dcc7043392439e6c79e787142c3b7b87d60db6c5449c8c4d9fc016a9c"

  url "https://github.com/okohlbacher/FASTag/releases/download/v#{version}/FASTag-#{version}-macos-#{arch}.dmg"
  name "FASTag command-line tool"
  desc "Command-line sequence-tag search and species identification for tandem MS"
  homepage "https://okohlbacher.github.io/FASTag/"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Apple silicon and Intel (Intel again after 1.14.0). FASTag.bin targets macOS 13.4, which
  # Homebrew cannot express (:ventura is 13.0), so the cask declares 14.
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
