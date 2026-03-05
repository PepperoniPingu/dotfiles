#!/usr/bin/env bash
# chezmoi run_onchange script — re-runs whenever this file changes

set -euo pipefail

if ! command -v dconf &>/dev/null; then
    echo "dconf not found, skipping" >&2
    exit 0
fi

dconf_write() {
    local key="$1"
    local value="$2"
    dconf write "$key" "$value"
}

# ---------------------------------------------------------------------------
# Top bar
# ---------------------------------------------------------------------------
dconf_write /org/gnome/desktop/interface/show-battery-percentage "true"
dconf_write /org/gnome/desktop/interface/clock-show-seconds "true"
dconf_write /org/gnome/desktop/interface/clock-format "'24h'"
dconf_write /org/gnome/desktop/calendar/show-weekdate "true"

# ---------------------------------------------------------------------------
# Input sources
# ---------------------------------------------------------------------------
dconf_write /org/gnome/desktop/input-sources/sources \
    "[('xkb', 'se'), ('xkb', 'us')]"
dconf_write /org/gnome/desktop/input-sources/show-all-sources "true"

# ---------------------------------------------------------------------------
# Keybindings
# ---------------------------------------------------------------------------
dconf_write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings \
    "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"
dconf_write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name "'kitty'"
dconf_write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'kitty'"
dconf_write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding "'<Primary><Alt>t'"
dconf_write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/name "'firefox'"
dconf_write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/command "'firefox'"
dconf_write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/binding "'<Primary><Alt>f'"
dconf_write /org/gnome/desktop/wm/keybindings/switch-input-source "['<Alt>space']"
dconf_write /org/gnome/desktop/wm/keybindings/switch-input-source-backward "['<Shift><Alt>space']"
dconf_write /org/gnome/desktop/wm/keybindings/activate-window-menu "@as []"
dconf_write /org/gnome/desktop/wm/keybindings/close "['<Primary><Shift>w']"

# ---------------------------------------------------------------------------
# Extensions
# ---------------------------------------------------------------------------
gnome-extensions enable places-menu@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable launch-new-instance@gnome-shell-extensions.gcampax.github.com

# ---------------------------------------------------------------------------
# Dash to Dock
# ---------------------------------------------------------------------------
dconf_write /org/gnome/shell/extensions/dash-to-dock/dock-position "'LEFT'"
dconf_write /org/gnome/shell/extensions/dash-to-dock/click-action "'launch'"
dconf_write /org/gnome/shell/extensions/dash-to-dock/autohide "true"
dconf_write /org/gnome/shell/extensions/dash-to-dock/autohide-in-fullscreen "false"
dconf_write /org/gnome/shell/extensions/dash-to-dock/require-pressure-to-show "true"
dconf_write /org/gnome/shell/extensions/dash-to-dock/custom-background-color "false"
dconf_write /org/gnome/shell/extensions/dash-to-dock/transparency-mode "'FIXED'"
dconf_write /org/gnome/shell/extensions/dash-to-dock/background-opacity "0.4"
dconf_write /org/gnome/shell/extensions/dash-to-dock/show-trash "false"
dconf_write /org/gnome/shell/extensions/dash-to-dock/multi-monitor "true"
dconf_write /org/gnome/shell/extensions/dash-to-dock/intellihide "false"
dconf_write /org/gnome/shell/extensions/dash-to-dock/show-dock-urgent-notify "false"

# ---------------------------------------------------------------------------
# App / window switcher
# ---------------------------------------------------------------------------
dconf_write /org/gnome/shell/app-switcher/current-workspace-only "true"
dconf_write /org/gnome/shell/window-switcher/current-workspace-only "true"

# ---------------------------------------------------------------------------
# Touchpad
# ---------------------------------------------------------------------------
dconf_write /org/gnome/desktop/peripherals/touchpad/natural-scroll "false"
