import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../"

Rectangle {
    id: root

    // ── Config Provider ────────────────────────────────────────────────
    property string configProvider: ShellState.configProvider

    // ── Workspace Dispatch Function ────────────────────────────────────
    function dispatchWorkspace(wsTarget, isSpecialToggle = false) {
        if (root.configProvider === "lua") {
            if (isSpecialToggle) {
                Hyprland.dispatch(`hl.dsp.workspace.toggle_special("${wsTarget}")`);
            } else {
                Hyprland.dispatch(`hl.dsp.focus({ workspace = "${wsTarget}" })`);
            }
        } else {
            // Default to 'conf' (Hyprland IPC style)
            if (isSpecialToggle) {
                Hyprland.dispatch(`togglespecialworkspace ${wsTarget}`);
            } else {
                Hyprland.dispatch(`workspace ${wsTarget}`);
            }
        }
    }

    // --- 1. Capsule Container ---
    color: Theme.wsBackground
    radius: Theme.wsRadius

    // Auto-size
    width: workspaceRow.width + (Theme.wsPadding * 2)
    height: Theme.wsDotSize + (Theme.wsPadding * 2)

    // --- 2. LOGIC: Raw Event Listener ---
    property bool isScratchpad: false

    Connections {
        target: Hyprland

        // Quickshell emits (name, data) for raw events
        function onRawEvent(event) {
            // 1. Handle Scratchpad Toggle
            if (event.name === "activespecial" || event.name === "activespecialv2") {
                // Event data format: "workspaceName,monitorName"
                // Example: "special:magic,eDP-1" or ",eDP-1" (closed)
                const wsName = event.data.split(',')[0];

                // If name is not empty, scratchpad is open.
                root.isScratchpad = (wsName !== "");
            }

            // 2. Reset when switching to a normal workspace
            if (event.name === "destroyworkspace") {
                root.isScratchpad = false;
            }
        }
    }

    // ── Pac-Man workspace animation ────────────────────────────────────
    // The workspace row keeps the original ten targets, while a Pac-Man
    // runner animates between the previous and newly focused workspace and
    // visually eats the dots it passes.
    property int pacmanLastWorkspace: -1
    property int pacmanTargetWorkspace: -1
    property real pacmanX: 0
    property real pacmanStartX: 0
    property real pacmanEndX: 0
    property int pacmanDirection: 1
    property bool pacmanTraveling: false
    property real pacmanMouth: 0
    property real pacmanEatProgress: 0

    readonly property int pacmanDuration: {
        var distance = Math.abs(pacmanTargetWorkspace - pacmanLastWorkspace)
        return Math.max(180, Math.min(650, 150 + distance * 90))
    }

    function workspaceCenter(index) {
        var item = workspaceRowRepeater.itemAt(index - 1)
        if (!item) return -1
        return workspaceRow.x + item.x + item.width / 2
    }

    function startPacmanAnimation(fromId, toId) {
        if (fromId < 1 || toId < 1 || fromId === toId) {
            pacmanTraveling = false
            return
        }

        // Let the row settle before measuring delegate positions.
        if (typeof workspaceRow.forceLayout === "function")
            workspaceRow.forceLayout()

        var fromX = workspaceCenter(fromId)
        var toX = workspaceCenter(toId)
        if (fromX < 0 || toX < 0) {
            pacmanTraveling = false
            return
        }

        pacmanStartX = fromX
        pacmanEndX = toX
        pacmanX = fromX
        pacmanDirection = toX >= fromX ? 1 : -1
        pacmanTargetWorkspace = toId
        pacmanEatProgress = 0
        pacmanMouth = 0
        pacmanTraveling = true
        pacmanTravel.restart()
    }

    function finishPacmanAnimation() {
        pacmanTraveling = false
        pacmanEatProgress = 0
        pacmanMouth = 0
    }

    Connections {
        target: Hyprland

        function onFocusedWorkspaceChanged() {
            var current = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1
            if (current < 1) return

            if (root.pacmanLastWorkspace < 1) {
                root.pacmanLastWorkspace = current
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
        pacmanLastWorkspace = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
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
            duration: 90
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: root
            property: "pacmanMouth"
            to: 0
            duration: 90
            easing.type: Easing.InOutSine
        }
    }

    NumberAnimation {
        id: pacmanEat
        target: root
        property: "pacmanEatProgress"
        from: 0
        to: 1
        duration: root.pacmanDuration
        running: root.pacmanTraveling
        easing.type: Easing.Linear
    }

    // --- 3. Workspace Dots / Pac-Man ---
    Row {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: Theme.wsSpacing

        // Logic: Fade out dots when Scratchpad is active
        opacity: root.isScratchpad ? 0 : 1
        scale: root.isScratchpad ? 0.8 : 1
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 200 } }
        Behavior on scale   { NumberAnimation { duration: 200 } }

        Repeater {
            id: workspaceRowRepeater
            model: 10

            delegate: Rectangle {
                id: dot

                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                property bool isOccupied: ws !== undefined
                property bool isUrgent: ws !== undefined && ws.urgent

                height: Theme.wsDotSize
                radius: height / 2
                width: isActive ? Theme.wsActiveWidth : Theme.wsDotSize

                color: {
                    if (isActive)   return Theme.wsActive
                    if (isUrgent)   return Theme.wsUrgent
                    if (isOccupied) return Theme.wsOccupied
                    return Theme.wsEmpty
                }

                // Pac-Man eats the pellets along the path. During travel, dots
                // between source and target fade/shrink as the runner reaches them.
                property bool eatenByPacman: {
                    if (!root.pacmanTraveling) return false
                    var left = Math.min(root.pacmanLastWorkspace, root.pacmanTargetWorkspace)
                    var right = Math.max(root.pacmanLastWorkspace, root.pacmanTargetWorkspace)
                    if (index + 1 < left || index + 1 > right) return false
                    var span = Math.max(1, right - left)
                    var progress = (root.pacmanX - Math.min(root.pacmanStartX, root.pacmanEndX))
                                   / Math.max(1, Math.abs(root.pacmanEndX - root.pacmanStartX))
                    var cellProgress = ((index + 1) - left) / span
                    return root.pacmanDirection > 0
                        ? progress >= cellProgress
                        : progress >= (1 - cellProgress)
                }

                opacity: eatenByPacman && !isActive ? 0.08 : 1
                scale: eatenByPacman && !isActive ? 0.25 : 1

                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on opacity { NumberAnimation { duration: 90 } }
                Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }

                SequentialAnimation {
                    running: dot.isUrgent && !dot.isActive && !root.pacmanTraveling
                    loops: Animation.Infinite

                    NumberAnimation {
                        target: dot
                        property: "scale"
                        to: 1.35
                        duration: 400
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        target: dot
                        property: "scale"
                        to: 1.0
                        duration: 400
                        easing.type: Easing.InOutSine
                    }
                }

                onIsUrgentChanged: {
                    if (!isUrgent) scale = 1.0
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.dispatchWorkspace(index + 1)
                }
            }
        }
    }

    // Pac-Man runner. Uses vector geometry, so no external image/asset is needed.
    Item {
        id: pacmanRunner
        visible: root.pacmanTraveling && !root.isScratchpad
        z: 100
        width: Theme.wsActiveWidth
        height: Theme.wsDotSize + 10
        x: root.pacmanX - width / 2
        y: (parent.height - height) / 2
        scale: 1.0

        Canvas {
            anchors.fill: parent
            antialiasing: true
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                var cx = width / 2
                var cy = height / 2
                var r = Math.max(4, Math.min(width, height) * 0.38)
                var mouth = 0.18 + 0.28 * root.pacmanMouth
                var dir = root.pacmanDirection
                var forward = dir >= 0 ? 0 : Math.PI

                ctx.beginPath()
                ctx.moveTo(cx, cy)
                ctx.arc(cx, cy, r, forward + mouth, forward - mouth + Math.PI * 2)
                ctx.closePath()
                ctx.fillStyle = Theme.wsActive
                ctx.fill()

                ctx.beginPath()
                ctx.arc(cx + dir * r * 0.28, cy - r * 0.35, Math.max(0.9, r * 0.12), 0, Math.PI * 2)
                ctx.fillStyle = "#101010"
                ctx.fill()
            }
        }

        Connections {
            target: root
            function onPacmanMouthChanged() { parent.children[0].requestPaint() }
            function onPacmanDirectionChanged() { parent.children[0].requestPaint() }
        }
    }

    // --- 4. Scratchpad Overlay ---
    Rectangle {
        id: overlay
        anchors.fill: parent
        radius: root.radius
        color: Theme.wsOverlay
        z: 99

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
