import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../"

PanelWindow {
    id: root

    property int selectedIndex: 0

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
        onClicked: BrainSearchService.hide()
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
        border.color: Qt.rgba(1, 1, 1, 0.12)

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
                color: Qt.rgba(1, 1, 1, 0.06)

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
                        if (root.selectedIndex < BrainSearchService.results.length - 1)
                            root.selectedIndex++
                        list.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                    }

                    Keys.onUpPressed: {
                        if (root.selectedIndex > 0)
                            root.selectedIndex--
                        list.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                    }

                    Keys.onReturnPressed: {
                        if (BrainSearchService.results.length > 0) {
                            var app = BrainSearchService.results[root.selectedIndex]
                            BrainSearchService.launch(app.exec, app.name)
                        }
                    }

                    Keys.onEscapePressed: BrainSearchService.hide()
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
                flickableDirection: Flickable.VerticalFlick
                pixelAligned: false

                // Native Flickable physics, tuned for a lighter and faster feel.
                flickDeceleration: 900
                maximumFlickVelocity: 12000
                currentIndex: root.selectedIndex

                delegate: Rectangle {
                    width: list.width
                    height: 44
                    radius: 10

                    color: index === root.selectedIndex
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
                            BrainSearchService.launch(modelData.exec, modelData.name)
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
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            Qt.callLater(function() {
                search.text = ""
                root.selectedIndex = 0
                list.cancelFlick()
                list.contentY = 0
                search.forceActiveFocus()
            })
        }
    }
}
