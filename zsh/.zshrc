# ----------------------------------------
# .zshrc
# 2022
# ----------------------------------------

# Sections:
# <1> - PATH
# <2> - OMZ
# <3> - USER


# ----------------------------------------
# PATH Setup
# ----------------------------------------

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# update path for brew
# export PATH="/opt/homebrew/bin:$PATH"

# remove PATH duplicates
export PATH=$(awk -F: '{for (i=1;i<=NF;i++) { if (!x[$i]++) printf("%s:",$i); }}' <<< $PATH | sed 's/.$//')

# completions
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
# fpath+=$(brew --prefix)/share/zsh/site-functions


# ----------------------------------------
# OMZ Configs
# ----------------------------------------

# Set name of the theme to load
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="bureau"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode disabled  # disable automatic updates

# History configs
HIST_STAMPS="mm/dd/yyyy"
HISTFILE="$HOME/.zsh_history"    # Location of history file
HISTSIZE=10000000                # Size of history lines in memory
SAVEHIST=10000000                # Size of history file in lines
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git nice-exit-code fzf colored-man-pages docker aws \
         kubectl kube-ps1 helm pip pipenv ripgrep fzf-tab fast-syntax-highlighting)

# Finally:
source $ZSH/oh-my-zsh.sh


# ----------------------------------------
# User Configs
# ----------------------------------------

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if command -v nvim &> /dev/null; then
  export EDITOR='nvim'
else
  export EDITOR='vim'
fi

# add help for shell built-ins
autoload run-help
HELPDIR=/usr/share/zsh/"${ZSH_VERSION}"/help

# kube PS1 func
function get_cluster_short() {
  echo "$1" | cut -d @ -f2
}

KUBE_PS1_SYMBOL_ENABLE=false
KUBE_PS1_CLUSTER_FUNCTION=get_cluster_short

# Source other dotfiles if present
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.profile ] && source ~/.profile

# ENV exports
export HOMEBREW_CURLRC=1
export MOZ_ENABLE_WAYLAND=1
export FZF_DEFAULT_COMMAND='fd -t f -LIH -E .git --color=never'
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_ALT_C_COMMAND='fd -t d -LIH -E .git --color=never'
# export FZF_BASE=/opt/homebrew/opt/fzf

# LS Aliases
if command -v lsd &> /dev/null; then
  alias ls='lsd'
  alias l='ls -l'
  alias la='ls -a'
  alias lla='ls -la'
  alias lt='ls --tree'
fi

# Startup commands
kubeoff
enable-fzf-tab

# Enable broot
if command -v broot &> /dev/null; then
  source /home/lb/.config/broot/launcher/bash/br
fi
