import QtQuick
import qs.modules.common
import qs.services

Item {
    id: root
    implicitWidth: loader.implicitWidth
    implicitHeight: 20
    Rectangle {
        width: loader.width + 16
        height: loader.height + 6
        color: mouseArea.containsMouse ? Appearence.colors.hoverColor : "transparent"
        radius: 10
        anchors.centerIn: parent

        MouseArea {
            id: mouseArea
            hoverEnabled: true
            anchors.fill: parent
        }

        Loader {
            id: loader
            sourceComponent: StyledText {
                id: innerItem
                anchors.centerIn: parent
                font.family: Appearence.font.readFont
                font.pixelSize: 13
                color: Appearence.colors.accentColor
                text: XcbLayout.currentLayoutCode
                elide: Text.ElideRight
            }
            anchors.centerIn: parent
        }
        Behavior on color {
            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }
}
