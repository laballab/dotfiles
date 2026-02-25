#!/usr/bin/env bash

# =========================
#  test-fonts.sh
# =========================
# tests nerd font glyph rendering across all patched icon sets

set -euo pipefail

# colors
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

header() {
  printf "\n%s%s═══ %s ═══%s\n" "$BOLD" "$CYAN" "$1" "$RESET"
}

# ─────────────────────────────────────────────────────────────
header "POWERLINE"
echo "  arrows:          "
echo "  rounded:         "
echo "  flames:          "
echo "  pixelated:       "
echo "  trapezoid:     "

# ─────────────────────────────────────────────────────────────
header "POWERLINE EXTRA"
echo "  half-circle:     "
echo "  slant:           "
echo "  ice:                "
echo "  honeycomb:      "
echo "  lego:            "
echo "  blocks:           "

# ─────────────────────────────────────────────────────────────
header "FONT AWESOME — files & folders"
echo "  files:               "
echo "  more files:          "
echo "  folders:         "

# ─────────────────────────────────────────────────────────────
header "FONT AWESOME — ui & actions"
echo "  check/x:             "
echo "  plus/minus:        "
echo "  arrows:             "
echo "  more arrows:         "
echo "  icons:               "
echo "  ui:                  "
echo "  edit:                "
echo "  info:                "

# ─────────────────────────────────────────────────────────────
header "FONT AWESOME — brands & logos"
echo "  git:              "
echo "  social:              "
echo "  os:                  "
echo "  coding:              "
echo "  cloud:               "

# ─────────────────────────────────────────────────────────────
header "FONT AWESOME — media & misc"
echo "  media:               "
echo "  more media:          "
echo "  comm:                "
echo "  misc:                "
echo "  objects:             "
echo "  shapes:              "

# ─────────────────────────────────────────────────────────────
header "FONT AWESOME EXTENSION"
echo "  misc:           "

# ─────────────────────────────────────────────────────────────
header "OCTICONS — git"
echo "  git:                 "
echo "  more git:            "
echo "  branches:            "

# ─────────────────────────────────────────────────────────────
header "OCTICONS — files & ui"
echo "  files:               "
echo "  more files:          "
echo "  ui:                  "
echo "  more ui:             "
echo "  symbols:             "
echo "  actions:             "
echo "  more:                "

# ─────────────────────────────────────────────────────────────
header "CODICONS — files & ui"
echo "  files:               "
echo "  more files:          "
echo "  folders:             "
echo "  ui:                  "
echo "  more ui:             "
echo "  arrows:              "

# ─────────────────────────────────────────────────────────────
header "CODICONS — dev & debug"
echo "  dev:                 "
echo "  more dev:            "
echo "  debug:               "
echo "  more debug:          "
echo "  git:                 "
echo "  symbols:             "

# ─────────────────────────────────────────────────────────────
header "FONT LOGOS — languages"
echo "  languages:           "
echo "  more langs:          "
echo "  scripting:           "
echo "  compiled:            "

# ─────────────────────────────────────────────────────────────
header "FONT LOGOS — platforms & tools"
echo "  web:                 "
echo "  platforms:           "
echo "  more plat:           "
echo "  tools:               "
echo "  more tools:          "
echo "  editors:             "
echo "  databases:           "
echo "  misc:                "

# ─────────────────────────────────────────────────────────────
header "POMICONS"
echo "  pomodoro:            "
echo "  misc:           "

# ─────────────────────────────────────────────────────────────
header "WEATHER — sun, moon, clouds"
echo "  sun:                 "
echo "  more sun:            "
echo "  clouds:              "
echo "  more clouds:         "

# ─────────────────────────────────────────────────────────────
header "WEATHER — conditions"
echo "  rain:                "
echo "  storm:               "
echo "  snow:                "
echo "  wind:                "
echo "  misc:                "

# ─────────────────────────────────────────────────────────────
header "WEATHER — moon phases & thermo"
echo "  moon phases:         "
echo "  more moon:           "
echo "  thermo:              "
echo "  time:                "
echo "  misc:                "

# ─────────────────────────────────────────────────────────────
header "SUMMARY"
printf "  %s✓%s if you see icons above, your font is patched correctly\n" "$GREEN" "$RESET"
printf "  %s□%s boxes or blanks indicate missing glyphs\n" "$RED" "$RESET"
echo ""
