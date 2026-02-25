#!/usr/bin/env bash

set -euo pipefail

rundir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
basedir=$(cd "$rundir/.." && pwd)

source "$rundir/helpers/slog.sh"

usage() {
  cat <<EOF
usage: $0 <arch|mac> [--output <dir>]
Packages the bootstrap files for the selected target into a tarball.
- arch: bundle the Arch Linux bootstrap script
- mac:  bundle the macOS bootstrap script
Default output directory: $basedir/dist
EOF
}

target=""
output_dir="$basedir/dist"

while [[ $# -gt 0 ]]; do
  case "$1" in
    arch|mac)
      target="$1"
      shift
      ;;
    -o|--output)
      if [[ $# -lt 2 ]]; then
        log_error "missing output directory after $1"
        usage
        exit 1
      fi
      output_dir="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      log_error "unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$target" ]]; then
  usage
  exit 1
fi

mkdir -p "$output_dir"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

log_info "building bootstrap package for $target..."

common_paths=(
  dots
)

target_paths=()
case "$target" in
  arch)
    target_paths+=(services)
    ;;
  mac)
    target_paths+=(themes)
    ;;
esac

for path in "${common_paths[@]}" "${target_paths[@]}"; do
  if [[ -e "$basedir/$path" ]]
    then cp -a "$basedir/$path" "$tmpdir/"
    else log_warning "skipping missing path: $path"
  fi
done

mkdir -p "$tmpdir/scripts"
cp -a "$basedir/scripts/helpers" "$tmpdir/scripts/"

shared_scripts=(
  setup-starship.sh
  setup-yazi.sh
)

for script in "${shared_scripts[@]}"; do
  src="$basedir/scripts/$script"
  if [[ -e "$src" ]]
    then cp -a "$src" "$tmpdir/scripts/"
    else log_warning "skipping missing script: $script"
  fi
done

case "$target" in
  arch)
    bootstrap_src="$basedir/scripts/bootstrap-arch.sh"
    ;;
  mac)
    bootstrap_src="$basedir/scripts/bootstrap-mac.sh"
    ;;
esac

if [[ ! -f "$bootstrap_src" ]]; then
  log_error "bootstrap script not found for target: $target"
  exit 1
fi

cp -a "$bootstrap_src" "$tmpdir/scripts/bootstrap.sh"
log_info "selected $(basename "$bootstrap_src") as scripts/bootstrap.sh"

if [[ -f "$basedir/README.md" ]]; then
  cp "$basedir/README.md" "$tmpdir/README.md"
fi

chmod +x "$tmpdir/scripts/"*.sh

tarball="$output_dir/bootstrap-$target.tar.gz"
tar -C "$tmpdir" -czf "$tarball" .

log_success "package created at $tarball"
