import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.modules.common
import qs.services

Scope {
    id: root

    property bool shouldShowOsd: false

    // Combined monitor modes data
    readonly property var monitorModes: [
        {
            mode: "hdmi",
            icon: "\uf26c",
            label: "External Only"
        },
        {
            mode: "default",
            icon: "\uf109",
            label: "Internal Only"
        },
        {
            mode: "mirrored",
            icon: "\uf24d",
            label: "Mirror Displays"
        },
        {
            mode: "splited",
            icon: "\udb83\ude51",
            label: "Extended Display"
        }
    ]
    LazyLoader {
        active: root.shouldShowOsd

        PanelWindow {
            id: panelWindow
            HyprlandFocusGrab {
                windows: [panelWindow]
                active: root.shouldShowOsd
                onCleared: () => {
                    if (!active)
                        root.shouldShowOsd = false;
                }
            }
            implicitWidth: 600
            implicitHeight: 180
            color: "transparent"
            property int selectedIndex: -1
            Rectangle {
                focus: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        root.shouldShowOsd = false;
                    }

                }
                anchors.fill: parent
                radius: 20
                color: "#cc000000"
                border.color: Appearence.colors.accentColor
                border.width: 2

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: 30
                    }
                    spacing: 20

                    // Monitor mode buttons
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 4
                        rowSpacing: 10
                        columnSpacing: 10

                        Repeater {
                            model: root.monitorModes

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.minimumHeight: 80
                                radius: 12
                                color: (mouseArea.containsMouse || index === panelWindow.selectedIndex) ? Appearence.colors.accentColor : "#30ffffff"
                                border.color: (mouseArea.containsMouse || index === panelWindow.selectedIndex) ? Appearence.colors.accentColor : "transparent"
                                border.width: 2

                                Behavior on color {
                                    animation: Appearence.animation.elementMove.colorAnimation.createObject(this)
                                }

                                Behavior on border.color {
                                    animation: Appearence.animation.elementMove.colorAnimation.createObject(this)
                                }

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 8

                                    StyledText {
                                        Layout.alignment: Qt.AlignHCenter
                                        font {
                                            pixelSize: 40
                                            family: Appearence.font.nerdFont
                                        }
                                        text: modelData.icon
                                        color: (mouseArea.containsMouse || index === panelWindow.selectedIndex) ? "#000000" : "#ffffff"
                                    }

                                    StyledText {
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.maximumWidth: parent.parent.width - 10
                                        text: modelData.label
                                        font {
                                            family: Appearence.font.readFont
                                            pixelSize: 11
                                        }
                                        color: (mouseArea.containsMouse || index === panelWindow.selectedIndex) ? "#000000" : "#ffffff"
                                        horizontalAlignment: Text.AlignHCenter
                                        wrapMode: Text.WordWrap
                                    }
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    enabled: {
                                        switch (modelData.mode) {
                                        case "hdmi":
                                            return MonitorService.hasExternalMonitor;
                                        case "default":
                                            return MonitorService.hasInternalMonitor;
                                        case "mirrored" || "splited":
                                            return MonitorService.hasExternalMonitor && MonitorService.hasInternalMonitor;
                                        default:
                                            return false;
                                        }
                                    }
                                    onClicked: {
                                        Quickshell.execDetached(["sh", "-c", `${Quickshell.shellDir}/scripts/change-monitor.sh ${modelData.mode}`]);
                                        closeTimer.start();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Close timer (short delay for visual feedback)
    Timer {
        id: closeTimer
        interval: 100
        onTriggered: root.shouldShowOsd = false
    }

    // Auto-hide timer (if no selection is made)
    Timer {
        id: autoHideTimer
        interval: 5000
        running: root.shouldShowOsd
        onTriggered: root.shouldShowOsd = false
    }

    IpcHandler {
        target: "changeMonitor"
        function showOsd() {
            MonitorService.update();
            root.shouldShowOsd = true;
        }
    }
}
