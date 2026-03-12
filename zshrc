
# ============================================================
# PATH  (consolidated)
# ============================================================
path=(
    "$HOME/bin"
    "$HOME/.local/bin"
    "/opt/homebrew/opt/python/libexec/bin"
    $path
)
export PATH

# ============================================================
# Homebrew  (adds /opt/homebrew/{bin,sbin} etc.)
# ============================================================
eval "$(/opt/homebrew/bin/brew shellenv)"

# ============================================================
# Nix
# ============================================================
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
export NETRC=/etc/nix/netrc

# ============================================================
# History
# ============================================================
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY           # sync across sessions
setopt HIST_IGNORE_DUPS        # no consecutive duplicates
setopt HIST_IGNORE_SPACE       # leading space = don't save
setopt HIST_EXPIRE_DUPS_FIRST  # expire dupes before unique entries
setopt HIST_FIND_NO_DUPS       # skip dupes when searching
setopt EXTENDED_HISTORY        # record timestamps

# ============================================================
# Options
# ============================================================
setopt AUTO_CD        # type a dir name to cd into it
setopt CORRECT        # suggest spelling corrections
setopt PROMPT_SUBST   # allow command substitution in PROMPT

# ============================================================
# Completion
# ============================================================
# Docker CLI completions must be on fpath before compinit runs
[[ -d $HOME/.docker/completions ]] && fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit && compinit

# ============================================================
# Claude
# ============================================================
export CLAUDE_CODE_INSTALL_MEMORY=1

# ============================================================
# GPG
# ============================================================
export GPG_TTY=$(tty)
gpgconf --launch gpg-agent

# ============================================================
# Aliases
# ============================================================
alias gvim="/Applications/MacVim.app/Contents/bin/mvim"
alias grep="grep --color -n"
alias pd="pushd ."
alias pcd="pd; cd"
alias path='echo $PATH | tr ":" "\n"'

alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --icons --group-directories-first --git'
alias la='eza -lah --icons --group-directories-first --git'
alias lt='eza --tree --icons --level=2'
alias l.='eza -d .* --icons'

alias gwl='git worktree list'

# ============================================================
# Functions
# ============================================================
mkcd() { mkdir -p "$1" && cd "$1" }

gwt() { git worktree add "../${1}" "${1}" }

git-worktree-clone() {
    mkdir "$2" && cd "$2"
    git clone --bare "$1" .bare
    git -C .bare config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    git -C .bare fetch
}

# ============================================================
# Key bindings — prefix-aware history search
# ============================================================
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

# ============================================================
# Prompt
# ============================================================
autoload -Uz vcs_info

zstyle ':vcs_info:*'      enable           git
zstyle ':vcs_info:git:*'  check-for-changes true
zstyle ':vcs_info:git:*'  unstagedstr      '%F{red}✗%f'
zstyle ':vcs_info:git:*'  stagedstr        '%F{green}✔%f'
zstyle ':vcs_info:git:*'  formats          ' on %F{magenta}%b%f %u%c'
zstyle ':vcs_info:git:*'  actionformats    ' on %F{magenta}%b%f %F{yellow}(%a)%f %u%c'

precmd() {
    _last_exit=$?  # capture before vcs_info resets it
    vcs_info
}

_prompt_status() {
    if [[ $_last_exit -eq 0 ]]; then
        echo "%F{green}✓%f"
    else
        echo "%F{red}✗ $_last_exit%f"
    fi
}

# Line 1: time  user@host  path  git-info
# Line 2: status ❯
PROMPT='%F{cyan}%*%f %F{yellow}%n%f%F{white}@%f%F{green}%m%f %F{blue}%~%f${vcs_info_msg_0_}
$(_prompt_status) %F{white}❯%f '

# ============================================================
# direnv
# ============================================================
eval "$(direnv hook zsh)"

# ============================================================
# zoxide — smarter cd with frecency ranking
# install: brew install zoxide
# ============================================================
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# ============================================================
# fzf — fuzzy finder (Ctrl+R history, Ctrl+T files, Alt+C cd)
# install: brew install fzf
# ============================================================
if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
fi

# ============================================================
# Local overrides
# ============================================================
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ============================================================
# Plugins (order matters — autosuggestions before highlighting)
# ============================================================

# zsh-autosuggestions — fish-style ghost-text history suggestions
# install: brew install zsh-autosuggestions
[[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax highlighting — must be sourced last
[[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
