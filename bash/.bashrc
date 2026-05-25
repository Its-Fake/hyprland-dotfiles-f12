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

ssh-home() {
  ssh -L 9696:localhost:9696 -L 8085:localhost:8085 -L 7878:localhost:7878 -L 8989:localhost:8989 -L 8096:localhost:8096 -L 5055:localhost:5055 -L 8080:localhost:8080 homeserver
}

#Für Python versionen
#export PYENV_ROOT="$HOME/.pyenv"
#export PATH="$PYENV_ROOT/bin:$PATH"
#eval "$(pyenv init --path)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export PATH=$PATH:/home/timo/.spicetify
