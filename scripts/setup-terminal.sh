#!/usr/bin/env bash

# =========================
#  setup-terminal.sh
# =========================
# configures macOS terminal.app with a custom theme
# uses generate-theme.sh for theme generation
#
# usage: ./setup-terminal.sh [theme-name]
#        defaults to 'base' if no theme specified

set -euo pipefail
rundir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
basedir=$(cd "$rundir/.." && pwd)

# load libs
source "$rundir/helpers/slog.sh"

# default theme
THEME_NAME="${1:-base}"
THEME_FILE="$basedir/themes/${THEME_NAME}.terminal"

# ------------------------------
#  generate theme if needed
# ------------------------------
generate_theme_if_needed() {
  if [ ! -f "$THEME_FILE" ]; then
    log_info "theme file not found, generating..."
    "$rundir/generate-theme.sh" "$THEME_NAME"
  else
    log_info "using existing theme file: $THEME_FILE"
  fi
}

# ------------------------------
#  install theme
# ------------------------------
install_theme() {
  local plist=~/Library/Preferences/com.apple.Terminal.plist

  # ensure plist exists
  if [ ! -f "$plist" ]; then
    log_info "creating terminal prefs..."
    defaults write com.apple.Terminal "Default Window Settings" -string "Basic"
  fi

  # flush preferences cache
  log_info "flushing preferences cache..."
  killall cfprefsd 2>/dev/null || true
  sleep 0.5
  
  # remove existing profile
  log_info "removing existing '$THEME_NAME' profile if present..."
  /usr/libexec/PlistBuddy -c "Delete :Window\ Settings:$THEME_NAME" "$plist" 2>/dev/null || true

  # import theme directly into plist using plistbuddy
  log_info "importing terminal theme '$THEME_NAME'..."
  
  # create the window settings dict if it doesn't exist
  /usr/libexec/PlistBuddy -c "Add :Window\ Settings dict" "$plist" 2>/dev/null || true
  
  # add the profile as a new dict
  /usr/libexec/PlistBuddy -c "Add :Window\ Settings:$THEME_NAME dict" "$plist"
  
  # merge the theme file contents into the new profile
  /usr/libexec/PlistBuddy -c "Merge '$THEME_FILE' :Window\ Settings:$THEME_NAME" "$plist"

  # set as default via defaults write
  log_info "setting '$THEME_NAME' as default terminal profile..."
  defaults write com.apple.Terminal "Default Window Settings" -string "$THEME_NAME"
  defaults write com.apple.Terminal "Startup Window Settings" -string "$THEME_NAME"

  # sync preferences
  killall cfprefsd 2>/dev/null || true

  # reload terminal preferences via applescript
  log_info "reloading terminal preferences..."
  osascript -e 'tell application "Terminal" to activate' 2>/dev/null || true
  sleep 0.5
  osascript -e "tell application \"Terminal\" to set default settings to settings set \"$THEME_NAME\"" 2>/dev/null || true
  osascript -e "tell application \"Terminal\" to set startup settings to settings set \"$THEME_NAME\"" 2>/dev/null || true

  log_success "terminal theme '$THEME_NAME' installed and set as default"
}

# ------------------------------
#  main
# ------------------------------
log_info "setting up terminal.app with '$THEME_NAME' theme..."
generate_theme_if_needed
install_theme
