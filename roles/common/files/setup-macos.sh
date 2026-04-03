#!/bin/sh

# This script configures a (fairly) clean install to behave as I prefer
# See https://robin.hutty.us/articles/macos-config/ for details

# Please use `shfmt -s -d -i 2 -bn -ci -ln posix <this_file>` to format/lint

export LANG="en_US.UTF-8"
export LC_ALL="en_US.utf-8"
START=$(date '+%F %T')

abs_me="$0"
base_me=$(basename "$abs_me")
me_dir=$(dirname "$abs_me")

fail() {
  echo "$base_me - critical: $*"
  echo "Start: $START"
  echo "End: $(now)"
  exit 1
}

load_lib() {
  lib="$1"
  test -d "$lib" && fail "loading directories is not supported"
  test -r "$lib" || fail "failed to load lib: $lib, not readable"
  test -x "$lib" || fail "failed to load lib: $lib, not executable"
  echo "Loading $lib"
  . "$lib" && return 0
  fail "failed to load lib: $lib"
}

load_lib "${me_dir}/posix-shlib.sh"

brew_bundle=0 # whether to run `brew bundle`

macos_version=$(sw_vers --productVersion)
macos_major_version=$(echo "$macos_version" | cut -d. -f1)
macos_minor_version=$(echo "$macos_version" | cut -d. -f2)
case "$macos_major_version" in # See https://en.wikipedia.org/wiki/MacOS#Release_history
  26) macos_ver_name="Tahoe" ;;
  15) macos_ver_name="Sequoia" ;;
  14) macos_ver_name="Sonoma" ;;
  13) macos_ver_name="Ventura" ;;
  12) macos_ver_name="Monterey" ;;
  11) macos_ver_name="Big Sur" ;;
esac
echo "macOS ${macos_ver_name} (${macos_major_version}.${macos_minor_version})"

# XCode command line tools
if test -e "/Library/Developer/CommandLineTools/usr/bin/git"; then
  xcode_clt=no
else
  xcode_clt=yes
fi

if [ $xcode_clt = "yes" ]; then
  clt_label_command="/usr/sbin/softwareupdate -l |
                      grep -B 1 -E 'Command Line Tools' |
                      awk -F'*' '/^ *\\*/ {print \$2}' |
                      sed -e 's/^ *Label: //' -e 's/^ *//' |
                      sort -V |
                      tail -n1"
  clt_label="$(sh -c "${clt_label_command}")"
  if [ "$clt_label" != "" ]; then
    "/usr/sbin/softwareupdate" "-i" "${clt_label}" "--agree-to-license" \
      && "/usr/bin/xcode-select" "--switch" "/Library/Developer/CommandLineTools"
  fi
fi

if is_command brew; then
  log_info 'Homebrew is available'
  if [ $brew_bundle = 1 ] && [ -f "Brewfile" ]; then
    brew bundle check >/dev/null 2>&1 || {
      echo "==> Installing Homebrew packages..."
      brew bundle
    }
  fi
else
  log_warn 'Homebrew is not available/enabled, skipped package installation via "brew bundle"'
fi


# # Test presence of some graphical communication apps: signal, slack, zoom, teams, skype, whatsapp
# if is_usable "/Applications/iTerm.app/Contents/MacOS/iTerm2"; then
#   log_info 'iTerm is available'
# else
#   log_warn 'iTerm is not available'
# fi

## TODO
# Fonts
# Dotfiles: chezmoi? just pull from $git_repo? GIT_PATH="https://github.com/robinhutty/dotfiles.git" or similar?
# Networking: e.g. profiles for different networks/locations?
# (un)do more Apple 'defaults' settings?

# Click in the scrollbar to jump to the spot that is clicked
defaults write -globalDomain AppleScrollerPagingBehavior -bool true

########################
# Finder > Preferences #
########################

# Unhide hidden files
defaults write com.apple.finder AppleShowAllFiles YES

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder > View > As List
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Finder > View > Show Path Bar
defaults write com.apple.finder ShowPathbar -bool true

# Kill affected apps
for app in "Dock" "Finder"; do
  killall "${app}" >/dev/null 2>&1
done

#######################################
# System Preferences > Control Centre #
#######################################

# Control Centre Modules > Bluetooth > Show in Menu Bar
defaults write "com.apple.controlcenter" "NSStatusItem Visible Bluetooth" -bool true

# Control Centre Modules > Screen Mirroring > Don't Show in Menu Bar
defaults write "com.apple.airplay" showInMenuBarIfPresent -bool true

# Control Centre Modules > Sound > Always Show in Menu Bar
defaults write "com.apple.controlcenter" "NSStatusItem Visible Sound" -bool true

# Menu Bar Only > Clock Options > Show the day of a week
defaults write "com.apple.menuextra.clock" ShowDayOfWeek -bool true

#######################################
# System Preferences > Desktop & Dock #
#######################################

# Dock > Minimize windows into application icon
defaults write com.apple.dock minimize-to-application -bool true

# Dock > Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Dock > Automatically hide and show the Dock (duration)
defaults write com.apple.dock autohide-time-modifier -float 0.4

# Dock > Automatically hide and show the Dock (delay)
defaults write com.apple.dock autohide-delay -float 0

# Show recent applications in Dock
defaults write com.apple.dock "show-recents" -bool true

apple_update=0
if [ $apple_update != 0 ]; then
  "/usr/sbin/softwareupdate" "-i" "-a" "--agree-to-license"
fi

echo "Start: $START"
END=$(now)
echo "End: $END"

# vi: ft=sh
