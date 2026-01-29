#!/usr/bin/env bash
#
# tmux-cinnamon-notify - Cinnamon desktop notification widget for tmux
# https://github.com/odtgit/tmux-cinnamon-notify
#

# Get the directory where this script is located
# Handle both direct execution and tmux's run command
if [[ -n "${BASH_SOURCE[0]}" ]]; then
    CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    CURRENT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

source "$CURRENT_DIR/lib/helpers.sh"

do_interpolation() {
    local string="$1"
    # Use sed for replacement to handle # characters correctly
    string=$(echo "$string" | sed "s|#{cinnamon_notification}|#($CURRENT_DIR/scripts/notifications.sh)|g")
    echo "$string"
}

update_tmux_option() {
    local option="$1"
    local option_value
    option_value="$(get_tmux_option "$option")"
    local new_value
    new_value="$(do_interpolation "$option_value")"
    set_tmux_option "$option" "$new_value"
}

main() {
    update_tmux_option "status-left"
    update_tmux_option "status-right"
}

main
