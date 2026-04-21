# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export BREW_PREFIX="/opt/homebrew"
export ZSH="${HOME}/.oh-my-zsh"
export EDITOR="cursor --wait"
export AWS_PAGER=""
export PATH="${PATH}:${HOME}/go/bin"

export HISTSIZE=100000
export SAVEHIST=${HISTSIZE}
setopt appendhistory
setopt sharehistory
setopt incappendhistory
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify

plugins=(
    docker
    git
    kubectl
    macos
    terraform
)

sources=(
    ${ZSH}/oh-my-zsh.sh
    ${BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    ${BREW_PREFIX}/share/powerlevel10k/powerlevel10k.zsh-theme
    ~/.p10k.zsh
    ~/.aliases
    ~/.localrc
    ~/.fzf.zsh
    ~/.config/op/plugins.sh
)

for file in ${sources[@]}; do
    [ -f ${file} ] && source ${file}
done

[[ "$TERM_PROGRAM" == "iTerm.app" ]] && [ -f ~/.iterm2_shell_integration.zsh ] && source ~/.iterm2_shell_integration.zsh

if type brew &>/dev/null; then
    FPATH=${BREW_PREFIX}/share/zsh-completions:${FPATH}

    autoload -Uz compinit
    compinit -C
fi

# fix slowness of pastes with zsh-syntax-highlighting.zsh
pasteinit() {
    OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
    zle -N self-insert url-quote-magic
}
pastefinish() {
    zle -N self-insert ${OLD_SELF_INSERT}
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish
