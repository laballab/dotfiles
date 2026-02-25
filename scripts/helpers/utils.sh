#!/usr/bin/env bash
# utils.sh - common utility functions

# needs - check if a command exists
needs() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'error: missing required command: %s\n' "$1" >&2
    exit 1
  }
}
