import QtQuick
import Quickshell
import qs.core
import qs.modules.common
import qs.services

BarButton {
    id: root
    text: DateTime.time
    textItem.color: Appearence.colors.clockColor
    defaultColor: Appearence.colors.backgroundBarColor

    onClicked: GlobalStates.calendarOpen = !GlobalStates.calendarOpen
}
