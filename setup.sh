#!/bin/bash

set -euxo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
IFS=$'\n\t'

cd "$(dirname "$0")"

chflags nohidden ~/Library

osascript -e 'tell application "System Settings" to quit'

OLD_SETTINGS_SHA256="$(defaults read | openssl sha256)"

defaults write com.apple.ActivityMonitor ShowCategory -int 0
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

defaults write com.apple.dock wvous-bl-corner -int 2
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-corner -int 1
defaults write com.apple.dock wvous-br-modifier -int 1048576
defaults write com.apple.dock wvous-tl-corner -int 4
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 5
defaults write com.apple.dock wvous-tr-modifier -int 0

defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerDoubleTapGesture -int 0
defaults -currentHost write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerDoubleTapGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 0
defaults -currentHost write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 0

defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
defaults write com.apple.finder NewWindowTarget -string "PfCm"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible AudioVideoModule" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible FaceTime" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible FocusModes" -bool false
defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  h:mm a"
defaults write com.apple.menuextra.clock ShowAMPM -bool true
defaults write com.apple.menuextra.clock ShowDate -int 0
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write com.apple.menuextra.clock ShowSeconds -bool true

defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool false
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain com.apple.mouse.scaling -float 0.6875
defaults -currentHost write NSGlobalDomain com.apple.trackpad.forceClick -bool true
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

if [ "${OLD_SETTINGS_SHA256}" != "$(defaults read | openssl sha256)" ]; then
  killall Dock
  killall Finder
  killall ControlCenter
fi

if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
fi

if ! which -s brew; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  BREW_SHELLENV='eval "$(/opt/homebrew/bin/brew shellenv)"'
  grep -qxF "$BREW_SHELLENV" "$HOME/.zprofile" 2>/dev/null \
    || echo "$BREW_SHELLENV" >> "$HOME/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  /usr/sbin/softwareupdate --install-rosetta --agree-to-license
else
  brew update
fi

if [ -f Brewfile ]; then
  HOMEBREW_CASK_OPTS="--adopt" brew bundle install --verbose
fi

symlinks=(
  ".aliases:.aliases"
  ".fzf.zsh:.fzf.zsh"
  ".gitignore:.gitignore"
  ".p10k.zsh:.p10k.zsh"
  ".zshrc:.zshrc"
  "cursor.json:Library/Application Support/Cursor/User/settings.json"
  "ghosttyconfig:Library/Application Support/com.mitchellh.ghostty/config"
)

for entry in "${symlinks[@]}"; do
  src="${entry%%:*}"
  dst="${entry#*:}"
  [ -f "$src" ] || continue
  mkdir -p "$HOME/$(dirname "$dst")"
  ln -sf "$PWD/$src" "$HOME/$dst"
done

FONT_DIR="$HOME/Library/Fonts"
MESLO_BASE="https://github.com/romkatv/powerlevel10k-media/raw/master"
mkdir -p "$FONT_DIR"
for f in "MesloLGS NF Regular.ttf" \
         "MesloLGS NF Bold.ttf" \
         "MesloLGS NF Italic.ttf" \
         "MesloLGS NF Bold Italic.ttf"; do
  if [ ! -f "$FONT_DIR/$f" ]; then
    curl -fsSL "$MESLO_BASE/${f// /%20}" -o "$FONT_DIR/$f"
  fi
done

git config --global alias.ci commit
git config --global alias.co checkout
git config --global alias.st status
git config --global branch.sort -committerdate
git config --global column.ui auto
git config --global commit.verbose true
git config --global core.editor "cursor --wait"
git config --global core.excludesfile ~/.gitignore
git config --global diff.algorithm histogram
git config --global diff.colorMoved plain
git config --global diff.mnemonicPrefix true
git config --global diff.renames true
git config --global fetch.all true
git config --global fetch.prune true
git config --global fetch.pruneTags true
git config --global help.autocorrect prompt
git config --global init.defaultBranch main
git config --global push.autoSetupRemote true
git config --global rebase.autoSquash true
git config --global rebase.autoStash true
git config --global rebase.updateRefs true
git config --global tag.sort version:refname
git config --global user.email "17838283+ilyalavrenov@users.noreply.github.com"
git config --global user.name "ilya lavrenov"

OP_AGENT_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
OP_SSH_SIGN="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
touch "$HOME/.ssh/config"
chmod 600 "$HOME/.ssh/config"
if ! grep -qF "$OP_AGENT_SOCK" "$HOME/.ssh/config"; then
  printf 'Host *\n\tIdentityAgent "%s"\n\n%s' "$OP_AGENT_SOCK" "$(cat "$HOME/.ssh/config")" > "$HOME/.ssh/config.tmp"
  mv "$HOME/.ssh/config.tmp" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
fi

if [ ! -f "$HOME/.ssh/signing-key.pub" ]; then
  curl -fsSL https://api.github.com/users/ilyalavrenov/ssh_signing_keys \
    | jq -r '.[0].key' > "$HOME/.ssh/signing-key.pub"
  chmod 600 "$HOME/.ssh/signing-key.pub"
fi
git config --global gpg.format ssh
git config --global gpg.ssh.program "$OP_SSH_SIGN"
git config --global user.signingkey "$HOME/.ssh/signing-key.pub"
git config --global commit.gpgsign true
git config --global tag.gpgsign true

if command -v cursor >/dev/null && [ -f cursor.ext ]; then
  installed="$(cursor --list-extensions)"
  while IFS= read -r ext; do
    grep -qxF "$ext" <<< "$installed" || cursor --install-extension "$ext"
  done < cursor.ext
fi

BREW_ZSH="$(brew --prefix)/bin/zsh"
if [ "${SHELL}" != "${BREW_ZSH}" ]; then
  if ! grep -qxF "${BREW_ZSH}" /etc/shells; then
    echo "${BREW_ZSH}" | sudo tee -a /etc/shells >/dev/null
  fi
  chsh -s "${BREW_ZSH}"
  autoload -Uz compaudit
  insecure="$(compaudit)"
  [ -n "$insecure" ] && chmod g-w $insecure
fi

