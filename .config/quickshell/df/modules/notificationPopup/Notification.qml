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
    color: Appearence.colors.baseColor
    radius: 10
    border.width: 1
    border.color: Appearence.colors.borderColor
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

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Appearence.colors.whiteColor
        opacity: parent.hovered ? 0.05 : 0
        visible: parent.hovered || opacity > 0
        Behavior on opacity {
            animation: Appearence.animation.opacityFade.numberAnimation.createObject(this)
        }
    }

    MouseArea {
        id: notifArea
        anchors.fill: parent
        onClicked: event => {
            event.accepted = true;
            if (notificationService && event.button === Qt.LeftButton) {
                const actions = notificationItem.notificationData.actions;
                if (actions?.length > 0)
                    notificationService.attemptInvokeAction(notificationItem.notificationData.notificationId, "default");
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 14

        IconImage {
            id: realAppIcon
            visible: notificationData?.appIcon?.length > 0
            width: 32
            height: 32
            source: notificationData?.appIcon ? Quickshell.iconPath(notificationData.appIcon) : ""
            smooth: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    text: notificationData?.appName || "App"
                    color: Appearence.colors.textColor
                    font.pixelSize: 14
                    font.family: Appearence.font.readFont
                    font.weight: Font.Bold
                }

                Item {
                    Layout.fillWidth: true
                }

                StyledText {
                    text: notificationData?.time ? DateTime.formatTimestamp(notificationData.time) : "Now"
                    color: Appearence.colors.textMutedColor
                    font.pixelSize: 10
                    font.family: Appearence.font.readFont
                    font.weight: Font.Medium
                }
            }

            StyledText {
                text: notificationData?.summary || "Notification"
                color: Appearence.colors.textColor
                font.pixelSize: 12
                font.weight: Font.Medium
                font.family: Appearence.font.readFont
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }

            StyledText {
                text: notificationData?.body || ""
                color: Appearence.colors.textMutedColor
                font.pixelSize: 12
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.family: Appearence.font.readFont
                maximumLineCount: 2
                elide: Text.ElideRight
                visible: text !== "" && text !== notificationData.summary
            }
        }

        
        Button {
            id: dismissBtn
            width: 24
            height: 24
            hoverEnabled: true

            background: Rectangle {
                radius: 12
                color: dismissBtn.hovered ? Appearence.colors.errorColor : "transparent"

                Behavior on color {
                    animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                }
            }

            contentItem: StyledText {
                text: "✕"
                color: dismissBtn.hovered ? Appearence.colors.baseColor : Appearence.colors.textMutedColor
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
}
