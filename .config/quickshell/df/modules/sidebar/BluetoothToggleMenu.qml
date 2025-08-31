import qs
import qs.services
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    width: 48
    height: 48
    radius: 24
    color: (BluetoothService?.ready ?? false) ? Appearence.colors.accentColor : "#11111b"
    border.width: 1
    border.color: "#6c7086"
    scale: mouseArea.containsMouse ? 1.1 : 1.0

    StyledText {
        color: (BluetoothService?.ready ?? false) ? "#45475a" : "#cdd6f4"
        anchors.centerIn: parent
        text: BluetoothService.materialSymbol
        font.family: Appearence.font.nerdFont
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            if (event.button === Qt.LeftButton) {
                toggle.running = true;
            }
            if (event.button === Qt.RightButton) {
                Quickshell.execDetached(["sh", "-c", "if pgrep -x blueman-applet > /dev/null; then killall blueman-applet; else blueman-applet & fi"]);
            }
            event.accepted = true;
        }
    }

    Behavior on color {
        animation: Appearence.animation.elementMove.colorAnimation.createObject(this)
    }
    Behavior on scale {
        animation: Appearence.animation.elementMoveEnter.numberAnimation.createObject(this)
    }

    Process {
        id: toggle
        command: ["sh", "-c", "rfkill list bluetooth | grep -q 'Soft blocked: no' && rfkill block bluetooth || rfkill unblock bluetooth"]
    }
}
