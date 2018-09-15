#!/bin/bash

set -euxo pipefail

cd "$(dirname "$0")"

chflags nohidden ~/Library
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

which -s brew; if [[ $? != 0 ]]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    brew update
fi

if [ -f Brewfile ]; then
    brew bundle install
fi

if [ -f .aliases ]; then
    ln -sf .aliases ~/.aliases
fi

if [ -f .zshrc ]; then
    ln -sf .zshrc ~/.zshrc
fi

if [ ! -f ~/Library/Fonts/Menlo\ for\ Powerline.ttf ]; then
    curl -sLo fonts.zip https://github.com/abertsch/Menlo-for-Powerline/archive/master.zip
    unzip -j fonts.zip -d fonts/
    cp -f fonts/*.ttf ~/Library/Fonts/
    rm -rf fonts*
fi

if [ ! -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
else
    exec ${SHELL} -l
fi
