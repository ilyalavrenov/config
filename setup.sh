#!/bin/bash

set -euxo pipefail

cd "$(dirname "$0")"

chflags nohidden ~/Library

defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder NewWindowTarget -string "PfCm"
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
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

defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  h:mm a"
defaults write com.apple.menuextra.battery ShowPercent -bool true

defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

if ! which -s brew; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    brew update
fi

if [ -f Brewfile ]; then
    brew bundle install
fi

if [ -f .aliases ]; then
    ln -sf $(pwd)/.aliases ~/.aliases
fi

if [ -f .zshrc ]; then
    ln -sf $(pwd)/.zshrc ~/.zshrc
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
