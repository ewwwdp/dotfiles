import qs
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common

BarButton {
    id: root
    text: inhibit.enabled ? "" : ""
    useNerdFont: true
    fontSize: 12

    onClicked: inhibit.enabled = !inhibit.enabled
    onEntered: tooltip.tooltipVisible = true
    onExited: tooltip.tooltipVisible = false

    CustomTooltip {
        id: tooltip
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
