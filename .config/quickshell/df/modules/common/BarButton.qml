import QtQuick
import qs.modules.common

Item {
    id: root

    property alias text: textItem.text
    property alias textItem: textItem
    property alias fontFamily: textItem.font.family
    property alias fontSize: textItem.font.pixelSize
    property color defaultColor: "transparent"
    property bool useNerdFont: false
    property int horizontalPadding: 16
    property int verticalPadding: 6

    signal clicked
    signal entered
    signal exited

    implicitWidth: textItem.implicitWidth
    implicitHeight: 20

    Rectangle {
        width: textItem.implicitWidth + horizontalPadding
        height: textItem.implicitHeight + verticalPadding
        color: mouseArea.containsMouse ? Appearence.colors.hoverColor : root.defaultColor
        radius: 10
        anchors.centerIn: parent

        StyledText {
            id: textItem
            anchors.centerIn: parent
            font.family: useNerdFont ? Appearence.font.nerdFont : Appearence.font.readFont
            font.pixelSize: 13
            color: Appearence.colors.accentColor
            elide: Text.ElideRight
        }

        MouseArea {
            id: mouseArea
            hoverEnabled: true
            anchors.fill: parent
            onClicked: root.clicked()
            onEntered: root.entered()
            onExited: root.exited()
        }

        Behavior on color {
            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }
}
