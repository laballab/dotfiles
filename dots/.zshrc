# =========================
#  ~/.zshrc
# =========================

# ---- 0) homebrew ----
[ -f /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# ---- 1) instant prompt ----
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# ---- 2) basic ----
export SHELL="${SHELL:-$(command -v zsh)}"
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt INTERACTIVE_COMMENTS

HISTFILE=~/.zsh_history
HISTSIZE=200000
SAVEHIST=200000

setopt NO_BEEP
unsetopt FLOW_CONTROL

# ---- 3) completions ----
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ---- 4) bindings ----
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^R' history-incremental-search-backward

# ---- 5) tool setup ----
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"; fi
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"; fi
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"; fi
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"; fi

# yazi wrapper for changing dir on exit
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# ---- 6) aliases ----
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

# ---- 7) path / env ----
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

# ---- 8) per-machine overrides ----
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# ---- 9) plugins ----
# load antidote & plugins
if [ -f /usr/share/zsh-antidote/antidote.zsh ]; then
  source /usr/share/zsh-antidote/antidote.zsh  # arch/aur
elif [ -f "${ZDOTDIR:-$HOME}/.antidote/antidote.zsh" ]; then
  source "${ZDOTDIR:-$HOME}/.antidote/antidote.zsh"  # brew/manual
else
  echo "antidote not found"
fi && antidote load ~/.zsh_plugins 
# bind plugin keys as needed
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

