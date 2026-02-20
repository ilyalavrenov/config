# Use cached brew prefix or fallback
BREW_PREFIX=${BREW_PREFIX:-"/opt/homebrew"}

# Setup fzf
# ---------
if [[ ! "$PATH" == *${BREW_PREFIX}/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}${BREW_PREFIX}/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "${BREW_PREFIX}/opt/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "${BREW_PREFIX}/opt/fzf/shell/key-bindings.zsh"
