import qs
import qs.services
import qs.modules.notificationPopup
import qs.modules.common
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: notifRoot
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: Appearence.colors.surfaceColor
    radius: 12
    border.width: 1
    border.color: Appearence.colors.borderColor

    property bool isDndFocused: false
    property bool isClearFocused: false

    function activateDnd() {
        GlobalStates.dndEnabled = !GlobalStates.dndEnabled;
    }

    function activateClear() {
        NotificationService.discardAllNotifications();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        
        RowLayout {
            Layout.fillWidth: true

            StyledText {
                text: "Notifications"
                        color: Appearence.colors.textColor
                font.pixelSize: 18
                font.weight: Font.Bold
            }

            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 16
                radius: 8
                color: Appearence.colors.errorColor

                StyledText {
                    anchors.centerIn: parent
                    text: NotificationService.list.length
                    color: Appearence.colors.baseColor
                    font.pixelSize: 10
                    font.weight: Font.Bold
                }
            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 8

                Button {
                    id: silentBtn
                    hoverEnabled: true
                    onClicked: notifRoot.activateDnd()
                    background: Rectangle {
                        color: GlobalStates.dndEnabled ? (silentBtn.hovered ? "#585b70" : Appearence.colors.surfaceHoverColor) : (silentBtn.hovered ? Appearence.colors.surfaceHoverColor : Appearence.colors.borderColor)
                        radius: 6
                        border.width: notifRoot.isDndFocused ? 2 : 1
                        border.color: silentBtn.hovered || notifRoot.isDndFocused ? Appearence.colors.textMutedColor : Appearence.colors.surfaceHoverColor

                        Behavior on color {
                            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                        }
                        Behavior on border.color {
                            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                        }
                    }

                    contentItem: StyledText {
                        text: GlobalStates.dndEnabled ? "🔔 Notify" : "🔕 Silent"
                color: Appearence.colors.textColor
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        anchors.centerIn: parent

                        Behavior on color {
                            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                        }
                    }
                }

                Button {
                    id: clearBtn
                    hoverEnabled: true

                    background: Rectangle {
                        color: clearBtn.hovered ? Appearence.colors.errorColor : Appearence.colors.borderColor
                        radius: 6
                        border.width: notifRoot.isClearFocused ? 2 : 1
                        border.color: clearBtn.hovered || notifRoot.isClearFocused ? Appearence.colors.errorColor : Appearence.colors.surfaceHoverColor

                        Behavior on color {
                            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                        }
                    }

                    contentItem: StyledText {
                        text: "✕ Clear"
                        color: clearBtn.hovered ? Appearence.colors.baseColor : Appearence.colors.textColor
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        anchors.centerIn: parent

                        Behavior on color {
                            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                        }
                    }
                    onClicked: notifRoot.activateClear()
                }
            }
        }

        
        ListView {
            id: notifList
            visible: NotificationService.list.length > 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12
            clip: true
            model: NotificationService.list.slice().reverse()

            delegate: Notification {
                width: notifList.width
                height: 90
                Notification {
                    anchors.fill: parent
                    notificationData: modelData
                }
            }

            ScrollBar.vertical: ScrollBar {
                contentItem: Rectangle {
                    radius: 3
                    height: 10
                    color: Appearence.colors.whiteColor
                }
            }
        }

        Item {
            visible: NotificationService.list.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 12

                StyledText {
                    text: "🔔"
                    font.pixelSize: 48
                    Layout.alignment: Qt.AlignHCenter
                }

                StyledText {
                    text: "No new notifications"
                    font.family: Appearence.font.readFont
                    color: Appearence.colors.textMutedColor
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
