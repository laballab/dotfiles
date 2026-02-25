#!/usr/bin/env bash

# =========================
#  bootstrap-arch.sh
# =========================

set -euo pipefail
rundir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
basedir=$(cd "$rundir/.." && pwd)

# load libs
source "$rundir/helpers/slog.sh"

# configure pacman
log_info "configuring pacman..."
sudo sed -i '
  s/^#Color$/Color/
  s/^#VerbosePkgLists$/VerbosePkgLists/
  s/^#ParallelDownloads.*/ParallelDownloads = 7/
  /^ILoveCandy/d
  /^ParallelDownloads/a ILoveCandy
  /^#\[multilib\]/,/^#Include/ s/^#//
' /etc/pacman.conf
log_success "pacman configured"

pacman_packages=(
  zsh                    # shell
  zoxide                 # smart cd
  starship               # prompt
  fzf                    # fuzzy finder
  fd                     # fast find
  ripgrep                # fast grep
  lsd                    # fast ls
  yazi                   # fast files
  bat                    # cat with wings
  btop                   # system monitor
  bottom                 # system monitor
  tmux                   # terminal multiplexer
  neovim                 # vim 4 life
  git                    # commit
  base-devel             # basic dev
  jq                     # json query
  go-yq                  # yaml query
  nmap                   # network toys (ncat)
  bind                   # dns toys (dig)
  tldr                   # man pages
  uv                     # python
  just                   # just do it
  wl-clipboard           # wayland clipboard
  ttf-nerd-fonts-symbols # nerd glyphs
  fastfetch              # system info
  dconf                  # gnome config db
  util-linux-libs        # utils lib
  kmonad                 # keyboard layers
  github-cli             # cli > website
  lazygit                # tui > cli (sometimes)
  ffmpeg                 # video/audio processing
  7zip                   # 7zip archive support
  poppler                # PDF rendering
  resvg                  # SVG rendering
  imagemagick            # image manipulation
)

log_info "installing pacman packages..."
sudo pacman -S --needed "${pacman_packages[@]}"
log_success "pacman packages installed"

# language servers
language_server_packages=(
  lua-language-server        # lua
  bash-language-server       # bash
  yaml-language-server       # yaml
  pyright                    # python
  marksman                   # markdown
  gopls                      # golang
  clang                      # c/c++
  rust-analyzer              # rust
  typescript-language-server # ts/js
  typescript                 # tsserver
)

log_info "installing language servers..."
sudo pacman -S --needed "${language_server_packages[@]}"
log_success "language servers installed"

# install yay
if ! command -v yay >/dev/null 2>&1; then
  log_info "installing yay..."
  mkdir -p ~/repos
  git clone https://aur.archlinux.org/yay.git \
    ~/repos/yay 2>/dev/null || true
  (cd ~/repos/yay && makepkg -si)
  log_success "yay installed"
fi

# install AUR packages
yay_packages=(
  zsh-antidote           # zsh plugins
  pfetch                 # system info
  gnome-shell-extension-tiling-assistant # fix gnome tiling
)

log_info "installing AUR packages..."
yay -S --needed "${yay_packages[@]}"
log_success "packages installed"

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

# setup kmonad
log_info "setting up kmonad..."
sudo mkdir -p /opt/kmonad/
sudo cp "$basedir/services/config.kbd" /opt/kmonad/config.kbd
sudo cp "$basedir/services/kbd.service" /etc/systemd/system/kbd.service
sudo systemctl daemon-reload && sudo systemctl enable --now kbd.service
log_success "kmonad configured"

# fix gnome login-keyring
mkdir -p ~/.local/share/keyrings
sudo chown -R $USER:$USER ~/.local/share/keyrings
chmod 700 ~/.local/share/keyrings
shopt -s nullglob
keyrings=(~/.local/share/keyrings/*.keyring)
if [ "${#keyrings[@]}" -gt 0 ]; then
  chmod 600 "${keyrings[@]}"
fi
shopt -u nullglob

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
