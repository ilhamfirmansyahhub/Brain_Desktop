import QtQuick
import Quickshell.Io

// ============================================================
// ColorsLoader — watches ~/.cache/brain-shell/colors.json
// and exposes parsed color properties.
//
// Not a singleton. Instantiated as a property inside Theme.qml.
// Theme.qml reads loader.background, loader.active etc.
// ============================================================

QtObject {
    id: root

    // ── Parsed colors ────────────────────────────────────────────────────────
    // Brain Desktop uses a true black background regardless of matugen output.
    property color background: "#000000"
    property color active:     "#a6d0f7"
    property color text:       "#FFFFFF"
    property color subtext:    "#FFFFFF"
    property color icon:       "#FFFFFF"
    property color border:     "#ffffff"
    property color iconFont:   "#2f8d97"

    // ── File watcher ──────────────────────────────────────────────────────────
    property var _file: FileView {
        id: colorsFile
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root._parse(colorsFile.text())
    }

    property var _homeProc: Process {
        command: ["bash", "-c", "echo $HOME"]
        running: true
        stdout: SplitParser {
            onRead: function(line) {
                var h = line.trim()
                if (h !== "")
                    colorsFile.path = h + "/.cache/brain-shell/colors.json"
            }
        }
    }

    // ── Parser ────────────────────────────────────────────────────────────────
    function _parse(raw) {
        if (!raw || raw.trim() === "") return
        try {
            var obj = JSON.parse(raw)
            // Keep the Brain Desktop background and primary text explicitly black/white.
            root.background = "#000000"
            root.text = "#FFFFFF"
            root.icon = "#FFFFFF"
            root.subtext = "#FFFFFF"
            if (obj.active)     root.active     = obj.active
            if (obj.border)     root.border     = obj.border
            if (obj.iconFont)   root.iconFont   = obj.iconFont
        } catch (e) {
            // Malformed JSON — keep fallback values
        }
    }
}
