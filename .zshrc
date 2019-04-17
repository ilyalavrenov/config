export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="agnoster"
plugins=(
    aws
    docker
    git
    osx
    terraform
)
source $ZSH/oh-my-zsh.sh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export PATH=$GOPATH/bin:$PATH

if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

if [ -f ~/.localrc ]; then
    . ~/.localrc
fi