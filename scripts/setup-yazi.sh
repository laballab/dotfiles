#!/usr/bin/env bash
# setup yazi file manager with
# plugins and custom config

set -euo pipefail

rundir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
basedir=$(cd "$rundir/.." && pwd)
source "$rundir/helpers/utils.sh"

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"

needs ya

# copy config files
mkdir -p "$config_dir"
cp -r "$basedir/dots/yazi" "$config_dir/"

# install plugins
ya pkg add yazi-rs/plugins:full-border || true
ya pkg add yazi-rs/plugins:smart-enter || true
ya pkg add yazi-rs/plugins:no-status || true
ya pkg add Rolv-Apneseth/starship || true
ya pkg add yazi-rs/plugins:git || true
ya pkg install || true
