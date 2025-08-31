import QtQuick
import qs
import qs.modules.common

Item {
    id: root
    implicitWidth: innerItem.implicitWidth
    implicitHeight: 20
    Rectangle {
        width: innerItem.width + 16
        height: innerItem.height + 6
        color: mouseArea.containsMouse ? Appearence.colors.hoverColor : "transparent"
        radius: 10
        anchors.centerIn: parent

        MouseArea {
            id: mouseArea
            hoverEnabled: true
            anchors.fill: parent
            onClicked: GlobalStates.sidebarOpen = !GlobalStates.sidebarOpen
        }

        StyledText {
            id: innerItem
            anchors.centerIn: parent
            font.family: Appearence.font.readFont
            font.pixelSize: 13
            color: Appearence.colors.accentColor
            text: "󰍜"
            elide: Text.ElideRight
        }
        Behavior on color {
            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }
}
