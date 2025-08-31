import QtQuick
import qs.services
import qs.modules.common

Item {
    id: root
    visible: BluetoothService?.ready ?? false
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
            onEntered: balTooltip.tooltipVisible = true
            onExited: balTooltip.tooltipVisible = false
        }

        StyledText {
            id: innerItem
            anchors.centerIn: parent
            font.family: Appearence.font.readFont
            font.pixelSize: 13
            color: Appearence.colors.accentColor
            text: BluetoothService.materialSymbol
            elide: Text.ElideRight
        }
        Behavior on color {
            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }
    CustomTooltip {
        id: balTooltip
        text: BluetoothService.connectedDevicesText
        tooltipVisible: false
        targetItem: root
        positionAbove: false
    }
}
