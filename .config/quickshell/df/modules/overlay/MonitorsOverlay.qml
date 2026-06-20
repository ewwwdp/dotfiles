import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.modules.common
import qs.services

Scope {
    id: root

    property bool shouldShowOsd: false

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

                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 4
                        rowSpacing: 10
                        columnSpacing: 10

                        Repeater {
                            model: MonitorService.monitorModes

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.minimumHeight: 80
                                radius: 12
                                color: (mouseArea.containsMouse || modelData.mode === MonitorService.currentMode) ? Appearence.colors.accentColor : "#30ffffff"
                                border.color: (mouseArea.containsMouse || modelData.mode === MonitorService.currentMode) ? Appearence.colors.accentColor : "transparent"
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
                                        color: (mouseArea.containsMouse || modelData.mode === MonitorService.currentMode) ? Appearence.colors.pureBlackColor : Appearence.colors.whiteColor
                                    }

                                    StyledText {
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.maximumWidth: parent.parent.width - 10
                                        text: modelData.label
                                        font {
                                            family: Appearence.font.readFont
                                            pixelSize: 11
                                        }
                                        color: (mouseArea.containsMouse || modelData.mode === MonitorService.currentMode) ? Appearence.colors.pureBlackColor : Appearence.colors.whiteColor
                                        horizontalAlignment: Text.AlignHCenter
                                        wrapMode: Text.WordWrap
                                    }
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    enabled: MonitorService.hasMultipleMonitors
                                    onClicked: {
                                        MonitorService.switchMode(modelData.mode);
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

    Timer {
        id: closeTimer
        interval: 100
        onTriggered: root.shouldShowOsd = false
    }

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
            MonitorService.refreshModes();
            root.shouldShowOsd = true;
        }
    }
}
