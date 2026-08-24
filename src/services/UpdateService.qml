pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../"

// UpdateService is intentionally disabled in this build.
QtObject {
    id: root

    readonly property bool autoUpdate: false
    readonly property bool checking: false
    readonly property bool updating: false
    readonly property bool updateAvailable: false
    readonly property bool hasConflict: false
    readonly property bool updateSuccess: false
    readonly property int commitsBehind: 0
    readonly property var commitMessages: []
    readonly property string lastError: ""
    readonly property bool showPopup: false

    function check() {}
    function applyUpdate() {}
    function stashAndUpdate() {}
    function dismiss() {}
    function disableAutoUpdate() {}
}