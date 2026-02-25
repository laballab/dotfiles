#!/usr/bin/env bash

# =========================
#  example usage of libs
# =========================

set -e
libdir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# load libs
source "$libdir/slog.sh"
source "$libdir/selection.sh"

# ----- slog.sh examples -----

echo "=== logging examples ==="
echo

log_info "this is an info message"
log_success "this is a success message"
log_warning "this is a warning message"
log_error "this is an error message"
log_debug "this is a debug message (hidden by default)"

echo
echo "to show debug messages, set LOG_LEVEL_STDOUT=DEBUG"
echo "to log to a file, set LOG_PATH=/path/to/file.log"
echo

# ----- selection.sh examples -----

echo "=== selection examples ==="
echo

# single selection
echo "single selection:"
run_selection -t "choose a shell:" "bash" "zsh" "fish"
echo "you selected: $selection"
echo

# multi selection
echo "multi selection:"
run_selection -m -t "select packages to install:" "vim" "tmux" "git" "curl"
echo "you selected: ${selection[*]}"
echo

# selection with pre-checked items (use :1 suffix)
echo "multi selection with defaults:"
run_selection -m -t "select features:" "logging:1" "colors:1" "sounds:0"
echo "you selected: ${selection[*]}"
echo

# get index instead of name
echo "selection returning index:"
run_selection -i -t "pick one:" "first" "second" "third"
echo "you selected index: $selection"
