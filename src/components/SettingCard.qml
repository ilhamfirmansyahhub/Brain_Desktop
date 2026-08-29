import QtQuick
import "../theme"

Rectangle {
    id: root

    default property alias content: body.data

    radius: Theme.cornerRadius

    color: Theme.surface

    border.width: 1
    border.color: Theme.border

    implicitWidth: 400
    implicitHeight: body.implicitHeight + 32

    Column {
        id: body

        anchors.fill: parent
        anchors.margins: 16

        spacing: 14
    }
}
