#!/usr/bin/env bash

# =========================
#  patch-sf-mono.sh
# =========================
# patches macOS sf-mono with nerd-font symbols
# retains original font names for in-place replacement

set -euo pipefail
rundir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
basedir=$(cd "$rundir/.." && pwd)

# load libs
source "$rundir/helpers/slog.sh"

# configuration
NERD_FONTS_REPO="https://github.com/ryanoasis/nerd-fonts.git"
WORK_DIR="$HOME/.cache/nerd-fonts-patcher"
OUTPUT_DIR="$HOME/Library/Fonts"
BACKUP_DIR="$HOME/.local/share/fonts-backup"

# font weights to patch (add more as needed)
FONT_WEIGHTS=(
  "Regular"
  "Bold"
)

# find sf-mono font directory
find_sf_mono_dir() {
  local paths=(
    "/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts"
    "/Applications/Utilities/Terminal.app/Contents/Resources/Fonts"
    "/Library/Fonts"
  )
  for path in "${paths[@]}"; do
    if [ -f "$path/SF-Mono-Regular.otf" ]; then
      echo "$path"
      return 0
    fi
  done
  return 1
}

# install fontforge if needed
if ! command -v fontforge &>/dev/null; then
  log_info "installing fontforge..."
  brew install fontforge
  log_success "fontforge installed"
else
  log_info "fontforge already installed; skipping"
fi

# locate sf-mono directory
log_info "locating sf-mono fonts..."
if SF_MONO_DIR=$(find_sf_mono_dir); then
  log_success "found sf-mono at: $SF_MONO_DIR"
else
  log_error "sf-mono not found in expected locations"
  exit 1
fi

# setup directories
mkdir -p "$BACKUP_DIR"
mkdir -p "$OUTPUT_DIR"

# clone nerd-fonts patcher (sparse checkout for speed)
if [ -d "$WORK_DIR" ]; then
  log_info "cleaning up previous work directory..."
  rm -rf "$WORK_DIR"
fi

log_info "cloning nerd-fonts patcher (sparse)..."
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

git clone --depth 1 --filter=blob:none --sparse "$NERD_FONTS_REPO" .
git sparse-checkout set --no-cone '/src/' '/bin/' font-patcher
log_success "nerd-fonts patcher ready"

# create fontforge rename script (reused for each weight)
RENAME_SCRIPT="$WORK_DIR/rename-font.py"
cat > "$RENAME_SCRIPT" << 'PYTHON'
import fontforge
import sys

font_path = sys.argv[1]
output_path = sys.argv[2]
weight = sys.argv[3]

font = fontforge.open(font_path)

# restore original SF Mono naming
font.familyname = "SF Mono"
font.fontname = f"SF-Mono-{weight}"
font.fullname = f"SF Mono {weight}"

# update naming table entries
font.sfnt_names = tuple(
  (lang, strid, "SF Mono" if "Nerd" in val else val)
  if strid == 1 else  # family name
  (lang, strid, f"SF Mono {weight}" if "Nerd" in val else val)
  if strid == 4 else  # full name
  (lang, strid, f"SF-Mono-{weight}" if "Nerd" in val else val)
  if strid == 6 else  # postscript name
  (lang, strid, val)
  for lang, strid, val in font.sfnt_names
)

font.generate(output_path)
font.close()
PYTHON

# patch each font weight
for weight in "${FONT_WEIGHTS[@]}"; do
  FONT_FILENAME="SF-Mono-${weight}.otf"
  SF_MONO_PATH="$SF_MONO_DIR/$FONT_FILENAME"

  if [ ! -f "$SF_MONO_PATH" ]; then
    log_warning "SF-Mono-${weight}.otf not found; skipping"
    continue
  fi

  log_info "processing $weight weight..."

  # backup existing font if present
  if [ -f "$OUTPUT_DIR/$FONT_FILENAME" ]; then
    BACKUP_FILE="$BACKUP_DIR/${FONT_FILENAME%.otf}-$(date +%Y%m%d-%H%M%S).otf"
    log_info "backing up existing $FONT_FILENAME"
    cp "$OUTPUT_DIR/$FONT_FILENAME" "$BACKUP_FILE"
  fi

  # create temp output for this weight
  TEMP_OUTPUT="$WORK_DIR/patched-${weight}"
  mkdir -p "$TEMP_OUTPUT"

  # patch the font
  log_info "patching SF-Mono-${weight} with nerd-font symbols..."
  log_info "this may take a few minutes..."

  fontforge -quiet -script font-patcher \
    --powerline \
    --powerlineextra \
    --fontawesome \
    --fontawesomeext \
    --octicons \
    --codicons \
    --fontlogos \
    --pomicons \
    --weather \
    --outputdir "$TEMP_OUTPUT" \
    "$SF_MONO_PATH"

  # find the patched font file
  PATCHED_FONT=$(find "$TEMP_OUTPUT" -name "*.otf" -o -name "*.ttf" | head -1)
  if [ -z "$PATCHED_FONT" ]; then
    log_error "patched font not found for $weight weight"
    continue
  fi

  # rename and install
  log_info "renaming $weight font to original SF Mono name..."
  fontforge -quiet -script "$RENAME_SCRIPT" "$PATCHED_FONT" "$OUTPUT_DIR/$FONT_FILENAME" "$weight"

  log_success "$FONT_FILENAME installed"
done

# cleanup
log_info "cleaning up work directory..."
rm -rf "$WORK_DIR"

log_success "done! restart your terminal to use the patched SF Mono"
log_info "backup location: $BACKUP_DIR"
