#!/usr/bin/env python3
import os
import json
import re
import configparser

HIDDEN_DESKTOP_FILES = {
    "re.fossplant.songrec.desktop",
    "voxtype-configure.desktop",
    "org.pulseaudio.pavucontrol.desktop",
    "vim.desktop",
    "avahi-discover.desktop",
    "bssh.desktop",
    "bvnc.desktop",
    "caja-file-management-properties.desktop",
    "nemo.desktop",
    "org.gnome.Nautilus.desktop",
    "lstopo.desktop",
    "mate-color-select.desktop",
    "yazi.desktop",
    "xgps.desktop",
    "xgpsspeed.desktop",
    "rofi.desktop",
    "rofi-theme-selector.desktop",
    "nm-connection-editor.desktop",
    "blueman-adapters.desktop",
    "blueman-manager.desktop",
    "com.github.wwmm.easyeffects.desktop",
    "be.alexandervanhee.gradia.desktop",
    "yad-settings.desktop",
    "cachyos-hello.desktop",
    "org.cachyos.KernelManager.desktop",
    "cachyos-pi.desktop",
    "org.cachyos.scx-manager.desktop",
    "com.shellyorg.shelly.desktop",
    "btop.desktop",
    "htop.desktop",
}

HIDDEN_APP_NAMES = {
    "Micro",
    "KWrite",
    "Neovim",
}

HIDDEN_APP_PREFIXES = (
    "Qt ",
    "Qt6 ",
)

HIDDEN_DESKTOP_PREFIXES = (
    "com.system76.Cosmic",
)

def main():
    dirs = [
        "/usr/share/applications",
        os.path.expanduser("~/.local/share/applications"),
    ]

    apps = []
    seen = set()

    for d in dirs:
        if not os.path.isdir(d):
            continue

        for fname in sorted(os.listdir(d)):
            if not fname.endswith(".desktop"):
                continue

            if fname in HIDDEN_DESKTOP_FILES:
                continue

            if fname.startswith(HIDDEN_DESKTOP_PREFIXES):
                continue

            if fname in seen:
                continue

            seen.add(fname)

            path = os.path.join(d, fname)

            try:
                cp = configparser.ConfigParser(
                    interpolation=None,
                    strict=False,
                )
                cp.read(path, encoding="utf-8")

                if not cp.has_section("Desktop Entry"):
                    continue

                de = cp["Desktop Entry"]

                if de.get("Type", "") != "Application":
                    continue

                if de.get("NoDisplay", "false").lower() == "true":
                    continue

                if de.get("Hidden", "false").lower() == "true":
                    continue

                name = de.get("Name", "").strip()

                if name in HIDDEN_APP_NAMES:
                    continue

                if name.startswith(HIDDEN_APP_PREFIXES):
                    continue

                exec_ = re.sub(
                    r"%[a-zA-Z]",
                    "",
                    de.get("Exec", ""),
                ).strip()

                if not name or not exec_:
                    continue

                apps.append({
                    "name": name,
                    "exec": exec_,
                    "icon": de.get("Icon", ""),
                    "categories": de.get("Categories", ""),
                })

            except Exception:
                continue

    apps.sort(key=lambda a: a["name"].lower())

    print(json.dumps(apps))


if __name__ == "__main__":
    main()
