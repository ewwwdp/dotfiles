import QtQuick
import qs.modules.common

Item {
    id: root
    required property Component content
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
            sourceComponent: root.content
            anchors.centerIn: parent
        }
        Behavior on color {
            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }
}
