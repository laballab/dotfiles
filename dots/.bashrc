# =========================
#  ~/.bashrc
# =========================


# ---- 0) homebrew ----
[ -f /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# ---- 1) instant prompt ----
[[ $- != *i* ]] && return # skip if not interactive
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# ---- 2) basic ----
# check window size after each command and
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# match all files and zero or more directories and subdirectories.
shopt -s globstar

# append to the history file, don't overwrite it
shopt -s histappend

# autocd: if a command is a directory, cd into it
shopt -s autocd

# history control
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=200000
HISTFILESIZE=200000
HISTFILE=~/.bash_history

# ---- 3) tool setup ----
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"; fi
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init bash)"; fi
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"; fi
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"; fi

# yazi wrapper for changing dir on exit
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# ---- 4) aliases ----
alias ..='cd ..'
alias ...='cd ../..'
if command -v rg >/dev/null 2>&1; then
  alias grep='rg'; fi
if command -v lazygit >/dev/null 2>&1; then
  alias lzg='lazygit'; fi
if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd --group-directories-first'
  alias ll='lsd -lah --group-directories-first'
  alias la='lsd -a --group-directories-first'
  alias lt='lsd --tree'
  alias lla='ll'
fi

# ---- 5) path / env ----
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
  export VISUAL="nvim"
elif command -v vim >/dev/null 2>&1; then
  export EDITOR="vim"
  export VISUAL="vim"
else
  export EDITOR="vi"
  export VISUAL="vi"
fi

# ---- 6) per-machine overrides ----
if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi
