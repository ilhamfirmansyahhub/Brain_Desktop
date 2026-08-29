pragma Singleton

import QtQuick
import Quickshell

QtObject {
    id: root

    property string currentWallpaper: ""
    property bool busy: false
    property bool reloadAfterExit: false

    signal wallpaperChanged(string path)

    function reloadCurrentWallpaper() {
        // Wallpaper is managed externally.
    }

    function restoreWallpaper() {
        // Wallpaper is managed externally.
    }

    function applyWallpaper(path) {
        // Wallpaper is managed externally.
    }

    function browseImages() {
        // Wallpaper is managed externally.
    }

    function browseVideos() {
        // Wallpaper is managed externally.
    }

    function randomWallpaper() {
        // Wallpaper is managed externally.
    }

    Component.onCompleted: {
        // Intentionally do nothing.
    }
}
