import qs
import qs.modules.common
import qs.services
import QtQuick
import Quickshell

Rectangle {
    id: root

    property bool isFocused: false
    property bool showMenu: false

    function activate() {
        BluetoothService.toggle();
    }

    width: 48
    height: 48
    radius: 24
    color: BluetoothService.ready ? Appearence.colors.accentColor : Appearence.colors.baseColor
    border.width: 2
    border.color: isFocused ? Appearence.colors.focusColor : Appearence.colors.textMutedColor
    scale: mouseArea.containsMouse ? 1.1 : 1.0
    opacity: BluetoothService.hasDefaultAdapter ? 1.0 : 0.4

    StyledText {
        color: BluetoothService.ready ? Appearence.colors.surfaceHoverColor : Appearence.colors.textColor
        anchors.centerIn: parent
        text: BluetoothService.materialSymbol
        font.family: Appearence.font.nerdFont
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: BluetoothService.hasDefaultAdapter
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            event.accepted = true;
            if (event.button === Qt.RightButton) {
                showMenu = BluetoothService.ready && !showMenu;
            } else {
                showMenu = false;
                BluetoothService.toggle();
            }
        }
    }

    Behavior on color {
        animation: Appearence.animation.elementMove.colorAnimation.createObject(this)
    }
    Behavior on scale {
        animation: Appearence.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
}
