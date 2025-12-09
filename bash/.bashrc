# USER bashrc
# ~/.bashrc
#

source "/home/timo/.config/shell/bashrc-common"
alias cd='z'
alias cdi='zi'

alias c='cd'

#alias j='z'
#alias ji='zi'
eval "$(zoxide init bash)"
. "$HOME/.cargo/env"

#Für Python versionen
#export PYENV_ROOT="$HOME/.pyenv"
#export PATH="$PYENV_ROOT/bin:$PATH"
#eval "$(pyenv init --path)"
