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

                flickDeceleration: 4200
                maximumFlickVelocity: 16000
                currentIndex: root.selectedIndex

                onContentYChanged: {
                    if (!scrollAnim.running)
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
                        var angle = event.angleDelta.y
                        var pixels = event.pixelDelta.y
                        var delta = pixels !== 0 ? pixels : angle

                        if (delta === 0) {
                            event.accepted = true
                            return
                        }

                        // Treat high-resolution wheel input as continuous pixels,
                        // matching the light, fluid feeling of browser scrolling.
                        if (pixels !== 0)
                            delta *= 1.15
                        else
                            delta = delta / 120 * 140

                        root.wheelBoost = Math.min(3.2, root.wheelBoost + 0.18)

                        var step = delta * root.wheelBoost
                        var maxY = Math.max(0, list.contentHeight - list.height)
                        root.wheelTargetY = Math.max(
                            0,
                            Math.min(maxY, root.wheelTargetY - step)
                        )

                        wheelBoostReset.restart()
                        event.accepted = true
                    }
                }
            }
        }
    }

    Timer {
        id: wheelBoostReset
        interval: 85
        repeat: false
        onTriggered: root.wheelBoost = 1.0
    }

    // Unlike a spring, SmoothedAnimation retargets the same motion continuously.
    // This prevents the tiny stops/jerks caused by restarting an animation on each tick.
    SmoothedAnimation {
        id: scrollAnim
        target: list
        property: "contentY"
        velocity: 9000
        maximumEasingTime: 0.09
    }

    onVisibleChanged: {
        if (visible) {
            Qt.callLater(function() {
                search.text = ""
                root.selectedIndex = 0
                root.wheelTargetY = 0
                root.wheelBoost = 1.0
                list.contentY = 0
                scrollAnim.stop()
                search.forceActiveFocus()
            })
        }
    }
}
