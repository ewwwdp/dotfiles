import qs
import qs.modules.common
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
    id: root

    // Updated colors to match CSS
    property color backgroundColor: "#13141c"  // window background-color
    property color buttonColor: "#06060d"     // button background-color
    property color buttonHoverColor: "#181923" // button:hover background-color

    default property list<LogoutButton> buttons

    PanelWindow {
        id: w
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        color: "transparent"

        contentItem {
            focus: true
            Keys.onPressed: event => {
                if (event.key == Qt.Key_Escape)
                    GlobalStates.isSessionOpen = false;
                else {
                    for (let i = 0; i < buttons.length; i++) {
                        let button = buttons[i];
                        if (event.key == button.keybind)
                            button.exec();
                    }
                }
            }
        }

        anchors {
            top: true
            left: true
            bottom: true
            right: true
        }

        Rectangle {
            color: backgroundColor
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
                onClicked: GlobalStates.isSessionOpen = false

                GridLayout {
                    anchors.centerIn: parent
                    width: parent.width * 0.75
                    height: parent.height * 0.75
                    columns: 3
                    columnSpacing: 0
                    rowSpacing: 0

                    Repeater {
                        model: buttons
                        delegate: Rectangle {
                            required property LogoutButton modelData
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: ma.containsMouse ? buttonHoverColor : buttonColor

                            // Removed border to match CSS (no border specified)
                            border.width: 0

                            MouseArea {
                                id: ma
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: modelData.exec()
                            }

                            StyledText {
                                id: icon
                                anchors.centerIn: parent
                                text: modelData.icon
                                color: "#D4BFF9"
                                font.pixelSize: 150
                            }

                            StyledText {
                                anchors {
                                    top: icon.bottom
                                    topMargin: 20
                                    horizontalCenter: parent.horizontalCenter
                                }
                                text: modelData.text

                                font.family: "JetBrains Mono, Iosevka Nerd Font, archcraft, sans-serif"
                                font.pixelSize: 14
                                font.weight: Font.Bold

                                color: "#ffffff"
                            }
                        }
                    }
                }
            }
        }
    }
}
