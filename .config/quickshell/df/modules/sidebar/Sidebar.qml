import qs
import qs.services
import qs.modules.common
import qs.modules.session

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root

    property int hyprlandGapsOut: 4
    property int elevationMargin: 2
    property int sidebarWidth: 420
    property int sidebarPadding: 12

    PanelWindow {
        id: sidebar
        visible: GlobalStates.sidebarOpen
        function hide() {
            GlobalStates.sidebarOpen = false;
        }

        exclusiveZone: 0
        implicitWidth: root.sidebarWidth
        WlrLayershell.namespace: "quickshell:sidebar"
        color: "transparent"

        anchors {
            top: true
            right: true
            bottom: true
        }

        HyprlandFocusGrab {
            id: grab
            windows: [sidebar]
            active: GlobalStates.sidebarOpen
            onCleared: () => {
                if (!active)
                    sidebar.hide();
            }
        }

        Loader {
            id: sidebarContentLoader
            active: GlobalStates.sidebarOpen
            anchors {
                fill: parent
                margins: root.hyprlandGapsOut
                leftMargin: root.elevationMargin
            }
            width: root.sidebarWidth - root.hyprlandGapsOut - root.elevationMargin
            height: parent.height - root.hyprlandGapsOut * 2

            focus: GlobalStates.sidebarOpen
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    sidebar.hide();
                }
            }

            sourceComponent: Rectangle {
                anchors.fill: parent
                color: "#11111b" // Darker base background
                radius: 12
                border.width: 1
                border.color: "#313244"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 24

                    // Enhanced Header with uptime
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 25
                        color: "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.verticalCenter: parent.verticalCenter

                            // Enhanced uptime section

                            Rectangle {
                                implicitWidth: 8
                                implicitHeight: 8
                                radius: 4
                                color: "#a6e3a1"
                            }
                            StyledText {
                                text: `Uptime ${DateTime.uptime}`
                                color: "#cdd6f4"
                                font.pixelSize: 13
                                font.family: Appearence.font.readFont
                                font.weight: Font.Medium
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Button {
                                id: powerBtn
                                hoverEnabled: true
                                onClicked: {
                                    GlobalStates.isSessionOpen = !GlobalStates.isSessionOpen;
                                }
                                background: Rectangle {
                                    radius: 32
                                    color: powerBtn.hovered ? "#f38ba8" : "#313244"
                                    border.width: 1
                                    border.color: powerBtn.hovered ? "#f38ba8" : "#45475a"

                                    Behavior on color {
                                        animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                                    }
                                    Behavior on border.color {
                                        animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                                    }
                                }

                                contentItem: StyledText {
                                    text: "⏻"
                                    color: powerBtn.hovered ? "#11111b" : "#cdd6f4"
                                    font.pixelSize: 16
                                    anchors.centerIn: parent

                                    Behavior on color {
                                        animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                                    }
                                }
                            }
                        }
                    }

                    // Enhanced quick toggles section
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        color: "#181825"
                        radius: 12
                        border.width: 1
                        border.color: "#313244"

                        GridLayout {
                            anchors.centerIn: parent
                            columns: 5
                            columnSpacing: 12
                            rowSpacing: 12

                            // WiFi toggle
                            WifiToggleMenu {}

                            // Bluetooth toggle
                            BluetoothToggleMenu {}

                            // DND toggle
                            PpdToggleMenu {}
                            // Freeze toggle
                            GamemodeToggleMenu {}
                        }
                    }

                    // Enhanced notifications section
                    Notifications {}
                }
            }
        }
    }
}
