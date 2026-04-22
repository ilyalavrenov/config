#!/bin/bash
set -euo pipefail

trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
IFS=$'\n\t'

log() { printf '\n==> %s\n' "$*"; }

setup_macos_settings() {
  log "setup: macos settings"

  chflags nohidden ~/Library
  osascript -e 'tell application "System Settings" to quit'

  local old_sha
  old_sha="$(defaults read | openssl sha256)"

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

  if [ "$old_sha" != "$(defaults read | openssl sha256)" ]; then
    killall Dock
    killall Finder
    killall ControlCenter
  fi
}

setup_xcode_cli() {
  log "setup: xcode command line tools"
  if ! xcode-select -p >/dev/null 2>&1; then
    xcode-select --install
  fi
}

setup_rosetta() {
  log "setup: rosetta"
  if ! grep -qx com.apple.pkg.RosettaUpdateAuto <(pkgutil --pkgs); then
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
  fi
}

setup_homebrew() {
  log "setup: homebrew"
  if ! which -s brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    local brew_shellenv='eval "$(/opt/homebrew/bin/brew shellenv)"'
    grep -qxF "$brew_shellenv" "$HOME/.zprofile" 2>/dev/null \
      || echo "$brew_shellenv" >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  if [ -f Brewfile ]; then
    HOMEBREW_CASK_OPTS="--adopt" brew bundle install --quiet
  fi
}

setup_symlinks() {
  log "setup: symlinks"
  local symlinks=(
    ".aliases:.aliases"
    ".fzf.zsh:.fzf.zsh"
    ".gitignore:.gitignore"
    ".p10k.zsh:.p10k.zsh"
    ".zshrc:.zshrc"
    "cursor.json:Library/Application Support/Cursor/User/settings.json"
    "ghosttyconfig:Library/Application Support/com.mitchellh.ghostty/config"
    "mise.toml:.config/mise/config.toml"
  )
  local entry src dst
  for entry in "${symlinks[@]}"; do
    src="${entry%%:*}"
    dst="${entry#*:}"
    [ -f "$src" ] || continue
    mkdir -p "$HOME/$(dirname "$dst")"
    ln -sf "$PWD/$src" "$HOME/$dst"
  done
}

setup_claude_settings() {
  log "setup: claude settings"
  mkdir -p "$HOME/.claude"
  local base="$PWD/claude-settings.json"
  local overlay="$HOME/.claude/settings.local-overlay.json"
  local out="$HOME/.claude/settings.json"
  [ -L "$out" ] && rm "$out"
  local union_keys='["permissions.allow","permissions.ask","permissions.additionalDirectories"]'
  if [ -f "$overlay" ]; then
    jq -n --slurpfile base "$base" --slurpfile overlay "$overlay" --argjson union "$union_keys" '
      def path_of(s): s | split(".") | map(if test("^[0-9]+$") then tonumber else . end);
      def deep_merge(a; b):
        if (a | type) == "object" and (b | type) == "object" then
          reduce ((a | keys_unsorted) + (b | keys_unsorted) | unique)[] as $k
            ({}; .[$k] = (if (a | has($k)) and (b | has($k)) then deep_merge(a[$k]; b[$k]) elif (b | has($k)) then b[$k] else a[$k] end))
        else b end;
        $base[0] as $b | $overlay[0] as $o | deep_merge($b; $o) as $merged
      | reduce $union[] as $key ($merged;
          path_of($key) as $p
        | ($b | getpath($p)? // []) as $ba
        | ($o | getpath($p)? // []) as $ov
        | if ($ba | type) == "array" or ($ov | type) == "array"
            then setpath($p; (($ba + $ov) | unique))
            else . end)
    ' > "$out.tmp"
    mv "$out.tmp" "$out"
  else
    cp "$base" "$out"
  fi
}

setup_mise_tools() {
  if command -v mise >/dev/null; then
    log "setup: mise tools"
    mise trust --quiet "$PWD/mise.toml"
    mise install --quiet
  fi
}

setup_fonts() {
  log "setup: fonts"
  local font_dir="$HOME/Library/Fonts"
  local meslo_base="https://github.com/romkatv/powerlevel10k-media/raw/master"
  mkdir -p "$font_dir"
  local f
  for f in "MesloLGS NF Regular.ttf" \
           "MesloLGS NF Bold.ttf" \
           "MesloLGS NF Italic.ttf" \
           "MesloLGS NF Bold Italic.ttf"; do
    if [ ! -f "$font_dir/$f" ]; then
      curl -fsSL "$meslo_base/${f// /%20}" -o "$font_dir/$f"
    fi
  done
}

setup_git() {
  log "setup: git"
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
}

setup_ssh() {
  log "setup: ssh"
  local op_agent_sock="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  local op_ssh_sign="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  touch "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
  if ! grep -qF "$op_agent_sock" "$HOME/.ssh/config"; then
    printf 'Host *\n\tIdentityAgent "%s"\n\n%s' "$op_agent_sock" "$(cat "$HOME/.ssh/config")" > "$HOME/.ssh/config.tmp"
    mv "$HOME/.ssh/config.tmp" "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
  fi
  if [ ! -f "$HOME/.ssh/signing-key.pub" ]; then
    curl -fsSL https://api.github.com/users/ilyalavrenov/ssh_signing_keys \
      | jq -r '.[0].key' > "$HOME/.ssh/signing-key.pub"
    chmod 600 "$HOME/.ssh/signing-key.pub"
  fi
  git config --global gpg.format ssh
  git config --global gpg.ssh.program "$op_ssh_sign"
  git config --global user.signingkey "$HOME/.ssh/signing-key.pub"
  git config --global commit.gpgsign true
  git config --global tag.gpgsign true
}

setup_cursor_extensions() {
  if command -v cursor >/dev/null && [ -f cursor.ext ]; then
    log "setup: cursor extensions"
    export NODE_NO_WARNINGS=1
    local installed ext
    installed="$(cursor --list-extensions)"
    while IFS= read -r ext; do
      grep -qxF "$ext" <<< "$installed" || cursor --install-extension "$ext"
    done < cursor.ext
    unset NODE_NO_WARNINGS
  fi
}

setup_shell() {
  local brew_zsh
  brew_zsh="$(brew --prefix)/bin/zsh"
  if [ "${SHELL}" != "${brew_zsh}" ]; then
    log "setup: default shell"
    if ! grep -qxF "${brew_zsh}" /etc/shells; then
      echo "${brew_zsh}" | sudo tee -a /etc/shells >/dev/null
    fi
    chsh -s "${brew_zsh}"
    "${brew_zsh}" -c 'autoload -Uz compaudit; insecure=(${(@f)"$(compaudit)"}); (( ${#insecure[@]} )) && chmod g-w "${insecure[@]}"'
  fi
}

main() {
  cd "$(dirname "$0")"

  log "setup: starting"

  setup_macos_settings
  setup_xcode_cli
  setup_rosetta
  setup_homebrew
  setup_symlinks
  setup_claude_settings
  setup_mise_tools
  setup_fonts
  setup_git
  setup_ssh
  setup_cursor_extensions
  setup_shell

  log "setup: finished"
}

main "$@"
