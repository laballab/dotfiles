#!/bin/bash
#
# Create selections checkboxes in CLI
# https://github.com/rokobuljan/selection.sh
# Author: Roko C. Buljan
# License: MIT

set -euo pipefail

# PUBLIC
declare -a selection=()

# PRIVATE
declare -a _selection_items=()
declare -a _selection_active=()
declare -i _selection_tot=0
declare -i _selection_cursor=0
_isMultiple=false
_isOutputIndex=false

usage() {
    echo -e "Usage:
    source $0 [-m -a] [-i] [-t title] \"a_checked:1\" \"b_unchecked:0\" \"c_unchecked\" ...
Options:
    -m Multiple (checkboxes)
    -c Inverse checked default logic
    -i Output index instead of names
    -t Title
    -h Help
Examples:
    source $0 Yes No \"Maybe tomorrow\"
    source $0 -t \"Select one:\" \"Yes\" \"No\" \"Maybe\"
    source $0 -i -t \"Select one:\" \"Yes\" \"No\" \"Maybe\"
    source $0 -m -t \"Select multiple:\" \"Load:1\" \"Configure:0\" \"Reboot\"
    source $0 -i -m -t \"Select multiple:\" \"Load:1\" \"Configure:0\" \"Reboot\"
"
    exit 0
}

inArray() {
    local val
    for val in "${@:2}"; do [[ "$val" == "$1" ]] && return 0; done
    return 1
}

draw() {
    clear

    if [[ "$_isMultiple" == true ]]; then
        _selection_title="${_selection_title:-"Select the desired options:"}"
    else
        _selection_title="${_selection_title:-"Select an option:"}"
    fi

    local outNavInfo="Use "
    if [[ "$_selection_tot" -gt 0 ]]; then
        outNavInfo+="[Arrows] to navigate, "
    fi

    if [[ "$_isMultiple" == true ]]; then
        outNavInfo+="[Space] to toggle, "
    fi

    local out="$_selection_title\n($outNavInfo[Enter] to proceed)\n\n"

    local arrow="\e[32m›\e[0m"
    local ckbOn="\e[32m☑\e[0m"
    local ckbOff="☐"
    local -i i=0

    for (( i=0; i<$_selection_tot; i++ )); do
        if [[ "${i}" -eq "${_selection_cursor}" ]]; then
            out+="$arrow "
        else
            out+="  "
        fi

        if [[ "$_isMultiple" == true ]]; then
            if inArray "$i" "${_selection_active[@]}"; then
                out+="$ckbOn "
            else
                out+="$ckbOff "
            fi
        fi

        if [[ "${i}" -eq "${_selection_cursor}" ]]; then
            out+=" \e[32m${_selection_items[$i]}\e[0m\n"
        else
            out+=" ${_selection_items[$i]}\n"
        fi
    done

    echo -e "$out"
}

moveUp() {
    _selection_cursor=$((_selection_cursor - 1))
    if [[ "$_selection_cursor" -lt 0 ]]; then
        _selection_cursor=$((_selection_tot-1))
    fi
    draw
}

moveDown() {
    _selection_cursor=$((_selection_cursor + 1))
    if [[ "$_selection_cursor" -ge "$_selection_tot" ]]; then
        _selection_cursor=0
    fi
    draw
}

toggle() {
    if [[ "$_isMultiple" == true ]]; then
        if inArray "$_selection_cursor" "${_selection_active[@]}"; then
            local i=0
            for i in "${!_selection_active[@]}"; do
                if [[ "${_selection_active[i]}" == "$_selection_cursor" ]]; then
                    unset "_selection_active[i]"
                fi
            done
        else
            _selection_active+=($_selection_cursor)
        fi
        draw
    fi
}

selection_main() {
    local _isDefaultChecked=false
    while getopts ":hmcit:" opt; do
        case "$opt" in
            h) usage ;;
            m) _isMultiple=true ;;
            c) _isDefaultChecked=true ;;
            i) _isOutputIndex=true ;;
            t) _selection_title="$OPTARG" ;;
            \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
            :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
        esac
    done

    shift $((OPTIND-1))

    local -a args=("$@")
    local -i i=0

    for i in "${!args[@]}"; do
        arg="${args[$i]}"
        IFS=':' read -r name ckd <<<"$arg"

        local ckdDefault="0"
        if [[ "$_isDefaultChecked" == true ]]; then
            ckdDefault="1"
        fi

        local checked="${ckd:-$ckdDefault}"
        _selection_items+=("$name")
        [[ "$checked" -eq "1" ]] && _selection_active+=("$i")
    done

    _selection_tot="${#_selection_items[@]}"

    draw

    unset IFS
    unset OPTIND
}

selection_watchKeys() {
    while true; do
        read -rsN 1
        case "$REPLY" in
            $'\x1b')
                read -rsN 2
                case "$REPLY" in
                    '[A'|'[D') moveUp ;;
                    '[B'|'[C') moveDown ;;
                esac
                ;;
            $' ')
                [[ "$_isMultiple" == true ]] && toggle || { clear; break; }
                ;;
            $'\n')
                clear
                break
                ;;
        esac
    done
}

selection_output() {
    if [[ "$_isMultiple" == true ]]; then
        local -i idx
        for idx in "${!_selection_items[@]}"; do
            if inArray "$idx" "${_selection_active[@]}"; then
                if [[ "$_isOutputIndex" == true ]]; then
                    selection+=("$idx")
                else
                    selection+=("${_selection_items[$idx]}")
                fi
            fi
        done
    else
        if [[ "$_isOutputIndex" == true ]]; then
            selection="$_selection_cursor"
        else
            selection="${_selection_items[$_selection_cursor]}"
        fi
    fi
}

selection_cleanup() {
    unset _selection_title
    unset _selection_items
    unset _selection_active
    unset _selection_tot
    unset _selection_cursor
    unset _isMultiple
    unset _isOutputIndex
}

# Main function to run selection
run_selection() {
    selection=()
    _selection_items=()
    _selection_active=()
    _selection_tot=0
    _selection_cursor=0
    _isMultiple=false
    _isOutputIndex=false
    
    selection_main "$@"
    selection_watchKeys
    selection_output
    selection_cleanup
}
