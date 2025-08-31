import QtQuick
import Quickshell
import qs.modules.common
import qs.services

Item {
    id: root
    implicitWidth: innerItem.implicitWidth
    implicitHeight: 20
    Rectangle {
        width: innerItem.width + 16
        height: innerItem.height + 6
        color: mouseArea.containsMouse ? Appearence.colors.hoverColor : Appearence.colors.pureBlackColor
        radius: 10
        anchors.centerIn: parent

        MouseArea {
            id: mouseArea
            hoverEnabled: true
            anchors.fill: parent
        }

        StyledText {
            id: innerItem
            anchors.centerIn: parent
            font {
                family: Appearence.font.readFont
                pixelSize: 13
            }
            color: Appearence.colors.accentColor
            text: DateTime.time
        }
        Behavior on color {
            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }
}
