#!/usr/bin/env bash
#
# Helper functions for tmux-cinnamon-notify
#

get_tmux_option() {
    local option="$1"
    local default_value="${2:-}"
    local option_value
    option_value=$(tmux show-option -gqv "$option")
    if [[ -z "$option_value" ]]; then
        echo "$default_value"
    else
        echo "$option_value"
    fi
}

set_tmux_option() {
    local option="$1"
    local value="$2"
    tmux set-option -gq "$option" "$value"
}

# Cache helper for expensive operations
# Usage: cached_command <cache_key> <ttl_seconds> <command>
cached_command() {
    local cache_key="$1"
    local ttl="$2"
    shift 2
    local command="$*"

    local cache_dir="${TMPDIR:-/tmp}/tmux-cinnamon-notify"
    local cache_file="$cache_dir/$cache_key"

    mkdir -p "$cache_dir"

    if [[ -f "$cache_file" ]]; then
        local file_age
        file_age=$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null)))
        if [[ "$file_age" -lt "$ttl" ]]; then
            cat "$cache_file"
            return 0
        fi
    fi

    local result
    result=$(eval "$command")
    echo "$result" > "$cache_file"
    echo "$result"
}

# Get OS type
get_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "macos" ;;
        *)       echo "unknown" ;;
    esac
}

# Evaluate JavaScript in Cinnamon via D-Bus
# Returns the result string from Cinnamon's org.Cinnamon.Eval method
cinnamon_eval() {
    local script="$1"
    local result
    result=$(dbus-send --session --print-reply --dest=org.Cinnamon \
        /org/Cinnamon org.Cinnamon.Eval string:"$script" 2>/dev/null | \
        grep 'string "' | tail -1)
    # D-Bus returns: string ""value"" - extract content between doubled quotes
    # For numbers: string "4" - just one set of quotes
    # For strings: string ""text"" - doubled quotes
    result="${result#*string \"}"  # Remove prefix up to first quote
    result="${result%\"}"          # Remove trailing quote
    result="${result#\"}"          # Remove leading quote if doubled
    result="${result%\"}"          # Remove trailing quote if doubled
    echo "$result"
}
