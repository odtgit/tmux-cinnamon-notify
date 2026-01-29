# tmux-cinnamon-notify

A tmux plugin that displays Cinnamon desktop notifications in the status bar. Features catppuccin-style formatting.

## Requirements

- Linux with Cinnamon desktop environment
- tmux 2.1+
- bash 4.0+
- dbus-send (usually pre-installed)

## Installation

### Using TPM (recommended)

Add to your `~/.tmux.conf`:

```bash
set -g @plugin 'odtgit/tmux-cinnamon-notify'
```

Then press `prefix + I` to install.

### Manual

Clone the repository:

```bash
git clone https://github.com/odtgit/tmux-cinnamon-notify ~/.tmux/plugins/tmux-cinnamon-notify
```

Add to your `~/.tmux.conf`:

```bash
run-shell ~/.tmux/plugins/tmux-cinnamon-notify/cinnamon-notify.tmux
```

## Usage

Add the `#{cinnamon_notification}` placeholder to your status bar:

```bash
set -g status-right "#{cinnamon_notification}"
```

The widget displays the most recent notification from Cinnamon's notification applet.

## Configuration

All options use catppuccin mocha colors as defaults.

| Option | Default | Description |
|--------|---------|-------------|
| `@cinnamon_notify_icon` | 󰂚 | Icon displayed in the widget |
| `@cinnamon_notify_icon_bg` | #f9e2af | Icon background color |
| `@cinnamon_notify_icon_fg` | #11111b | Icon foreground color |
| `@cinnamon_notify_text_bg` | #313244 | Text background color |
| `@cinnamon_notify_text_fg` | #cdd6f4 | Text foreground color |
| `@cinnamon_notify_max_length` | 30 | Maximum length of notification text |

Example configuration:

```bash
set -g @cinnamon_notify_icon "🔔"
set -g @cinnamon_notify_max_length "25"
```

## How It Works

The plugin queries Cinnamon's internal state via D-Bus using `org.Cinnamon.Eval`. It executes JavaScript to read notification data from `Main.panel`'s `CinnamonNotificationsApplet`.

Results are cached for 2 seconds to minimize D-Bus overhead.

## License

MIT
