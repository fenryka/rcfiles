#
# If not running interactively, don't do anything
#
case $- in
    *i*) ;;
      *) return;;
esac

export INPUTRC=~/.inputrc

HOST=`hostname`

#
# Set the command prompt up the way I like it
#
PS1='[\[\033[0;34m\]\u\[\033[0m\]\[\033[0;32m\]@\[\033[0m\]\[\033[0;35m\]\h\[\033[0m\] \[\033[0;36m\]\W\[\033[0m\]] '

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

alias vim="vim -n -p"
alias bim="vim -n -p"
alias cim="vim -n -p"
alias ee="exit"
alias cc="clear"
alias mkae="make"
alias mkea="make"
alias amke="make"
alias bash="exec bash"
alias grep="grep --color -n"
alias gvim="gvim -p"
alias pd="pushd ."
alias pcd="pd; cd"

if [ "$(uname)" == "Darwin" ]; then
    alias ls="ls -FG"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    alias ls="ls --color=auto"
fi

shopt -s checkwinsize

source ~/.bashrc.local
