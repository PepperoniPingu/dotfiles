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

shell_version() {
    gnome-shell --version | awk '{print $3}' | cut -d. -f1
}

# Install an extension from extensions.gnome.org into ~/.local/share.
# No-op if it is already present system-wide or in the user directory.
ext_install() {
    local uuid="$1"
    if [[ -d "$HOME/.local/share/gnome-shell/extensions/$uuid" ]] ||
        [[ -d "/usr/share/gnome-shell/extensions/$uuid" ]]; then
        return 0
    fi

    local info url tmp
    if ! info=$(curl -fsSL \
        "https://extensions.gnome.org/extension-info/?uuid=${uuid}&shell_version=$(shell_version)"); then
        echo "warning: no build of $uuid for GNOME $(shell_version), skipping" >&2
        return 0
    fi

    url=$(printf '%s' "$info" |
        python3 -c 'import json,sys; print(json.load(sys.stdin)["download_url"])')

    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' RETURN

    if ! curl -fsSL "https://extensions.gnome.org${url}" -o "$tmp/ext.zip"; then
        echo "warning: failed to download $uuid, skipping" >&2
        return 0
    fi

    gnome-extensions install --force "$tmp/ext.zip"
    echo "installed $uuid"
}

# Enable an extension. If the running shell has not picked it up yet (normal on
# Wayland right after install), fall back to adding it to the enabled list so it
# activates on next login.
ext_enable() {
    local uuid="$1"
    if gnome-extensions enable "$uuid" 2>/dev/null; then
        return 0
    fi

    local current
    current=$(gsettings get org.gnome.shell enabled-extensions)
    [[ "$current" == *"'${uuid}'"* ]] && return 0

    if [[ "$current" == "@as []" || "$current" == "[]" ]]; then
        gsettings set org.gnome.shell enabled-extensions "['${uuid}']"
    else
        gsettings set org.gnome.shell enabled-extensions "${current%]}, '${uuid}']"
    fi
    echo "enabled $uuid (takes effect after logout)"
}

# ---------------------------------------------------------------------------
# Dark mode
# ---------------------------------------------------------------------------
dconf_write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
dconf_write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"

# ---------------------------------------------------------------------------
# Top bar
# ---------------------------------------------------------------------------
dconf_write /org/gnome/desktop/interface/show-battery-percentage "true"
dconf_write /org/gnome/desktop/interface/clock-show-seconds "true"
dconf_write /org/gnome/desktop/interface/clock-format "'24h'"
dconf_write /org/gnome/desktop/calendar/show-weekdate "true"
dconf_write /org/gnome/system/locale/region "'sv_SE.UTF-8'"

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
ext_enable places-menu@gnome-shell-extensions.gcampax.github.com
ext_enable launch-new-instance@gnome-shell-extensions.gcampax.github.com

ext_install dash-to-dock@micxgx.gmail.com
ext_enable dash-to-dock@micxgx.gmail.com

ext_install tilingshell@ferrarodomenico.com
ext_enable tilingshell@ferrarodomenico.com

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
