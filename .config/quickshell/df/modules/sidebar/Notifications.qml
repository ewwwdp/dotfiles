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
    color: "#181825"
    radius: 12
    border.width: 1
    border.color: "#313244"

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

        // Enhanced notifications header
        RowLayout {
            Layout.fillWidth: true

            StyledText {
                text: "Notifications"
                color: "#cdd6f4"
                font.pixelSize: 18
                font.weight: Font.Bold
            }

            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 16
                radius: 8
                color: "#f38ba8"

                StyledText {
                    anchors.centerIn: parent
                    text: NotificationService.list.length
                    color: "#11111b"
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
                        color: GlobalStates.dndEnabled ? (silentBtn.hovered ? "#585b70" : "#45475a") : (silentBtn.hovered ? "#45475a" : "#313244")
                        radius: 6
                        border.width: notifRoot.isDndFocused ? 2 : 1
                        border.color: silentBtn.hovered || notifRoot.isDndFocused ? "#6c7086" : "#45475a"

                        Behavior on color {
                            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                        }
                        Behavior on border.color {
                            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                        }
                    }

                    contentItem: StyledText {
                        text: GlobalStates.dndEnabled ? "🔔 Notify" : "🔕 Silent"
                        color: "#cdd6f4"
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
                        color: clearBtn.hovered ? "#f38ba8" : "#313244"
                        radius: 6
                        border.width: notifRoot.isClearFocused ? 2 : 1
                        border.color: clearBtn.hovered || notifRoot.isClearFocused ? "#f38ba8" : "#45475a"

                        Behavior on color {
                            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                        }
                    }

                    contentItem: StyledText {
                        text: "✕ Clear"
                        color: clearBtn.hovered ? "#11111b" : "#cdd6f4"
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

        // Enhanced notifications list
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
                    color: "#ffffff"
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
                    color: "#6c7086"
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
