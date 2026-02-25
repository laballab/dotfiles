#!/bin/sh
#--------------------------------------------------------------------------------------------------
# slog - Makes logging in POSIX shell scripting suck less
# Copyright (c) Fred Palmer
# POSIX version Copyright Joe Cooper
# Licensed under the MIT license
# http://github.com/swelljoe/slog
#--------------------------------------------------------------------------------------------------
set -e

# LOG_PATH - Define $LOG_PATH in your script to log to a file
# LOG_LEVEL_STDOUT - Define to determine above which level goes to STDOUT
LOG_LEVEL_STDOUT="${LOG_LEVEL_STDOUT:-INFO}"
# LOG_LEVEL_LOG - Define to determine which level goes to LOG_PATH
LOG_LEVEL_LOG="${LOG_LEVEL_LOG:-INFO}"

# Useful global variables
SCRIPT_ARGS="$@"
SCRIPT_NAME="$0"
SCRIPT_NAME="${SCRIPT_NAME#\./}"
SCRIPT_NAME="${SCRIPT_NAME##/*/}"

# Determines if we print colors or not
if tty -s 2>/dev/null; then
    readonly INTERACTIVE_MODE="on"
else
    readonly INTERACTIVE_MODE="off"
fi

#--------------------------------------------------------------------------------------------------
# Begin Logging Section
if [ "${INTERACTIVE_MODE}" = "on" ] && tput colors >/dev/null 2>&1; then
    LOG_DEFAULT_COLOR=$(tput sgr0)
    LOG_ERROR_COLOR=$(tput setaf 1)
    LOG_INFO_COLOR=$(tput sgr 0)
    LOG_SUCCESS_COLOR=$(tput setaf 2)
    LOG_WARN_COLOR=$(tput setaf 3)
    LOG_DEBUG_COLOR=$(tput setaf 4)
else
    LOG_DEFAULT_COLOR=""
    LOG_ERROR_COLOR=""
    LOG_INFO_COLOR=""
    LOG_SUCCESS_COLOR=""
    LOG_WARN_COLOR=""
    LOG_DEBUG_COLOR=""
fi

log() {
    local log_text="${1:-}"
    local log_level="${2:-INFO}"
    local log_color="${3:-$LOG_INFO_COLOR}"

    local LOG_LEVEL_DEBUG=0
    local LOG_LEVEL_INFO=1
    local LOG_LEVEL_SUCCESS=2
    local LOG_LEVEL_WARNING=3
    local LOG_LEVEL_ERROR=4

    case "$LOG_LEVEL_STDOUT" in
        DEBUG|INFO|SUCCESS|WARNING|ERROR) ;;
        *) LOG_LEVEL_STDOUT=INFO ;;
    esac
    case "$LOG_LEVEL_LOG" in
        DEBUG|INFO|SUCCESS|WARNING|ERROR) ;;
        *) LOG_LEVEL_LOG=INFO ;;
    esac

    local log_level_int log_level_stdout log_level_log
    eval log_level_int="\${LOG_LEVEL_${log_level}:-1}"
    eval log_level_stdout="\${LOG_LEVEL_${LOG_LEVEL_STDOUT}:-1}"
    if [ "$log_level_stdout" -le "$log_level_int" ]; then
        printf "%s[%s] %s %s\n" "$log_color" "$log_level" "$log_text" "$LOG_DEFAULT_COLOR"
    fi
    eval log_level_log="\${LOG_LEVEL_${LOG_LEVEL_LOG}:-1}"
    if [ "$log_level_log" -le "$log_level_int" ]; then
        if [ -n "${LOG_PATH:-}" ]; then
            printf "[%s] [%s] %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$log_level" "$log_text" >> "$LOG_PATH"
        fi
    fi

    return 0
}

log_info()      { log "$@"; }
log_success()   { log "${1:-}" "SUCCESS" "${LOG_SUCCESS_COLOR}"; }
log_error()     { log "${1:-}" "ERROR" "${LOG_ERROR_COLOR}"; }
log_warning()   { log "${1:-}" "WARNING" "${LOG_WARN_COLOR}"; }
log_debug()     { log "${1:-}" "DEBUG" "${LOG_DEBUG_COLOR}"; }
