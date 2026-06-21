import QtQuick
import qs.core
import qs.modules.common

BarButton {
    text: "󰍜"
    onClicked: GlobalStates.sidebarOpen = !GlobalStates.sidebarOpen
}
