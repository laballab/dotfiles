#!/usr/bin/env bash

# =========================
#  bootstrap-mac.sh
# =========================

set -euo pipefail
rundir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
basedir=$(cd "$rundir/.." && pwd)

# load libs
source "$rundir/helpers/slog.sh"

# setup homebrew
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  log_info "homebrew already installed; skipping"
else
  log_info "installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  log_success "homebrew installed"
fi

brew_packages=(
  zsh                        # shell
  zoxide                     # smart cd
  starship                   # prompt
  fzf                        # fuzzy finder
  fd                         # fast find
  ripgrep                    # fast grep
  lsd                        # fast ls
  yazi                       # fast files
  bat                        # cat with wings
  btop                       # system monitor
  bottom                     # system monitor
  tmux                       # terminal multiplexer
  reattach-to-user-namespace # tmux clipboard
  neovim                     # vim 4 life
  git                        # commit
  jq                         # json query
  yq                         # yaml query
  nmap                       # network toys (ncat)
  bind                       # dns toys (dig)
  tldr                       # man pages
  uv                         # python
  just                       # just do it
  fastfetch                  # system info
  gh                         # cli > website
  lazygit                    # tui > cli (sometimes)
  ffmpeg                     # video/audio processing
  p7zip                      # 7zip archive support
  poppler                    # PDF rendering
  resvg                      # SVG rendering
  imagemagick                # image manipulation
)

log_info "installing brew packages..."
brew install "${brew_packages[@]}"
log_success "brew packages installed"

# language servers
language_server_packages=(
  lua-language-server        # lua
  bash-language-server       # bash
  yaml-language-server       # yaml
  pyright                    # python
  marksman                   # markdown
  gopls                      # golang
  llvm                       # c/c++ (clangd)
  rust-analyzer              # rust
  typescript-language-server # ts/js
  typescript                 # tsserver
)

log_info "installing language servers..."
brew install "${language_server_packages[@]}"
log_success "language servers installed"

# install cask packages (skip already-installed apps)
cask_packages=(
  font-symbols-only-nerd-font  # nerd glyphs
  visual-studio-code           # heavyweight editor
  obsidian                     # md knowledge base
)

log_info "installing cask packages..."
for cask in "${cask_packages[@]}"; do
  if brew list --cask "$cask" &>/dev/null; then
    log_info "$cask already installed; skipping"
  else
    brew install --cask "$cask" || log_warning "failed to install $cask (may already exist)"
  fi
done
log_success "cask packages installed"

# install antidote (zsh plugin manager)
if [ ! -d "${ZDOTDIR:-$HOME}/.antidote" ]; then
  log_info "installing antidote..."
  git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote
  log_success "antidote installed"
fi

# setup starship prompt
log_info "setting up starship..."
"$rundir/setup-starship.sh"
log_success "starship configured"

# install zsh plugins
cat <<EOF > ~/.zsh_plugins
Aloxaf/fzf-tab
zsh-users/zsh-autosuggestions
zsh-users/zsh-history-substring-search
MichaelAquilina/zsh-you-should-use
zdharma-continuum/fast-syntax-highlighting
EOF

# setup shell configs
log_info "setting up shell configs..."
cp "$basedir/dots/.bashrc" ~/.bashrc
cp "$basedir/dots/.zshrc" ~/.zshrc

# setup lsd config
log_info "setting up lsd config..."
bash "$rundir/setup-lsd.sh"
log_success "lsd configured"

# setup codex CLI config
log_info "setting up codex CLI config..."
mkdir -p ~/.codex
cp "$basedir/dots/codex/config.toml" ~/.codex/config.toml
log_success "codex CLI config installed"

# setup vim
log_info "setting up vim..."
cp "$basedir/dots/.vimrc" ~/.vimrc
mkdir -p ~/.config
cp -r "$basedir/dots/nvim" ~/.config/

# setup tmux
log_info "setting up tmux..."
cp "$basedir/dots/.tmux.conf" ~/.tmux.conf
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# setup yazi
log_info "setting up yazi..."
"$rundir/setup-yazi.sh"
log_success "yazi configured"

# setup git
log_info "setting up git..."
git_email=$(git config --global user.email || true)
if [ -n "$git_email" ]; then
  log_info "git user already set; skipping"
else
  read -p "GitHub username: " ghusr
  git config --global user.name "$ghusr"
  git config --global user.email "$ghusr@users.noreply.github.com"
fi
git config --global push.autoSetupRemote true

log_success "bootstrap complete!"
