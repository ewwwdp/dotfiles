import QtQuick
import Quickshell.Services.UPower
import qs.modules.common

Rectangle {
    id: root
    width: 48
    height: 48
    radius: 24
    color: "#11111b"
    border.width: 1
    border.color: "#6c7086"
    scale: mouseArea.containsMouse ? 1.1 : 1.0
    StyledText {
        color: "#cdd6f4"
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
    }

    Behavior on scale {
        animation: Appearence.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
}
