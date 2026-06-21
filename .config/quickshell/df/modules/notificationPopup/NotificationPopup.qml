import QtQuick
import Quickshell
import qs.services
import qs.core

PanelWindow {
    id: notificationWindow
    property var notificationService: NotificationService

    anchors {
        top: true
        right: true
    }

    implicitWidth: 380
    implicitHeight: Math.max(1, notificationColumn.implicitHeight + 20)

    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0

    visible: !GlobalStates.dndEnabled && !GlobalStates.sidebarOpen && notificationService && notificationService.popupList.length > 0

    color: "transparent"

    Column {
        id: notificationColumn
        anchors.fill: parent
        anchors.margins: 6
        spacing: 6

        Repeater {
            model: notificationService ? notificationService.popupList : []
            delegate: Notification {
                notificationData: modelData
            }
        }
    }

    Connections {
        target: notificationService

        function onPopupInhibitedChanged() {
            if (notificationService && notificationService.popupInhibited) {
                notificationService.timeoutAll();
            }
        }
    }
}
