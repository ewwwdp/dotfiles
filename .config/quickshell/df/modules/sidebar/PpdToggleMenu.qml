import QtQuick
import Quickshell.Services.UPower
import qs.modules.common

Rectangle {
    id: root

    property bool isFocused: false

    function activate() {
        if (PowerProfiles.hasPerformanceProfile) {
            switch (PowerProfiles.profile) {
            case PowerProfile.PowerSaver:
                PowerProfiles.profile = PowerProfile.Balanced;
                break;
            case PowerProfile.Balanced:
                PowerProfiles.profile = PowerProfile.Performance;
                break;
            case PowerProfile.Performance:
                PowerProfiles.profile = PowerProfile.PowerSaver;
                break;
            }
        } else {
            PowerProfiles.profile = PowerProfiles.profile == PowerProfile.Balanced ? PowerProfile.PowerSaver : PowerProfile.Balanced;
        }
    }

    width: 48
    height: 48
    radius: 24
    color: Appearence.colors.baseColor
    border.width: 2
    border.color: isFocused ? Appearence.colors.focusColor : Appearence.colors.textMutedColor
    scale: mouseArea.containsMouse ? 1.1 : 1.0
    StyledText {
        color: Appearence.colors.textColor
        anchors.centerIn: parent
        text: switch (PowerProfiles.profile) {
        case PowerProfile.PowerSaver:
            return "";
        case PowerProfile.Balanced:
            return " ";
        case PowerProfile.Performance:
            return "";
        }
        font.family: Appearence.font.nerdFont
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            event.accepted = true;
            root.activate();
        }
    }

    Behavior on scale {
        animation: Appearence.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
}
