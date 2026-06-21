import QtQuick
import Quickshell
import qs.core
import qs.modules.common
import qs.services

BarButton {
    id: root
    text: DateTime.time
    defaultColor: Appearence.colors.pureBlackColor

    onClicked: GlobalStates.calendarOpen = !GlobalStates.calendarOpen
}
