#!/usr/bin/env bash

set -euo pipefail

rundir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
basedir=$(cd "$rundir/.." && pwd)

mkdir -p ~/.config/lsd
cp "$basedir/dots/lsd/config.yaml" ~/.config/lsd/config.yaml
cp "$basedir/dots/lsd/icons.yaml" ~/.config/lsd/icons.yaml
