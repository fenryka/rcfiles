# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

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

alias ls="ls -FG"
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

export INPUTRC=~/.inputrc
#export PATH="/usr/texbin:$PATH"

if [ $HOSTNAME = "stormsender" ]; then
    export PATH="$PATH:~/bin"
    # IntellJiJ install location    
    export PATH="$PATH:~/bin/idea-IC-171.4694.23/bin"
fi
