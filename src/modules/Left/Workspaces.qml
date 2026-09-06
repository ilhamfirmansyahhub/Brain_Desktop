import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../"

Rectangle {
    id: root

    property string configProvider: ShellState.configProvider

    function dispatchWorkspace(wsTarget, isSpecialToggle = false) {
        if (root.configProvider === "lua") {
            if (isSpecialToggle) {
                Hyprland.dispatch(`hl.dsp.workspace.toggle_special("${wsTarget}")`)
            } else {
                Hyprland.dispatch(`hl.dsp.focus({ workspace = "${wsTarget}" })`)
            }
        } else {
            if (isSpecialToggle) {
                Hyprland.dispatch(`togglespecialworkspace ${wsTarget}`)
            } else {
                Hyprland.dispatch(`workspace ${wsTarget}`)
            }
        }
    }

    color: Theme.wsBackground
    radius: Theme.wsRadius

    width: workspaceRow.width + (Theme.wsPadding * 2)
    height: Math.max(Theme.wsDotSize, pacmanSize) + (Theme.wsPadding * 2)

    property bool isScratchpad: false

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "activespecial" || event.name === "activespecialv2") {
                const wsName = event.data.split(",")[0]
                root.isScratchpad = (wsName !== "")
            }

            if (event.name === "destroyworkspace")
                root.isScratchpad = false
        }
    }

    // ── Pac-Man state ─────────────────────────────────────────────────
    property int pacmanSourceWorkspace: -1
    property int pacmanLastWorkspace: -1
    property int pacmanTargetWorkspace: -1
    property real pacmanX: 0
    property real pacmanStartX: 0
    property real pacmanEndX: 0
    property int pacmanDirection: 1
    property bool pacmanTraveling: false
    property real pacmanMouth: 0
    readonly property int pacmanSize: Math.max(Theme.wsDotSize + 2, 16)

    readonly property int pacmanDuration: {
        if (pacmanSourceWorkspace < 1 || pacmanTargetWorkspace < 1)
            return 220

        var distance = Math.abs(pacmanTargetWorkspace - pacmanSourceWorkspace)
        return Math.max(220, Math.min(700, 180 + distance * 95))
    }

    function workspaceCenter(workspaceId) {
        var item = workspaceRowRepeater.itemAt(workspaceId - 1)
        if (!item) return -1
        return workspaceRow.x + item.x + item.width / 2
    }

    function normalizedEatProgress() {
        if (!pacmanTraveling)
            return 1

        var distance = Math.abs(pacmanEndX - pacmanStartX)
        if (distance < 1)
            return 1

        return Math.max(0, Math.min(1,
            Math.abs(pacmanX - pacmanStartX) / distance))
    }

    function startPacmanAnimation(fromId, toId) {
        if (fromId < 1 || toId < 1 || fromId === toId) {
            pacmanTraveling = false
            return
        }

        if (typeof workspaceRow.forceLayout === "function")
            workspaceRow.forceLayout()

        var fromX = workspaceCenter(fromId)
        var toX = workspaceCenter(toId)
        if (fromX < 0 || toX < 0) {
            pacmanTraveling = false
            return
        }

        pacmanSourceWorkspace = fromId
        pacmanTargetWorkspace = toId
        pacmanStartX = fromX
        pacmanEndX = toX
        pacmanX = fromX

        // Workspace 1 is always the home/right-facing position.
        // This keeps Pac-Man facing right even when returning from workspace 2+.
        pacmanDirection = toId === 1 ? 1 : (toX >= fromX ? 1 : -1)

        pacmanMouth = 0
        pacmanTraveling = true
        pacmanTravel.restart()
    }

    function finishPacmanAnimation() {
        pacmanTraveling = false
        pacmanSourceWorkspace = pacmanTargetWorkspace
        pacmanLastWorkspace = pacmanTargetWorkspace
        pacmanX = workspaceCenter(pacmanLastWorkspace)
        pacmanMouth = 0

        // Workspace 1 always rests facing right.
        if (pacmanLastWorkspace === 1)
            pacmanDirection = 1
    }

    Connections {
        target: Hyprland

        function onFocusedWorkspaceChanged() {
            var current = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1
            if (current < 1) return

            if (root.pacmanLastWorkspace < 1) {
                root.pacmanLastWorkspace = current
                root.pacmanTargetWorkspace = current
                if (current === 1)
                    root.pacmanDirection = 1
                Qt.callLater(function() {
                    root.pacmanX = root.workspaceCenter(current)
                })
                return
            }

            if (current === root.pacmanLastWorkspace) return

            var previous = root.pacmanLastWorkspace
            root.pacmanLastWorkspace = current
            Qt.callLater(function() {
                root.startPacmanAnimation(previous, current)
            })
        }
    }

    Component.onCompleted: {
        var current = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
        pacmanLastWorkspace = current
        pacmanTargetWorkspace = current
        if (current === 1)
            pacmanDirection = 1
        Qt.callLater(function() {
            pacmanX = workspaceCenter(current)
        })
    }

    NumberAnimation {
        id: pacmanTravel
        target: root
        property: "pacmanX"
        from: root.pacmanStartX
        to: root.pacmanEndX
        duration: root.pacmanDuration
        easing.type: Easing.InOutCubic
        onRunningChanged: {
            if (!running && root.pacmanTraveling)
                root.finishPacmanAnimation()
        }
    }

    SequentialAnimation {
        running: root.pacmanTraveling
        loops: Animation.Infinite

        NumberAnimation {
            target: root
            property: "pacmanMouth"
            to: 1
            duration: 85
            easing.type: Easing.InOutSine
        }

        NumberAnimation {
            target: root
            property: "pacmanMouth"
            to: 0
            duration: 85
            easing.type: Easing.InOutSine
        }
    }

    // ── Workspace pellets ──────────────────────────────────────────────
    Row {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: Theme.wsSpacing

        opacity: root.isScratchpad ? 0 : 1
        scale: root.isScratchpad ? 0.8 : 1
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 200 } }
        Behavior on scale { NumberAnimation { duration: 200 } }

        Repeater {
            id: workspaceRowRepeater
            model: 10

            delegate: Rectangle {
                id: dot

                readonly property int workspaceId: index + 1
                property var ws: Hyprland.workspaces.values.find(w => w.id === workspaceId)
                property bool isActive: Hyprland.focusedWorkspace?.id === workspaceId
                property bool isOccupied: ws !== undefined
                property bool isUrgent: ws !== undefined && ws.urgent

                width: Theme.wsDotSize
                height: Theme.wsDotSize
                radius: height / 2

                color: isUrgent
                    ? Theme.wsUrgent
                    : isOccupied
                        ? Theme.wsOccupied
                        : Theme.wsEmpty

                property bool eatenByPacman: {
                    if (!root.pacmanTraveling)
                        return false

                    var from = root.pacmanSourceWorkspace
                    var to = root.pacmanTargetWorkspace
                    var distance = Math.abs(to - from)
                    if (distance < 1 || workspaceId < Math.min(from, to) || workspaceId > Math.max(from, to))
                        return false

                    var cellProgress = Math.abs(workspaceId - from) / distance
                    return root.normalizedEatProgress() >= cellProgress
                }

                opacity: eatenByPacman ? 0.05 : 1
                scale: eatenByPacman ? 0.15 : 1

                Behavior on color { ColorAnimation { duration: 160 } }
                Behavior on opacity { NumberAnimation { duration: 75 } }
                Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }

                SequentialAnimation {
                    running: dot.isUrgent && !root.pacmanTraveling
                    loops: Animation.Infinite

                    NumberAnimation {
                        target: dot
                        property: "scale"
                        to: 1.3
                        duration: 380
                        easing.type: Easing.InOutSine
                    }

                    NumberAnimation {
                        target: dot
                        property: "scale"
                        to: 1
                        duration: 380
                        easing.type: Easing.InOutSine
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.dispatchWorkspace(workspaceId)
                }
            }
        }
    }

    // ── Pac-Man ─────────────────────────────────────────────────────────
    Item {
        id: pacmanRunner

        visible: !root.isScratchpad && root.pacmanLastWorkspace > 0
        z: 100
        width: root.pacmanSize
        height: root.pacmanSize
        x: (root.pacmanTraveling ? root.pacmanX : root.workspaceCenter(root.pacmanLastWorkspace)) - width / 2
        y: (parent.height - height) / 2

        Canvas {
            id: pacmanCanvas
            anchors.fill: parent
            antialiasing: true

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                var cx = width / 2
                var cy = height / 2
                var r = Math.max(5, Math.min(width, height) * 0.39)
                var mouth = 0.16 + 0.30 * root.pacmanMouth
                var dir = root.pacmanDirection
                var forward = dir > 0 ? 0 : Math.PI

                ctx.beginPath()
                ctx.moveTo(cx, cy)
                ctx.arc(cx, cy, r, forward + mouth, forward - mouth + Math.PI * 2)
                ctx.closePath()
                ctx.fillStyle = Theme.wsActive
                ctx.fill()

                ctx.beginPath()
                ctx.arc(
                    cx + dir * r * 0.25,
                    cy - r * 0.38,
                    Math.max(0.8, r * 0.10),
                    0,
                    Math.PI * 2
                )
                ctx.fillStyle = "#111111"
                ctx.fill()
            }
        }

        Connections {
            target: root

            function onPacmanMouthChanged() { pacmanCanvas.requestPaint() }
            function onPacmanDirectionChanged() { pacmanCanvas.requestPaint() }
        }

        Component.onCompleted: pacmanCanvas.requestPaint()
    }

    // ── Scratchpad overlay ─────────────────────────────────────────────
    Rectangle {
        id: overlay
        anchors.fill: parent
        radius: root.radius
        color: Theme.wsOverlay
        z: 101

        visible: opacity > 0
        opacity: root.isScratchpad ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Text {
            anchors.centerIn: parent
            text: ""
            color: "#FFFFFF"
            font.pixelSize: 14
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.dispatchWorkspace("magic", true)
        }
    }
}
