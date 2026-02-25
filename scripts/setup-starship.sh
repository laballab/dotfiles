#!/usr/bin/env bash
# apply custom mods on top of
# plain-text-symbols preset

set -euo pipefail

rundir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$rundir/helpers/utils.sh"

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
config="$config_dir/starship.toml"

needs starship
needs sed
needs grep
needs awk

# detect OS for sed usage
if [[ "$OSTYPE" == darwin* ]]; then # bsd sed
  sed_edit() { sed -i '' "$@"; } # in place
  sed_append() { sed -i '' "/^$2\$/a\\
$3" "$1"; }
else # gnu sed
  sed_edit() { sed -i "$@"; } # in place
  sed_append() { sed -i "/^$2\$/a $3" "$1"; }
fi

has() { # check if key exists in section
  local section="$1" key="$2"
  awk -v section="$section" -v key="$key" '
    $0 ~ ("^\\[" section "\\][ \t]*$") { in_section = 1; next }
    in_section && /^\[/ { exit 1 }
    in_section && $0 ~ ("^" key " *= *") { found = 1; exit }
    END { exit !found }
  ' "$config"
}

upsert() { # upsert key in section
  local section="$1" key="$2" line="$3"
  if command grep -qE "^\[$section\][[:space:]]*$" "$config"; then # section exists
    if has "$section" "$key"; then # key exists
      line="${line//\\/\\\\}" # protect \
      line="${line//&/\\&}"   # protect &
      line="${line//|/\\|}"   # protect |
      sed_edit "/^\[$section\][[:space:]]*$/,/^\[/{s|^$key *= *.*|$line|;}" "$config"
    else # insert key if it doesn't exist
      line="${line//\\/\\\\}" # protect \
      sed_append "$config" "\[$section\]" "$line"
    fi # if section not found,
  else # append new section
    printf "\n[%s]\n%s\n" "$section" "$line" >> "$config"
  fi
}

# base preset
mkdir -p "$config_dir"
{ printf '%s\n\n' 'add_newline = false'
  starship preset plain-text-symbols
} > "$config"

# prompt: git branch + repo status
# branch segment
upsert git_branch symbol 'symbol = ""'
upsert git_branch style 'style = "purple"'
upsert git_branch format 'format = "[\\(](bold white)[$branch]($style)[\\)](bold white)"'
upsert git_branch truncation_length 'truncation_length = 21'
upsert git_branch truncation_symbol 'truncation_symbol = ""'

# repo status segment
upsert git_status format 'format = "([$all_status$ahead_behind]($style) )"'
upsert git_status style 'style = "bold white"'
upsert git_status ahead 'ahead = "[!>](bold green)"'
upsert git_status staged 'staged = "[+](green)"'
upsert git_status deleted 'deleted = "[*](red)"'
upsert git_status renamed 'renamed = "[>](bold purple)"'
upsert git_status modified 'modified = "[!](bold yellow)"'
upsert git_status untracked 'untracked = "[?](cyan)"'
upsert git_status behind 'behind = "[!<](bold purple)"'
upsert git_status diverged 'diverged = "[<>](bold red)"'
upsert git_status conflicted 'conflicted = "[!<](bold red)"'

# prompt character
upsert character success_symbol 'success_symbol = "[>](white) [\\$](green)"'
upsert character error_symbol 'error_symbol = "[\\$](white)"'

# prompt: identity (user@host)
# username
upsert username show_always 'show_always = true'
upsert username style_user 'style_user = "yellow"'
upsert username style_root 'style_root = "red"'
upsert username format 'format = "[$user]($style)[@](bold white)"'

# hostname
upsert hostname ssh_only 'ssh_only = false'
upsert hostname style 'style = "bold yellow"'
upsert hostname format 'format = "[$hostname]($style)[:/](bold white)"'

# prompt: command status + path
# non-zero command status
upsert status disabled 'disabled = false'
upsert status style 'style = "bold red"'
upsert status format 'format = "[$status]($style)[ ](white)"'

# duration
upsert cmd_duration disabled 'disabled = true'

# directory and read-only marker
upsert directory read_only 'read_only = "//ro"'
upsert directory read_only_style 'read_only_style = "bold red"'
upsert directory format 'format = "[$path]($style)([$read_only]($read_only_style))"'
upsert directory style 'style = "cyan"'

# version fmt
version_fmt='version_format = "~${major}.${minor}"'
for section in python package nodejs rust golang lua c cpp ruby java kotlin swift zig terraform; do
  upsert "$section" version_format "$version_fmt"
done

# language/tool symbols
upsert package symbol 'symbol = "pkg"'
upsert python symbol 'symbol = "py"'
upsert nodejs symbol 'symbol = "js"'
upsert rust symbol 'symbol = "rs"'
upsert golang symbol 'symbol = "go"'
upsert lua symbol 'symbol = "lua"'
upsert c symbol 'symbol = "c"'
upsert cpp symbol 'symbol = "cpp"'
upsert ruby symbol 'symbol = "rb"'
upsert java symbol 'symbol = "java"'
upsert kotlin symbol 'symbol = "ktln"'
upsert swift symbol 'symbol = "sw"'
upsert zig symbol 'symbol = "zig"'
upsert terraform symbol 'symbol = "tf"'
upsert kubernetes symbol 'symbol = "k8s"'
upsert helm symbol 'symbol = "helm"'
upsert docker_context symbol 'symbol = "dckr"'

# language fmt
lang_fmt='format = "[$symbol($version )]($style)"'
for section in package python nodejs rust golang lua c cpp ruby java kotlin swift zig terraform; do
  upsert "$section" format "$lang_fmt"
done

# disable noisy/slow modules
for section in terraform nodejs aws python; do
  upsert "$section" disabled 'disabled = true'
done
