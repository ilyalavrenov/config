#!/bin/bash

set -uxo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
IFS=$'\n\t'

cd "$(dirname "$0")"

chflags nohidden ~/Library

osascript -e 'tell application "System Preferences" to quit'

defaults write com.apple.ActivityMonitor ShowCategory -int 0
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder NewWindowTarget -string "PfCm"
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder QLEnableTextSelection -bool true

defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

defaults write com.apple.dock wvous-tl-corner -int 4
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 5
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner -int 2
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-corner -int 7
defaults write com.apple.dock wvous-br-modifier -int 0

defaults write com.apple.LaunchServices LSQuarantine -bool false

defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  h:mm a"
defaults write com.apple.menuextra.battery ShowPercent -bool true

defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

if ! xcode-select --version; then
    xcode-select --install
fi

if ! which -s brew; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    brew update
fi

if [ -f Brewfile ]; then
    brew bundle install
fi

symlinks=(
    .aliases
    .fzf.zsh
    .gitignore
    .zshrc
)

for file in ${symlinks[@]}; do
    [ -f $file ] && ln -sf $PWD/$file ~/$file
done

git config --global user.name "ilya lavrenov"
git config --global user.email "17838283+ilyalavrenov@users.noreply.github.com"
git config --global core.excludesfile ~/.gitignore

if [ ! -f ~/.ssh/id_rsa.pub ]; then
    ssh-keygen -t rsa -b 4096
    cat ~/.ssh/id_rsa.pub
    echo "add this pubkey to github \n"
    echo "https://github.com/account/ssh \n"
    read -p "hit [enter] to continue..."
fi

if [ ! -f ~/Library/Fonts/Menlo\ for\ Powerline.ttf ]; then
    curl -sLo fonts.zip https://github.com/abertsch/Menlo-for-Powerline/archive/master.zip
    unzip -j fonts.zip -d fonts/
    cp -f fonts/*.ttf ~/Library/Fonts/
    rm -rf fonts*
fi

if [ ! -d ~/.oh-my-zsh ]; then
    git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
    chsh -s /bin/zsh
else
    exec ${SHELL} -l
fi
