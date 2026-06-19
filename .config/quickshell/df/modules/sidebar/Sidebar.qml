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
            focus: GlobalStates.sidebarOpen
            anchors {
                fill: parent
                margins: root.hyprlandGapsOut
                leftMargin: root.elevationMargin
            }
            width: root.sidebarWidth - root.hyprlandGapsOut - root.elevationMargin
            height: parent.height - root.hyprlandGapsOut * 2

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    sidebar.hide();
                } else if (sidebarContentLoader.item) {
                    if (event.key === Qt.Key_Down || event.key === Qt.Key_Right) {
                        let idx = sidebarContentLoader.item.focusedIndex;
                        if (idx < 0) idx = 0;
                        else idx = (idx + 1) % 5;
                        sidebarContentLoader.item.focusedIndex = idx;
                    } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Left) {
                        let idx = sidebarContentLoader.item.focusedIndex;
                        if (idx < 0) idx = 4;
                        else idx = (idx - 1 + 5) % 5;
                        sidebarContentLoader.item.focusedIndex = idx;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (sidebarContentLoader.item.focusedIndex >= 0) {
                            sidebarContentLoader.item.activateItem(sidebarContentLoader.item.focusedIndex);
                        }
                    }
                }
            }

            sourceComponent: Rectangle {
                id: contentRect
                anchors.fill: parent
                color: Appearence.colors.baseColor
                radius: 12
                border.width: 1
                    border.color: Appearence.colors.borderColor

                property int focusedIndex: -1

                function activateItem(index) {
                    switch (index) {
                    case 0: powerBtn.clicked(); break;
                    case 1: ppdToggle.activate(); break;
                    case 2: gamemodeToggle.activate(); break;
                    case 3: notifComponent.activateDnd(); break;
                    case 4: notifComponent.activateClear(); break;
                    }
                }

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
                                color: Appearence.colors.textColor
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
                                    color: powerBtn.hovered ? Appearence.colors.errorColor : Appearence.colors.borderColor
                                    border.color: powerBtn.hovered || contentRect.focusedIndex === 0 ? Appearence.colors.errorColor : Appearence.colors.surfaceHoverColor
                                    border.width: contentRect.focusedIndex === 0 ? 2 : 1

                                    Behavior on color {
                                        animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                                    }
                                    Behavior on border.color {
                                        animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                                    }
                                }

                                contentItem: StyledText {
                                    text: "⏻"
                                    color: powerBtn.hovered ? Appearence.colors.baseColor : Appearence.colors.textColor
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
                        color: Appearence.colors.surfaceColor
                        radius: 12
                        border.width: 1
                border.color: Appearence.colors.borderColor

                        GridLayout {
                            anchors.centerIn: parent
                            columns: 5
                            columnSpacing: 12
                            rowSpacing: 12

                            PpdToggleMenu {
                                id: ppdToggle
                                isFocused: contentRect.focusedIndex === 1
                            }
                            GamemodeToggleMenu {
                                id: gamemodeToggle
                                isFocused: contentRect.focusedIndex === 2
                            }
                        }
                    }

                    Notifications {
                        id: notifComponent
                        isDndFocused: contentRect.focusedIndex === 3
                        isClearFocused: contentRect.focusedIndex === 4
                    }
                }
            }
        }
    }
}
