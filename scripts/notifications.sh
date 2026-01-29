#!/usr/bin/env bash
#
# Cinnamon notification widget
# Displays last notification title with catppuccin-style formatting
#

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/../lib/helpers.sh"

get_notification() {
    local os
    os=$(get_os)

    # Only works on Linux with Cinnamon desktop
    if [[ "$os" != "linux" ]]; then
        echo ""
        return
    fi

    # Check if Cinnamon is running
    if ! pgrep -x "cinnamon" >/dev/null 2>&1; then
        echo ""
        return
    fi

    # Get configurable options (catppuccin mocha colors as defaults)
    local icon icon_bg icon_fg text_bg text_fg max_length
    icon=$(get_tmux_option "@cinnamon_notify_icon" "󰂚")
    icon_bg=$(get_tmux_option "@cinnamon_notify_icon_bg" "#f9e2af")
    icon_fg=$(get_tmux_option "@cinnamon_notify_icon_fg" "#11111b")
    text_bg=$(get_tmux_option "@cinnamon_notify_text_bg" "#313244")
    text_fg=$(get_tmux_option "@cinnamon_notify_text_fg" "#cdd6f4")
    max_length=$(get_tmux_option "@cinnamon_notify_max_length" "30")

    # Query the last notification title from CinnamonNotificationsApplet
    local last_title
    last_title=$(cinnamon_eval '
let applet = Main.panel._rightBox.get_children().find(c =>
  c._delegate && c._delegate.constructor.name === "CinnamonNotificationsApplet"
);
if (applet && applet._delegate && applet._delegate.notifications && applet._delegate.notifications.length > 0) {
  let notifs = applet._delegate.notifications;
  notifs[notifs.length - 1].title || "";
} else {
  "";
}
')

    # Return empty if no notifications
    if [[ -z "$last_title" ]]; then
        echo ""
        return
    fi

    # Truncate title if too long
    if [[ ${#last_title} -gt $max_length ]]; then
        last_title="${last_title:0:$((max_length - 1))}…"
    fi

    # Get separators from catppuccin or use defaults
    local left_sep right_sep
    left_sep=$(get_tmux_option "@catppuccin_status_left_separator" $'\ue0b6')
    right_sep=$(get_tmux_option "@catppuccin_status_right_separator" $'\ue0b4')

    # Build the formatted output
    printf "#[fg=%s]%s" "$icon_bg" "$left_sep"
    printf "#[fg=%s,bg=%s]%s " "$icon_fg" "$icon_bg" "$icon"
    printf "#[fg=%s,bg=%s]" "$icon_bg" "$text_bg"
    printf "#[fg=%s,bg=%s] %s" "$text_fg" "$text_bg" "$last_title"
    printf "#[fg=%s]%s" "$text_bg" "$right_sep"
}

main() {
    cached_command "notifications" 2 get_notification
}

main
