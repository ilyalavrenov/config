# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export BREW_PREFIX="/opt/homebrew"
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

sources=(
    ${BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    ${BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
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

if type brew &>/dev/null; then
    FPATH=${BREW_PREFIX}/share/zsh-completions:${FPATH}
fi

autoload -Uz compinit
compinit -C

if command -v kubectl &>/dev/null; then
    source <(kubectl completion zsh)
    compdef __start_kubectl k
fi

if command -v terraform &>/dev/null; then
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C "$(command -v terraform)" terraform tf
fi

# fix slowness of pastes with zsh-syntax-highlighting.zsh
zstyle ':bracketed-paste-magic' active-widgets '.self-*'
