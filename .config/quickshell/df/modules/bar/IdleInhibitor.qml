import qs
import QtQuick
import Quickshell.Io
import qs.modules.common

Item {
    id: root
    implicitWidth: idleText.implicitWidth
    implicitHeight: 20

    Rectangle {
        width: idleText.width + 20
        height: idleText.height + 6
        color: mouseArea.containsMouse ? Appearence.colors.hoverColor : "transparent"
        radius: 10
        anchors.centerIn: parent

        MouseArea {
            id: mouseArea
            hoverEnabled: true
            anchors.fill: parent
            onClicked: {
                GlobalStates.idleInhibitorEnabled = !GlobalStates.idleInhibitorEnabled;
            }
            onEntered: balTooltip.tooltipVisible = true
            onExited: balTooltip.tooltipVisible = false
        }
        StyledText {
            id: idleText
            anchors.centerIn: parent
            font.family: Appearence.font.nerdFont
            font.pixelSize: 12
            color: Appearence.colors.accentColor
            text: GlobalStates.idleInhibitorEnabled ? "" : ""
        }

        Behavior on color {
            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
        }

        CustomTooltip {
            id: balTooltip
            text: GlobalStates.idleInhibitorEnabled ? "activated" : "deactivated"
            tooltipVisible: false
            targetItem: root
            positionAbove: false
        }

        Process {
            running: GlobalStates.idleInhibitorEnabled
            command: ["systemd-inhibit", "--what=idle", "--who=quickshell", "--why=Idle inhibitor active", "--mode=block", "sleep", "inf"]
        }
    }
}
