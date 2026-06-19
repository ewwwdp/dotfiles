import QtQuick
import qs.modules.common
import qs.services

BarButton {
    id: root
    visible: BluetoothService.ready
    text: BluetoothService.materialSymbol
    useNerdFont: true

    onEntered: tooltip.tooltipVisible = true
    onExited: tooltip.tooltipVisible = false

    CustomTooltip {
        id: tooltip
        text: BluetoothService.connectedDevicesText
        tooltipVisible: false
        targetItem: root
        positionAbove: false
    }
}
