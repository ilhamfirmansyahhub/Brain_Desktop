import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../"

PanelWindow {
    id: root

    property int selectedIndex: 0
    property real wheelTargetY: 0
    property real wheelBoost: 1.0

    visible: BrainSearchService.open

    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay

    WlrLayershell.keyboardFocus:
        visible
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

    MouseArea {
        anchors.fill: parent
        onClicked: {
            BrainSearchService.hide()
        }
    }

    Rectangle {
        id: box
        width: 560
        height: 420
        anchors.centerIn: parent
        radius: 18
        color: Qt.rgba(
            Theme.background.r,
            Theme.background.g,
            Theme.background.b,
            0.96
        )
        border.width: 1
        border.color: Qt.rgba(1,1,1,0.12)

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            Text {
                text: "󰍉  Brain Search"
                font.pixelSize: 18
                font.bold: true
                color: Theme.active
            }

            Rectangle {
                width: parent.width
                height: 46
                radius: 12
                color: Qt.rgba(1,1,1,0.06)

                TextInput {
                    id: search
                    anchors.fill: parent
                    anchors.margins: 12
                    focus: true
                    color: Theme.text
                    font.pixelSize: 15

                    onTextChanged: {
                        BrainSearchService.query = text
                        root.selectedIndex = 0
                    }

                    Keys.onDownPressed: {
                        if (
                            root.selectedIndex <
                            BrainSearchService.results.length - 1
                        ) {
                            root.selectedIndex++
                        }
                    }

                    Keys.onUpPressed: {
                        if (root.selectedIndex > 0)
                            root.selectedIndex--
                    }

                    Keys.onReturnPressed: {
                        if (BrainSearchService.results.length > 0) {
                            BrainSearchService.launch(
                                BrainSearchService
                                .results[root.selectedIndex]
                                .exec
                            )
                        }
                    }

                    Keys.onEscapePressed: {
                        BrainSearchService.hide()
                    }
                }
            }

            ListView {
                id: list

                width: parent.width
                height: 300
                model: BrainSearchService.results
                clip: true
                interactive: true
                boundsBehavior: Flickable.StopAtBounds
                pixelAligned: false

                // High kinetic limits keep fast wheel gestures responsive.
                flickDeceleration: 2600
                maximumFlickVelocity: 7000

                currentIndex: root.selectedIndex

                onContentYChanged: {
                    if (!wheelSpring.running)
                        root.wheelTargetY = contentY
                }

                delegate: Rectangle {
                    width: list.width
                    height: 44
                    radius: 10

                    color:
                        index === root.selectedIndex
                        ? Qt.rgba(
                            Theme.active.r,
                            Theme.active.g,
                            Theme.active.b,
                            0.15
                          )
                        : "transparent"

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            root.selectedIndex = index
                            BrainSearchService.launch(modelData.exec)
                        }
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        Text {
                            text: "󰣇"
                            color: Theme.active
                            font.pixelSize: 16
                        }

                        Text {
                            text: modelData.name
                            color: Theme.text
                            font.pixelSize: 14
                        }
                    }
                }

                WheelHandler {
                    id: wheelHandler

                    onWheel: function(event) {
                        var delta = event.angleDelta.y
                        if (delta === 0)
                            delta = event.pixelDelta.y

                        if (delta === 0) {
                            event.accepted = true
                            return
                        }

                        list.cancelFlick()

                        // Accelerate consecutive wheel ticks so long lists can
                        // be crossed quickly while each movement remains smooth.
                        root.wheelBoost = Math.min(2.8, root.wheelBoost + 0.45)

                        var step = delta / 120 * 135 * root.wheelBoost
                        var maxY = Math.max(0, list.contentHeight - list.height)
                        root.wheelTargetY = Math.max(
                            0,
                            Math.min(maxY, root.wheelTargetY - step)
                        )

                        wheelSpring.restart()
                        wheelBoostReset.restart()
                        event.accepted = true
                    }
                }
            }
        }
    }

    // Very short idle window: sustained scrolling gets acceleration,
    // isolated wheel ticks stay predictable.
    Timer {
        id: wheelBoostReset
        interval: 80
        repeat: false
        onTriggered: root.wheelBoost = 1.0
    }

    SpringAnimation {
        id: wheelSpring
        target: list
        property: "contentY"
        to: root.wheelTargetY
        spring: 13
        damping: 0.88
        mass: 0.3
        epsilon: 0.08
    }

    onVisibleChanged: {
        if (visible) {
            Qt.callLater(function() {
                search.text = ""
                root.selectedIndex = 0
                root.wheelTargetY = 0
                root.wheelBoost = 1.0
                list.contentY = 0
                search.forceActiveFocus()
            })
        }
    }
}
