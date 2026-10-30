# Homebrew's form of install.sh: `brew install jannis-lehnert/studioassistant/studioassistant-satellite`.
#
# A cask, not a formula, because the steps need root and a formula never has it: post_install runs in
# Homebrew's sandbox, writing only to the Cellar and the prefix, so a formula could not lay down
# /Library/LaunchDaemons and would leave `sudo brew services start` as a manual step. A cask's
# installer stanza runs under sudo. It runs the installer the channel publishes (stamped with the
# manifest-signing key, deploy-satellite-studioassistant.yml "Publish"), whose main() reads the channel
# manifest, checks the digest of the signed and notarised osx-arm64 archive and calls install_archive
# — so, as with the .pkg and the .deb, there is no second copy of the layout or the launchd steps.
#
# Nothing here names a release: the newest build is resolved by install.sh at install time and the
# satellite's self-update lane follows the channel from then on, hence :latest and auto_updates. This
# file is mirrored byte for byte to Casks/ in Jannis-Lehnert/homebrew-studioassistant, and only a
# change here needs copying there.
#
# Homebrew strips the environment except for HOMEBREW_*, which is why the channel is stated that way:
#   HOMEBREW_STUDIOASSISTANT_SATELLITE_CHANNEL=internal brew install <this cask>
cask "studioassistant-satellite" do
  channel = ENV.fetch("HOMEBREW_STUDIOASSISTANT_SATELLITE_CHANNEL", "stable")
  installer_url = "https://www.studio-assistant.com/download/satellite/studioassistant/#{channel}/install.sh"

  version :latest
  sha256 :no_check

  url installer_url
  name "Studio Assistant Satellite"
  desc "Local satellite daemon for Studio Assistant"
  homepage "https://www.studio-assistant.com/"

  auto_updates true
  depends_on arch: :arm64

  # sha256 :no_check checks nothing, and a walled host answers HTTP 200 with its login page, so make
  # sure sudo is about to run the installer and not that page.
  preflight do
    next if (staged_path/"install.sh").read(2) == "#!"

    raise CaskError, "#{installer_url} did not answer with the installer; is the download host behind its wall?"
  end

  installer script: {
    executable: "/usr/bin/env",
    args:       ["SATELLITE_CHANNEL=#{channel}", "/bin/bash", "#{staged_path}/install.sh"],
    sudo:       true,
  }

  # Like the .deb's removal: the service goes, the install root stays until it is asked for.
  uninstall launchctl: [
              "com.jannis-lehnert.pluginhostsharp.broker",
              "com.studio-assistant.satellite",
            ],
            delete:    [
              "/Library/LaunchAgents/com.jannis-lehnert.pluginhostsharp.broker.plist",
              "/Library/LaunchDaemons/com.studio-assistant.satellite.plist",
            ]

  zap delete: "/opt/studio-assistant/satellite"
end
