import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import qs
import qs.modules.common

Scope {
    id: bar
    Variants {
        // For each monitor
        model: Quickshell.screens
        LazyLoader {
            id: barLoader
            active: true
            required property ShellScreen modelData
            component: PanelWindow {
                id: barRoot
                screen: barLoader.modelData
                exclusionMode: ExclusionMode.Normal
                exclusiveZone: 24
                WlrLayershell.namespace: "quickshell:bar"
                implicitHeight: 24
                color: Appearence.colors.barBackgroundColor
                anchors {
                    top: true
                    bottom: false
                    left: true
                    right: true
                }

                Rectangle {
                    id: barBackground
                    anchors.fill: parent
                    color: Appearence.colors.barBackgroundColor

                    // --- Left + Right modules in a layout
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6

                        // Left side - Workspaces
                        Workspaces {
                            barRoot: barRoot
                            Layout.fillHeight: true
                            Layout.preferredWidth: implicitWidth
                        }

                        // Center spacer - allows clock to be centered
                        Item {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                        }

                        Item {
                            Layout.fillHeight: true
                            Layout.minimumWidth: rightSideLayout.implicitWidth
                            Layout.maximumWidth: barBackground.width * 0.45

                            // Background rectangle
                            Rectangle {
                                id: rightBackground
                                anchors.centerIn: parent
                                color: Appearence.colors.pureBlackColor
                                width: rightSideLayout.implicitWidth + 22
                                height: parent.height // Leave small margin from top/bottom
                                radius: height / 2
                            }

                            // Right side content
                            RowLayout {
                                id: rightSideLayout
                                spacing: 16  // Slightly increased spacing for better visual separation
                                anchors.centerIn: rightBackground
                                anchors.verticalCenter: rightBackground.verticalCenter

                                IdleInhibitor {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: implicitWidth
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                SoundMic {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: implicitWidth
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                NetworkWidget {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: implicitWidth
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                BluetoothWidget {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: implicitWidth
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                LangLayout {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: implicitWidth
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                SysTray {
                                    bar: barRoot
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: implicitWidth
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                MenuWidget {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: implicitWidth
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }
                        }
                    }
                }

                // Center clock - positioned absolutely to stay centered
                ClockWidget {
                    anchors.centerIn: parent
                    z: 1 // Ensure it's above other elements
                }
            }
        }
    }
}
