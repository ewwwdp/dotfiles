import qs.core
import qs.modules.common
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Item {
    id: root

    property color backgroundColor: Appearence.colors.wlogoutBgColor
    property color buttonColor: Appearence.colors.wlogoutButtonColor
    property color buttonHoverColor: Appearence.colors.wlogoutButtonHoverColor

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
                                color: Appearence.colors.wlogoutIconColor
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

                                color: Appearence.colors.whiteColor
                            }
                        }
                    }
                }
            }
        }
    }
}
