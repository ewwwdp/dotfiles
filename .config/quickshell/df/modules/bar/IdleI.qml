import qs
import QtQuick
import Quickshell
import Quickshell.Wayland
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
                inhibit.enabled = !inhibit.enabled;
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
            text: inhibit.enabled ? "" : ""
        }

        Behavior on color {
            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
        }

        CustomTooltip {
            id: balTooltip
            text: inhibit.enabled ? "activated" : "deactivated"
            tooltipVisible: false
            targetItem: root
            positionAbove: false
        }

        IdleInhibitor {
            id: inhibit
            window: PanelWindow {
                implicitWidth: 0
                implicitHeight: 0
                color: "transparent"
                mask: Region {}
            }
        }
    }
}
