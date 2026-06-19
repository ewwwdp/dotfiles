import QtQuick
import qs
import qs.modules.common

BarButton {
    text: "󰍜"
    onClicked: GlobalStates.sidebarOpen = !GlobalStates.sidebarOpen
}
