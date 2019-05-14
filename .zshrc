export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="agnoster"

plugins=(
    aws
    docker
    git
    kubectl
    osx
    terraform
)

sources=(
    $ZSH/oh-my-zsh.sh
    /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    ~/.aliases
    ~/.localrc
    ~/.fzf.zsh
)

for file in ${sources[@]}; do
    [ -f $file ] && source $file
done

export PATH=$PATH:$(go env GOPATH)/bin