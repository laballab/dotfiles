#!/usr/bin/env bash

# =========================
#  generate-theme.sh
# =========================
# generates macOS Terminal.app theme files from hex color definitions
# usage: ./generate-theme.sh <theme-name>
#        ./generate-theme.sh --list
#
# theme definitions are sourced from themes/<name>.sh

set -euo pipefail
rundir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
basedir=$(cd "$rundir/.." && pwd)

# load libs
source "$rundir/helpers/slog.sh"

# ------------------------------
#  font settings (shared)
# ------------------------------
# SF Mono Regular 14pt — NSKeyedArchiver data
FONT_DATA='	YnBsaXN0MDDUAQIDBAUGBwpYJHZlcnNpb25ZJGFyY2hpdmVyVCR0b3BYJG9iamVjdHMS
	AAGGoF8QD05TS2V5ZWRBcmNoaXZlctEICVRyb290gAGkCwwVFlUkbnVsbNQNDg8QERIT
	FFZOU1NpemVYTlNmRmxhZ3NWTlNOYW1lViRjbGFzcyNALAAAAAAAABAQgAKAA15TRk1v
	bm8tUmVndWxhctIXGBkaWiRjbGFzc25hbWVYJGNsYXNzZXNWTlNGb250ohkbWE5TT2Jq
	ZWN0CBEaJCkyN0lMUVNYXmdud36FjpCSlKOos7zDxgAAAAAAAAEBAAAAAAAAABwAAAAA
	AAAAAAAAAAAAAADP
	'

# ------------------------------
#  hex -> NSColor data converter
# ------------------------------
hex_to_nscolor_data() {
  local hex="${1#\#}"
  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))

  osascript -e "
    use framework \"AppKit\"
    set c to current application's NSColor's colorWithSRGBRed:($r/255) green:($g/255) blue:($b/255) alpha:1.0
    set d to current application's NSKeyedArchiver's archivedDataWithRootObject:c requiringSecureCoding:false |error|:(missing value)
    return (d's base64EncodedStringWithOptions:0) as text
  "
}

# ------------------------------
#  generate .terminal plist
# ------------------------------
generate_terminal_theme() {
  local theme_name="$1"
  local output_file="$basedir/themes/${theme_name}.terminal"

  log_info "generating '$theme_name' theme from hex colors..."

  # convert all colors
  local ansi_black=$(hex_to_nscolor_data "$COLOR_BLACK")
  local ansi_red=$(hex_to_nscolor_data "$COLOR_RED")
  local ansi_green=$(hex_to_nscolor_data "$COLOR_GREEN")
  local ansi_yellow=$(hex_to_nscolor_data "$COLOR_YELLOW")
  local ansi_blue=$(hex_to_nscolor_data "$COLOR_BLUE")
  local ansi_magenta=$(hex_to_nscolor_data "$COLOR_MAGENTA")
  local ansi_cyan=$(hex_to_nscolor_data "$COLOR_CYAN")
  local ansi_white=$(hex_to_nscolor_data "$COLOR_WHITE")

  local ansi_bright_black=$(hex_to_nscolor_data "$COLOR_BRIGHT_BLACK")
  local ansi_bright_red=$(hex_to_nscolor_data "$COLOR_BRIGHT_RED")
  local ansi_bright_green=$(hex_to_nscolor_data "$COLOR_BRIGHT_GREEN")
  local ansi_bright_yellow=$(hex_to_nscolor_data "$COLOR_BRIGHT_YELLOW")
  local ansi_bright_blue=$(hex_to_nscolor_data "$COLOR_BRIGHT_BLUE")
  local ansi_bright_magenta=$(hex_to_nscolor_data "$COLOR_BRIGHT_MAGENTA")
  local ansi_bright_cyan=$(hex_to_nscolor_data "$COLOR_BRIGHT_CYAN")
  local ansi_bright_white=$(hex_to_nscolor_data "$COLOR_BRIGHT_WHITE")

  local text_color=$(hex_to_nscolor_data "$COLOR_TEXT")
  local bold_text_color=$(hex_to_nscolor_data "$COLOR_BOLD_TEXT")
  local cursor_color=$(hex_to_nscolor_data "$COLOR_CURSOR")
  local selection_color=$(hex_to_nscolor_data "$COLOR_SELECTION")

  cat > "$output_file" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>ANSIBlackColor</key>
	<data>$ansi_black</data>
	<key>ANSIBlueColor</key>
	<data>$ansi_blue</data>
	<key>ANSIBrightBlackColor</key>
	<data>$ansi_bright_black</data>
	<key>ANSIBrightBlueColor</key>
	<data>$ansi_bright_blue</data>
	<key>ANSIBrightCyanColor</key>
	<data>$ansi_bright_cyan</data>
	<key>ANSIBrightGreenColor</key>
	<data>$ansi_bright_green</data>
	<key>ANSIBrightMagentaColor</key>
	<data>$ansi_bright_magenta</data>
	<key>ANSIBrightRedColor</key>
	<data>$ansi_bright_red</data>
	<key>ANSIBrightWhiteColor</key>
	<data>$ansi_bright_white</data>
	<key>ANSIBrightYellowColor</key>
	<data>$ansi_bright_yellow</data>
	<key>ANSICyanColor</key>
	<data>$ansi_cyan</data>
	<key>ANSIGreenColor</key>
	<data>$ansi_green</data>
	<key>ANSIMagentaColor</key>
	<data>$ansi_magenta</data>
	<key>ANSIRedColor</key>
	<data>$ansi_red</data>
	<key>ANSIWhiteColor</key>
	<data>$ansi_white</data>
	<key>ANSIYellowColor</key>
	<data>$ansi_yellow</data>
	<key>AutoMarkPromptLines</key>
	<false/>
	<key>CursorBlink</key>
	<true/>
	<key>CursorColor</key>
	<data>$cursor_color</data>
	<key>EnableSmoothResizing</key>
	<true/>
	<key>Font</key>
	<data>
$FONT_DATA
	</data>
	<key>FontAntialias</key>
	<true/>
	<key>FontWidthSpacing</key>
	<real>1.004032258064516</real>
	<key>ProfileCurrentVersion</key>
	<real>2.0899999999999999</real>
	<key>SelectionColor</key>
	<data>$selection_color</data>
	<key>ShowActiveProcessArgumentsInTitle</key>
	<false/>
	<key>ShowDimensionsInTitle</key>
	<false/>
	<key>TextBoldColor</key>
	<data>$bold_text_color</data>
	<key>TextColor</key>
	<data>$text_color</data>
	<key>name</key>
	<string>$theme_name</string>
	<key>type</key>
	<string>Window Settings</string>
</dict>
</plist>
EOF

  log_success "theme file generated: $output_file"
}

# ------------------------------
#  list available themes
# ------------------------------
list_themes() {
  echo "available themes:"
  for f in "$basedir/themes/"*.sh; do
    if [ -f "$f" ]; then
      local name=$(basename "$f" .sh)
      echo "  - $name"
    fi
  done
}

# ------------------------------
#  main
# ------------------------------
if [ $# -lt 1 ]; then
  echo "usage: $0 <theme-name>"
  echo "       $0 --list"
  exit 1
fi

if [ "$1" = "--list" ]; then
  list_themes
  exit 0
fi

theme_name="$1"
theme_file="$basedir/themes/${theme_name}.sh"

if [ ! -f "$theme_file" ]; then
  log_error "theme '$theme_name' not found at $theme_file"
  list_themes
  exit 1
fi

# source the theme colors
source "$theme_file"

# generate the .terminal file
generate_terminal_theme "$theme_name"
