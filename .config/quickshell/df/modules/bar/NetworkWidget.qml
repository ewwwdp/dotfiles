import QtQuick
import qs.modules.common
import qs.services

BarButton {
    id: root
    text: Network.materialSymbol

    onEntered: tooltip.tooltipVisible = true
    onExited: tooltip.tooltipVisible = false

    CustomTooltip {
        id: tooltip
        text: Network.networkName
        tooltipVisible: false
        targetItem: root
        positionAbove: false
    }
}
