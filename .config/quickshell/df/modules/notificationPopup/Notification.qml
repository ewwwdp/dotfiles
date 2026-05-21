import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.modules.common

Rectangle {
    id: notificationItem
    width: parent.width
    height: 90
    color: "#11111b"
    radius: 10
    border.width: 1
    border.color: "#313244"
    property var notificationService: NotificationService
    property bool hovered: myHandler.hovered
    property var notificationData

    HoverHandler {
        id: myHandler
    }
    function updateTimerState() {
        if (notificationData?.timer)
            notificationData.timer.running = !hovered;
    }

    onHoveredChanged: updateTimerState()
    Component.onCompleted: updateTimerState()

    // Hover effect overlay
    Rectangle {
        anchors.fill: parent
        radius: 10
        color: "#ffffff"
        opacity: parent.hovered ? 0.05 : 0
        visible: parent.hovered || opacity > 0
        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }

    MouseArea {
        id: notifArea
        anchors.fill: parent
        onClicked: event => {
            if (notificationService && event.button === Qt.LeftButton) {
                const actions = notificationItem.notificationData.actions;
                if (actions?.length > 0)
                    notificationService.attemptInvokeAction(notificationItem.notificationData.notificationId, "default");
            }
            event.accepted = true;
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 14

        IconImage {
            id: realAppIcon
            visible: data.appIcon?.length > 0
            width: 32
            height: 32
            source: Quickshell.iconPath(data.appIcon)
            smooth: true
        }

        // Enhanced content
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    text: notificationData.appName || "App"
                    color: "#cdd6f4"
                    font.pixelSize: 14
                    font.family: Appearence.font.readFont
                    font.weight: Font.Bold
                }

                Item {
                    Layout.fillWidth: true
                }

                StyledText {
                    text: formatTimestamp(notificationData.time)
                    color: "#6c7086"
                    font.pixelSize: 10
                    font.family: Appearence.font.readFont
                    font.weight: Font.Medium
                }
            }

            StyledText {
                text: notificationData.summary || "Notification"
                color: "#cdd6f4"
                font.pixelSize: 12
                font.weight: Font.Medium
                font.family: Appearence.font.readFont
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                maximumLineCount: 2
            }

            StyledText {
                text: notificationData.body || ""
                color: "#9399b2"
                font.pixelSize: 12
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.family: Appearence.font.readFont
                maximumLineCount: 2
                elide: Text.ElideRight
                visible: text !== "" && text !== notificationData.summary
            }
        }

        // Dismiss button
        Button {
            id: dismissBtn
            width: 24
            height: 24
            hoverEnabled: true

            background: Rectangle {
                radius: 12
                color: dismissBtn.hovered ? "#f38ba8" : "transparent"

                Behavior on color {
                    animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                }
            }

            contentItem: StyledText {
                text: "✕"
                color: dismissBtn.hovered ? "#11111b" : "#6c7086"
                font.pixelSize: 10
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                Behavior on color {
                    animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                }
            }

            onClicked: {
                if (notificationService) {
                    notificationService.discardNotification(notificationData.notificationId);
                }
            }
        }
    }

    function formatTimestamp(timestamp) {
        if (!timestamp)
            return "Now";

        const now = Date.now();
        const diffMs = now - timestamp;
        var diffMins = Math.floor(diffMs / 60000);

        if (diffMins < 1)
            return "Now";
        if (diffMins < 60)
            return diffMins + " min ago";

        var diffHours = Math.floor(diffMins / 60);
        if (diffHours === 1)
            return "1 hour ago";
        if (diffHours < 24)
            return diffHours + " hours ago";

        var diffDays = Math.floor(diffHours / 24);
        if (diffDays === 1)
            return "1 day ago";
        return diffDays + " days ago";
    }
}
