import QtQuick
import QtQuick.Controls
import "../../"
import "../../components"
import "../"
import "../../theme"

Item {
    anchors.fill: parent

    PopupPage {
        anchors.fill: parent

        SettingCard {
            width: parent.width

            SectionTitle {
                text: "Themes"
            }

            Text {
                width: parent.width
                text: "Change the visual style of Brain Desktop."
                color: Theme.subtext
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            Item {
                width: parent.width
                height: 16
            }

            Column {
                width: parent.width
                spacing: 8

                Repeater {
                    model: ThemeManager.themes

                    delegate: Rectangle {
                        required property var modelData

                        width: parent.width
                        height: 58

                        radius: Theme.cornerRadius
                        color: ThemeManager.currentTheme === modelData.id
                            ? Qt.rgba(
                                Theme.active.r,
                                Theme.active.g,
                                Theme.active.b,
                                0.14
                              )
                            : Qt.rgba(1, 1, 1, 0.04)

                        border.width: 1
                        border.color: ThemeManager.currentTheme === modelData.id
                            ? Theme.active
                            : Theme.border

                        Behavior on color {
                            ColorAnimation {
                                duration: 180
                            }
                        }

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 180
                            }
                        }

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 14

                            Rectangle {
                                width: 10
                                height: 10
                                radius: 5

                                anchors.verticalCenter: parent.verticalCenter

                                color: ThemeManager.currentTheme === modelData.id
                                    ? Theme.active
                                    : Theme.subtext
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 24
                                spacing: 3

                                Text {
                                    text: modelData.name
                                    color: Theme.text
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                }

                                Text {
                                    text: modelData.description
                                    color: Theme.subtext
                                    font.pixelSize: 10
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                ThemeManager.setTheme(modelData.id)
                            }
                        }
                    }
                }
            }
        }
    }
}
