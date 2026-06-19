import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs
import qs.modules.common
import qs.services

MenuContent {
    id: root

    RowLayout {
        width: parent.width
        spacing: 4

        StyledText {
            text: BluetoothService.hasConnected ? "" : ""
            font.family: Appearence.font.nerdFont
            font.pixelSize: 15
            color: BluetoothService.ready ? Appearence.colors.accentColor : Appearence.colors.textMutedColor
        }

        StyledText {
            Layout.fillWidth: true
            text: BluetoothService.adapter ? `Bluetooth (${BluetoothService.adapter.adapterId})` : "Bluetooth"
            font.pixelSize: 13
            color: Appearence.colors.whiteColor
        }

        Button {
            id: scanBtn
            implicitWidth: 22
            implicitHeight: 22
            hoverEnabled: true
            enabled: BluetoothService.adapter != null
            background: Rectangle {
                radius: 4
                color: scanBtn.hovered ? Appearence.colors.hoverColor : "transparent"
            }
            contentItem: StyledText {
                text: BluetoothService.adapter?.discovering ? "" : ""
                font.family: Appearence.font.nerdFont
                font.pixelSize: 11
                color: Appearence.colors.accentColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: BluetoothService.toggleScan()
        }
    }

    Rectangle {
        width: parent.width
        implicitHeight: 1
        visible: BluetoothService.adapter?.devices?.values?.length > 0
        color: Appearence.colors.borderColor
    }

    Repeater {
        model: BluetoothService.getSortedDevices()

        delegate: Item {
            required property BluetoothDevice modelData
            readonly property var device: modelData
            readonly property bool isPaired: device.paired || device.bonded
            property bool showActions: false

            x: 2
            width: parent.width - 4
            implicitHeight: (showActions && isPaired ? 64 : 36)
            clip: true

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            MouseArea {
                id: deviceArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: event => {
                    if (event.button === Qt.RightButton && isPaired) {
                        showActions = !showActions;
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height - 4
                    radius: 4
                    color: deviceArea.containsMouse ? Appearence.colors.hoverColor : "transparent"

                    Column {
                        anchors.fill: parent
                        spacing: 4

                        RowLayout {
                            width: parent.width
                            implicitHeight: 34
                            spacing: 4

                            StyledText {
                                text: device.connected ? "" : device.bonded ? "" : ""
                                font.family: Appearence.font.nerdFont
                                font.pixelSize: 13
                                color: device.connected ? Appearence.colors.accentColor : Appearence.colors.textMutedColor
                                Layout.leftMargin: 6
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                StyledText {
                                    Layout.fillWidth: true
                                    text: device.name || device.deviceName || "Unknown"
                                    font.pixelSize: 13
                                    color: Appearence.colors.whiteColor
                                    elide: Text.ElideRight
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: device.address || ""
                                    font.pixelSize: 11
                                    color: Appearence.colors.textMutedColor
                                    elide: Text.ElideRight
                                }
                            }

                            Button {
                                id: mainBtn
                                implicitWidth: 54
                                implicitHeight: 20
                                hoverEnabled: true
                                Layout.rightMargin: 6
                                background: Rectangle {
                                    radius: 4
                                    color: mainBtn.hovered ? Appearence.colors.accentColor : "transparent"
                                    border.color: mainBtn.hovered ? Appearence.colors.accentColor : Appearence.colors.textMutedColor
                                    border.width: 1
                                }
                                contentItem: StyledText {
                                    text: {
                                        if (device.connected)
                                            return "Disc.";
                                        if (device.pairing)
                                            return "...";
                                        if (device.paired)
                                            return "Conn.";
                                        return "Pair";
                                    }
                                    font.pixelSize: 10
                                    color: mainBtn.hovered ? Appearence.colors.baseColor : Appearence.colors.textColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    if (device.connected)
                                        device.disconnect();
                                    else if (device.paired)
                                        device.connect();
                                    else
                                        device.pair();
                                }
                            }

                            Button {
                                id: moreBtn
                                implicitWidth: 18
                                implicitHeight: 20
                                hoverEnabled: true
                                visible: isPaired
                                Layout.rightMargin: 6
                                background: Rectangle {
                                    radius: 4
                                    color: moreBtn.hovered || showActions ? Appearence.colors.hoverColor : "transparent"
                                }
                                contentItem: StyledText {
                                    text: "⋯"
                                    font.pixelSize: 11
                                    color: Appearence.colors.textMutedColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: showActions = !showActions
                            }
                        }

                        Rectangle {
                            width: parent.width
                            implicitHeight: showActions && isPaired ? 24 : 0
                            visible: showActions && isPaired
                            color: "transparent"

                            RowLayout {
                                anchors.left: parent.left
                                spacing: 4

                                Button {
                                    implicitWidth: 48
                                    implicitHeight: 20
                                    hoverEnabled: true
                                    background: Rectangle {
                                        radius: 4
                                        color: parent.hovered ? Appearence.colors.errorColor : "transparent"
                                        border.color: parent.hovered ? Appearence.colors.errorColor : Appearence.colors.textMutedColor
                                        border.width: 1
                                    }
                                    contentItem: StyledText {
                                        text: "Remove"
                                        font.pixelSize: 10
                                        color: parent.hovered ? Appearence.colors.baseColor : Appearence.colors.textMutedColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: device.forget()
                                }

                                Button {
                                    implicitWidth: 48
                                    implicitHeight: 20
                                    hoverEnabled: true
                                    background: Rectangle {
                                        radius: 4
                                        color: parent.hovered ? Appearence.colors.accentColor : "transparent"
                                        border.color: parent.hovered ? Appearence.colors.accentColor : Appearence.colors.textMutedColor
                                        border.width: 1
                                    }
                                    contentItem: StyledText {
                                        text: device.trusted ? "Untrust" : "Trust"
                                        font.pixelSize: 10
                                        color: parent.hovered ? Appearence.colors.baseColor : Appearence.colors.textMutedColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: device.trusted = !device.trusted
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    StyledText {
        width: parent.width
        visible: !BluetoothService.adapter || BluetoothService.adapter.devices.values.length === 0
        color: Appearence.colors.whiteColor
        opacity: 0.5
        text: BluetoothService.adapter ? "No devices found" : "No Bluetooth adapter"
        font.pixelSize: 12
        horizontalAlignment: Text.AlignHCenter
        padding: 4
    }
}
