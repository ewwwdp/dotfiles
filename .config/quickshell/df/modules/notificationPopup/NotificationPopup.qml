import QtQuick
import Quickshell
import qs.services
import qs

PanelWindow {
    id: notificationWindow
    // Assuming you have access to your notification service
    property var notificationService: NotificationService // Bind this to your notification service instance

    // Window properties
    anchors {
        top: true
        right: true
    }

    implicitWidth: 380
    implicitHeight: Math.max(1, notificationColumn.implicitHeight + 20)

    // Window behavior
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0

    // Only show window when there are popup notifications
    visible: !GlobalStates.dndEnabled && !GlobalStates.sidebarOpen && notificationService && notificationService.popupList.length > 0

    // Dark background with rounded corners
    color: "transparent"

    // Container for all popup notifications
    Column {
        id: notificationColumn
        anchors.fill: parent
        anchors.margins: 6
        spacing: 6

        // Create notification items for each popup notification
        Repeater {
            model: notificationService ? notificationService.popupList : []
            delegate: Notification {
                notificationData: modelData
            }
        }
    }
    // Auto-hide functionality based on popup inhibition
    Connections {
        target: notificationService

        function onPopupInhibitedChanged() {
            if (notificationService && notificationService.popupInhibited) {
                // Timeout all popups when inhibited
                notificationService.timeoutAll();
            }
        }
    }
}
