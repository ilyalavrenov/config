if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export AWS_PAGER=""
export BREW_PREFIX="/opt/homebrew"
export EDITOR="cursor --wait"
export PATH="${PATH}:${HOME}/go/bin"
export WORDCHARS=""

export HISTSIZE=100000
export SAVEHIST=${HISTSIZE}
setopt appendhistory
setopt extended_history
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify
setopt incappendhistory
setopt sharehistory

setopt auto_cd
setopt auto_pushd
setopt interactive_comments
setopt pushd_ignore_dups
setopt pushd_silent

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select

# fix slowness of pastes with zsh-syntax-highlighting.zsh
zstyle ':bracketed-paste-magic' active-widgets '.self-*'

bindkey -e
bindkey "^[[H"  beginning-of-line
bindkey "^[[F"  end-of-line
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line

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

if command -v mise &>/dev/null; then
    eval "$(mise activate zsh)"
fi

