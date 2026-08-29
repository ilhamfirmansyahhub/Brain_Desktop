pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // ============================================================
    // PERSISTENT THEME
    // ============================================================

    property alias currentTheme: themeAdapter.currentTheme

    property var _themeFile: FileView {
        id: themeFile

        path: (Quickshell.env("HOME") || "") +
              "/.config/Brain_Shell/src/user_data/brain_theme.json"

        blockLoading: true
        watchChanges: true
        printErrors: false
        atomicWrites: true

        onFileChanged: reload()

        JsonAdapter {
            id: themeAdapter

            property string currentTheme: "brain-default"
        }

        Component.onCompleted: {
            if (!themeFile.text())
                themeFile.writeAdapter()
        }
    }

    // ============================================================
    // ACTIVE THEME
    // ============================================================

    readonly property var themes: [
        {
            id: "brain-default",
            name: "Brain Default",
            description: "Original Brain Desktop"
        },
        {
            id: "glass",
            name: "Glass",
            description: "Transparent glass"
        },
        {
            id: "blur",
            name: "Blur",
            description: "Soft blurred dark"
        },
        {
            id: "catppuccin-mocha",
            name: "Catppuccin Mocha",
            description: "Pastel dark palette"
        },
        {
            id: "gruvbox",
            name: "Gruvbox",
            description: "Warm retro palette"
        },
        {
            id: "tokyo-night",
            name: "Tokyo Night",
            description: "Deep blue night palette"
        },
        {
            id: "nord",
            name: "Nord",
            description: "Cool muted palette"
        },
        {
            id: "dracula",
            name: "Dracula",
            description: "Purple dark palette"
        },
        {
            id: "gnome",
            name: "GNOME",
            description: "Clean dark gray style"
        }
    ]

    function is(theme) {
        return root.currentTheme === theme
    }

    function setTheme(theme) {
        for (var i = 0; i < root.themes.length; i++) {
            if (root.themes[i].id === theme) {
                root.currentTheme = theme
                themeFile.writeAdapter()
                return
            }
        }
    }

    function reset() {
        root.currentTheme = "brain-default"
        themeFile.writeAdapter()
    }

    // ============================================================
    // COLORS
    // ============================================================

    readonly property color background: {
        if (is("glass"))
            return Qt.rgba(0.08, 0.12, 0.17, 0.32)

        if (is("blur"))
            return Qt.rgba(0.08, 0.10, 0.13, 0.68)

        if (is("catppuccin-mocha"))
            return "#1e1e2e"

        if (is("gruvbox"))
            return "#282828"

        if (is("tokyo-night"))
            return "#1a1b26"

        if (is("nord"))
            return "#2e3440"

        if (is("dracula"))
            return "#282a36"

        if (is("gnome"))
            return "#1e1e1e"

        return Colors.background
    }

    readonly property color active: {
        if (is("glass"))
            return "#8ab4f8"

        if (is("blur"))
            return "#9aa7ff"

        if (is("catppuccin-mocha"))
            return "#cba6f7"

        if (is("gruvbox"))
            return "#fabd2f"

        if (is("tokyo-night"))
            return "#7aa2f7"

        if (is("nord"))
            return "#88c0d0"

        if (is("dracula"))
            return "#bd93f9"

        if (is("gnome"))
            return "#78aeed"

        return Colors.active
    }

    readonly property color text: {
        if (is("glass"))
            return "#f5f7fa"

        if (is("blur"))
            return "#f2f4f8"

        if (is("catppuccin-mocha"))
            return "#cdd6f4"

        if (is("gruvbox"))
            return "#ebdbb2"

        if (is("tokyo-night"))
            return "#c0caf5"

        if (is("nord"))
            return "#eceff4"

        if (is("dracula"))
            return "#f8f8f2"

        if (is("gnome"))
            return "#ffffff"

        return Colors.text
    }

    readonly property color subtext: {
        if (is("glass"))
            return "#b8c0cc"

        if (is("blur"))
            return "#a8afbd"

        if (is("catppuccin-mocha"))
            return "#a6adc8"

        if (is("gruvbox"))
            return "#bdae93"

        if (is("tokyo-night"))
            return "#9aa5ce"

        if (is("nord"))
            return "#b4bdc9"

        if (is("dracula"))
            return "#b9b9c7"

        if (is("gnome"))
            return "#b8b8b8"

        return Colors.subtext
    }

    readonly property color icon: {
        if (is("glass"))
            return "#dce6f5"

        if (is("blur"))
            return "#d8deeb"

        if (is("catppuccin-mocha"))
            return "#cdd6f4"

        if (is("gruvbox"))
            return "#ebdbb2"

        if (is("tokyo-night"))
            return "#c0caf5"

        if (is("nord"))
            return "#d8dee9"

        if (is("dracula"))
            return "#f8f8f2"

        if (is("gnome"))
            return "#ffffff"

        return Colors.icon
    }

    readonly property color border: {
        if (is("glass"))
            return "#dbeafe"

        if (is("blur"))
            return "#6f7890"

        if (is("catppuccin-mocha"))
            return "#585b70"

        if (is("gruvbox"))
            return "#665c54"

        if (is("tokyo-night"))
            return "#3b4261"

        if (is("nord"))
            return "#4c566a"

        if (is("dracula"))
            return "#6272a4"

        if (is("gnome"))
            return "#4a4a4a"

        return Colors.border
    }

    readonly property color iconFont: active

    // ============================================================
    // SURFACES / UI STATES
    // ============================================================

    readonly property color surface: {
        if (is("glass"))
            return Qt.rgba(0.15, 0.19, 0.24, 0.42)

        if (is("blur"))
            return Qt.rgba(0.10, 0.12, 0.16, 0.70)

        if (is("catppuccin-mocha"))
            return "#313244"

        if (is("gruvbox"))
            return "#3c3836"

        if (is("tokyo-night"))
            return "#24283b"

        if (is("nord"))
            return "#3b4252"

        if (is("dracula"))
            return "#44475a"

        if (is("gnome"))
            return "#2a2a2a"

        return Qt.rgba(1, 1, 1, 0.05)
    }

    readonly property color surfaceAlt: {
        if (is("glass"))
            return Qt.rgba(0.19, 0.25, 0.32, 0.50)

        if (is("blur"))
            return Qt.rgba(0.14, 0.17, 0.22, 0.76)

        if (is("catppuccin-mocha"))
            return "#45475a"

        if (is("gruvbox"))
            return "#504945"

        if (is("tokyo-night"))
            return "#292e42"

        if (is("nord"))
            return "#434c5e"

        if (is("dracula"))
            return "#6272a4"

        if (is("gnome"))
            return "#353535"

        return Qt.rgba(1, 1, 1, 0.08)
    }

    readonly property color muted: {
        if (is("catppuccin-mocha"))
            return "#6c7086"

        if (is("gruvbox"))
            return "#928374"

        if (is("tokyo-night"))
            return "#565f89"

        if (is("nord"))
            return "#616e88"

        if (is("dracula"))
            return "#6272a4"

        if (is("gnome"))
            return "#888888"

        if (is("glass"))
            return "#718096"

        if (is("blur"))
            return "#6f7885"

        return "#808080"
    }

    readonly property color hover: {
        if (is("glass"))
            return Qt.rgba(1, 1, 1, 0.10)

        if (is("blur"))
            return Qt.rgba(1, 1, 1, 0.08)

        return Qt.rgba(1, 1, 1, 0.07)
    }

    readonly property color selected:
        Qt.rgba(active.r, active.g, active.b, 0.16)

    readonly property color success: {
        if (is("catppuccin-mocha"))
            return "#a6e3a1"

        if (is("gruvbox"))
            return "#b8bb26"

        if (is("tokyo-night"))
            return "#9ece6a"

        if (is("nord"))
            return "#a3be8c"

        if (is("dracula"))
            return "#50fa7b"

        if (is("gnome"))
            return "#73d216"

        return "#a6e3a1"
    }

    readonly property color warning: {
        if (is("catppuccin-mocha"))
            return "#f9e2af"

        if (is("gruvbox"))
            return "#fabd2f"

        if (is("tokyo-night"))
            return "#e0af68"

        if (is("nord"))
            return "#ebcb8b"

        if (is("dracula"))
            return "#f1fa8c"

        if (is("gnome"))
            return "#f6d32d"

        return "#f5c47a"
    }

    readonly property color danger: {
        if (is("catppuccin-mocha"))
            return "#f38ba8"

        if (is("gruvbox"))
            return "#fb4934"

        if (is("tokyo-night"))
            return "#f7768e"

        if (is("nord"))
            return "#bf616a"

        if (is("dracula"))
            return "#ff5555"

        if (is("gnome"))
            return "#ed333b"

        return "#f38ba8"
    }

    // ============================================================
    // WORKSPACE COLORS
    // ============================================================

    readonly property color workspaceActive:
        active

    readonly property color workspaceOccupied:
        Qt.rgba(text.r, text.g, text.b, 0.50)

    readonly property color workspaceEmpty:
        Qt.rgba(text.r, text.g, text.b, 0.18)

    readonly property color workspaceUrgent:
        danger

    // ============================================================
    // VISUAL EFFECTS
    // ============================================================

    readonly property real barOpacity: {
        if (is("glass")) return 0.62
        if (is("blur")) return 0.78
        if (is("gruvbox")) return 0.92
        if (is("gnome")) return 0.94
        return 0.90
    }

    readonly property int blurRadius: {
        if (is("glass")) return 32
        if (is("blur")) return 26
        if (is("catppuccin-mocha")) return 18
        if (is("tokyo-night")) return 20
        if (is("nord")) return 16
        if (is("dracula")) return 18
        if (is("gnome")) return 14
        if (is("gruvbox")) return 12
        return Metrics.blurRadius
    }

    readonly property real transparency: {
        if (is("glass")) return 0.38
        if (is("blur")) return 0.26
        if (is("gruvbox")) return 0.08
        if (is("gnome")) return 0.06
        return 0.12
    }

    readonly property int borderWidth: {
        if (is("glass")) return 2
        return Metrics.borderWidth
    }

    readonly property int cornerRadius: {
        if (is("glass")) return 22
        if (is("blur")) return 20
        if (is("gruvbox")) return 12
        if (is("gnome")) return 14
        if (is("catppuccin-mocha")) return 17
        return Metrics.cornerRadius
    }

    readonly property int notchRadius: {
        if (is("glass")) return 20
        if (is("blur")) return 18
        if (is("gruvbox")) return 12
        if (is("gnome")) return 13
        return Metrics.notchRadius
    }

    readonly property int wsRadius: {
        if (is("glass")) return 20
        if (is("blur")) return 18
        if (is("gruvbox")) return 12
        if (is("gnome")) return 14
        return Metrics.wsRadius
    }

    // ============================================================
    // STATIC METRICS
    // ============================================================

    readonly property bool barEnabled:
        Metrics.barEnabled

    readonly property int notchHeight:
        Metrics.notchHeight

    readonly property int exclusionGap:
        Metrics.exclusionGap

    readonly property int spacing:
        Metrics.spacing

    readonly property int notchPadding:
        Metrics.notchPadding

    readonly property int notchHorizontalPadding:
        Metrics.notchHorizontalPadding

    readonly property int notchVerticalPadding:
        Metrics.notchVerticalPadding

    readonly property int notchSideMargin:
        Metrics.notchSideMargin

    readonly property int lNotchMinWidth:
        Metrics.lNotchMinWidth

    readonly property int lNotchMaxWidth:
        Metrics.lNotchMaxWidth

    readonly property int cNotchMinWidth:
        Metrics.cNotchMinWidth

    readonly property int cNotchMaxWidth:
        Metrics.cNotchMaxWidth

    readonly property int rNotchMinWidth:
        Metrics.rNotchMinWidth

    readonly property int rNotchMaxWidth:
        Metrics.rNotchMaxWidth

    readonly property int dashboardWidth:
        Metrics.dashboardWidth

    readonly property int dashboardHeight:
        Metrics.dashboardHeight

    readonly property int notificationsWidth:
        Metrics.notificationsWidth

    readonly property int notificationToastWidth:
        Metrics.notificationToastWidth

    readonly property int networkPopupWidth:
        Metrics.networkPopupWidth

    readonly property int popupMinWidth:
        Metrics.popupMinWidth

    readonly property int popupMaxWidth:
        Metrics.popupMaxWidth

    readonly property int popupMinHeight:
        Metrics.popupMinHeight

    readonly property int popupMaxHeight:
        Metrics.popupMaxHeight

    readonly property int popupPadding:
        Metrics.popupPadding

    readonly property int wsDotSize:
        Metrics.wsDotSize

    readonly property int wsActiveWidth:
        Metrics.wsActiveWidth

    readonly property int wsSpacing:
        Metrics.wsSpacing

    readonly property int wsPadding:
        Metrics.wsPadding

    readonly property int animDuration:
        Metrics.animDuration
}
