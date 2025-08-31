import qs
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    width: 48
    height: 48
    radius: 24
    color: GlobalStates.gamemodeEnabled ? Appearence.colors.accentColor : "#11111b"
    border.width: 1
    border.color: "#6c7086"
    scale: mouseArea.containsMouse ? 1.1 : 1.0

    StyledText {
        color: GlobalStates.gamemodeEnabled ? "#45475a" : "#cdd6f4"
        anchors.centerIn: parent
        text: GlobalStates.gamemodeEnabled ? "" : ""
        font.family: Appearence.font.nerdFont
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: event => {
            Quickshell.execDetached(["sh", "-c", `${Quickshell.shellDir}/scripts/gamemode.sh`]);
            GlobalStates.gamemodeEnabled = !GlobalStates.gamemodeEnabled;
            event.accepted = true;
        }
    }

    Behavior on color {
        animation: Appearence.animation.elementMove.colorAnimation.createObject(this)
    }
    Behavior on scale {
        animation: Appearence.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
}
