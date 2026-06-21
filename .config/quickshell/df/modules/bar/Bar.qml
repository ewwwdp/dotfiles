import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import qs
import qs.modules.common

Scope {
    id: bar
    Variants {
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
                WlrLayershell.layer: WlrLayer.Top
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

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6

                        Workspaces {
                            barRoot: barRoot
                            Layout.fillHeight: true
                            Layout.preferredWidth: implicitWidth
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 10
                        }

                        Item {
                            Layout.fillHeight: true
                            Layout.minimumWidth: rightSideLayout.implicitWidth
                            Layout.maximumWidth: barBackground.width * 0.45

                            Rectangle {
                                id: rightBackground
                                anchors.centerIn: parent
                                color: Appearence.colors.pureBlackColor
                                width: rightSideLayout.implicitWidth + 22
                                height: parent.height - 4
                                radius: height / 2
                            }

                            RowLayout {
                                id: rightSideLayout
                                spacing: 14
                                anchors.centerIn: rightBackground
                                anchors.verticalCenter: rightBackground.verticalCenter

                                IdleI {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: implicitWidth
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                SoundMic {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: implicitWidth
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                BatteryWidget {
                                    visible: GlobalStates.isLaptop
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

                ClockWidget {
                    anchors.centerIn: parent
                    z: 1
                }
            }
        }
    }
}
