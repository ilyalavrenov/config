# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH=$HOME/.oh-my-zsh

export HISTSIZE=1000000000
export HISTFILESIZE=1000000000
export SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory
setopt incappendhistory

plugins=(
    docker
    git
    kubectl
    osx
    terraform
)

sources=(
    $ZSH/oh-my-zsh.sh
    $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    $(brew --prefix)/opt/powerlevel10k/powerlevel10k.zsh-theme
    ~/.p10k.zsh
    ~/.aliases
    ~/.localrc
    ~/.fzf.zsh
)

for file in ${sources[@]}; do
    [ -f $file ] && source $file
done

export PATH="/usr/local/sbin:$PATH"
export EDITOR="code --wait"

if type go &>/dev/null; then
    export PATH=$PATH:$(go env GOPATH)/bin
fi

if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
fi

# fix slowness of pastes with zsh-syntax-highlighting.zsh
pasteinit() {
    OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
    zle -N self-insert url-quote-magic
}
pastefinish() {
    zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish
