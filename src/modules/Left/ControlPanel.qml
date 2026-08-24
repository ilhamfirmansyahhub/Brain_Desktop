import QtQuick
import Quickshell
import Quickshell.Io
import "../../components"
import "../../"

IconBtn {
    text: ""
    textColor: "#1793d1"

    Process {
        id: launcher
        command: [
            "qs",
            "ipc",
            "-p",
            Quickshell.shellDir,
            "call",
            "dashboard-launcher",
            "toggle"
        ]
        running: false
    }

    onClicked: {
        Popups.closeAll()
        launcher.running = true
    }
}
