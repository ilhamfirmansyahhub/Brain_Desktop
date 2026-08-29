# Brain Desktop

A modular Quickshell/QML desktop shell for Hyprland.

Brain Desktop is designed to sit alongside an existing Hyprland setup rather than replacing it. The installer deploys the shell to the current user, creates a user-level systemd service, and adds Brain's keybind include without overwriting the user's Hyprland configuration.

## Features

- Top desktop bar and dashboard UI
- Brain application launcher
- Dashboard, notifications, clipboard, audio, network, wallpaper and recording controls
- Click-outside / click-to-close popup behavior
- `Super+Space` Brain launcher shortcut
- `Alt+F9` screen-recording control
- Multi-monitor Quickshell support
- Portable per-user installation
- Automatic backups of an existing Brain Desktop config
- Curated application launcher filtering
- Fixed, self-contained configuration

## Installation

### Arch Linux / Arch-based distributions

Run the installer from a cloned repository:

```bash
git clone -b brain-desktop https://github.com/ilhamfirmansyahhub/Brain_Desktop.git
cd Brain_Desktop
chmod +x install.sh
./install.sh
```

The installer:

1. Checks for an Arch-based system and Hyprland.
2. Installs the runtime packages used by Brain Desktop.
3. Backs up an existing Brain Desktop configuration.
4. Installs the shell to `~/.config/quickshell/brain-desktop`.
5. Installs Brain keybind compatibility files under `~/.config/Brain_Shell`.
6. Adds Brain keybinds to the existing Hyprland config without replacing it.
7. Creates and enables `brain-desktop.service` for automatic startup.
8. Validates the installed shell before finishing.

The installer is intentionally run as the normal user. It uses `sudo` only for system package and service operations.

## Requirements

- Arch Linux or an Arch-based distribution
- Hyprland
- Wayland
- Quickshell

The installer installs the main runtime dependencies automatically.

## Runtime paths

```text
~/.config/quickshell/brain-desktop/
~/.config/Brain_Shell/
~/.config/systemd/user/brain-desktop.service
```

## Keybinds

Default Brain bindings:

```text
Super + Space       Application launcher
Super + D           Dashboard
Super + Z           Kanban / tasks
Super + C           Configuration
Super + N           Notifications
Super + W           Wallpaper
Super + V           Clipboard
Alt + F9            Screen recording
```

Brain's shipped keybind file uses the current user's home directory and Quickshell's path-based IPC, so it does not contain a hard-coded username or installation path.

## Application launcher filtering

The launcher intentionally hides several utilities that are not useful in a typical Brain Desktop setup, including:

```text
Avahi browser utilities
Caja/Nemo/Nautilus file-manager entries
Hardware Locality lstopo
MATE Color Selection
Yazi
xgps / xgpsspeed
Rofi / Rofi Theme Selector
Micro
KWrite
Neovim
Qt / Qt6 development utilities
```

These packages are **not uninstalled**; only their launcher entries are filtered.

## Fixed configuration

Brain Desktop is shipped as a fixed configuration snapshot. The runtime is intentionally kept self-contained so the installed desktop remains consistent with this build.

## Backups

The installer creates a timestamped backup under:

```text
~/.config.backup-TIMESTAMP-Brain_Desktop/
```

It does not replace the user's Hyprland configuration wholesale.

## License

Brain Desktop is distributed under the MIT License.

See `LICENSE` for the full license text.
