import qs
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    property bool isFocused: false

    function activate() {
        Quickshell.execDetached(["sh", "-c", `${Quickshell.shellDir}/scripts/gamemode.sh`]);
        GlobalStates.gamemodeEnabled = !GlobalStates.gamemodeEnabled;
    }

    width: 48
    height: 48
    radius: 24
    color: GlobalStates.gamemodeEnabled ? Appearence.colors.accentColor : Appearence.colors.baseColor
    border.width: 2
    border.color: isFocused ? Appearence.colors.focusColor : Appearence.colors.textMutedColor
    scale: mouseArea.containsMouse ? 1.1 : 1.0

    StyledText {
        color: GlobalStates.gamemodeEnabled ? Appearence.colors.surfaceHoverColor : Appearence.colors.textColor
        anchors.centerIn: parent
        text: GlobalStates.gamemodeEnabled ? "" : ""
        font.family: Appearence.font.nerdFont
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: event => {
            event.accepted = true;
            root.activate();
        }
    }

    Behavior on color {
        animation: Appearence.animation.elementMove.colorAnimation.createObject(this)
    }
    Behavior on scale {
        animation: Appearence.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
}
