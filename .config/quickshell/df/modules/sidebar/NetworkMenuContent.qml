import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Networking
import qs
import qs.modules.common
import qs.services

MenuContent {
    id: root

    readonly property bool hasWifiDev: Networking.devices?.values?.some(d => d.type === DeviceType.Wifi) ?? false
    readonly property bool hasEthDev: Networking.devices?.values?.some(d => d.type === DeviceType.Wired) ?? false

    Loader {
        width: parent.width
        active: root.hasWifiDev
        visible: active
        sourceComponent: Column {
            spacing: 4

            RowLayout {
                width: parent.width
                spacing: 4

                StyledText {
                    text: "󰤨"
                    font.family: Appearence.font.nerdFont
                    font.pixelSize: 15
                    color: NetworkService.wifiConnected ? Appearence.colors.accentColor : Appearence.colors.textMutedColor
                }

                StyledText {
                    Layout.fillWidth: true
                    text: `WiFi (${NetworkService.wifi?.name ?? "..."})`
                    font.pixelSize: 13
                    color: Appearence.colors.whiteColor
                }

                Button {
                    id: scanBtn
                    implicitWidth: 22
                    implicitHeight: 22
                    hoverEnabled: true
                    background: Rectangle {
                        radius: 4
                        color: scanBtn.hovered ? Appearence.colors.hoverColor : "transparent"
                    }
                    contentItem: StyledText {
                        text: NetworkService.wifi?.scannerEnabled ? "" : ""
                        font.family: Appearence.font.nerdFont
                        font.pixelSize: 11
                        color: Appearence.colors.accentColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: NetworkService.toggleScan()
                }
            }
        }
    }

    Loader {
        width: parent.width
        active: root.hasEthDev
        visible: active
        sourceComponent: Column {
            spacing: 4

            Rectangle {
                width: parent.width
                implicitHeight: 1
                color: Appearence.colors.borderColor
                visible: root.hasWifiDev && root.hasEthDev
            }

            Repeater {
                model: NetworkService.getWiredDevices()

                delegate: Item {
                    required property WiredDevice modelData
                    readonly property var dev: modelData

                    x: 2
                    width: parent.width - 4
                    implicitHeight: 38

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width
                            height: parent.height - 4
                            radius: 4
                            color: parent.containsMouse ? Appearence.colors.hoverColor : "transparent"

                            RowLayout {
                                width: parent.width
                                implicitHeight: 34
                                spacing: 4

                                StyledText {
                                    text: "󰱓"
                                    font.family: Appearence.font.nerdFont
                                    font.pixelSize: 13
                                    color: dev.connected ? Appearence.colors.accentColor : Appearence.colors.textMutedColor
                                    Layout.leftMargin: 10
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: dev.name ?? "Ethernet"
                                    font.pixelSize: 12
                                    color: Appearence.colors.whiteColor
                                }

                                StyledText {
                                    text: !dev.hasLink ? "Unplugged" : (dev.connected ? "Connected" : "Disconnected")
                                    font.pixelSize: 11
                                    color: dev.connected ? Appearence.colors.accentColor : Appearence.colors.textMutedColor
                                }

                                Button {
                                    implicitWidth: 54
                                    implicitHeight: 20
                                    hoverEnabled: true
                                    visible: dev.hasLink
                                    Layout.rightMargin: 10
                                    background: Rectangle {
                                        radius: 4
                                        color: parent.hovered ? Appearence.colors.accentColor : "transparent"
                                        border.color: parent.hovered ? Appearence.colors.accentColor : Appearence.colors.textMutedColor
                                        border.width: 1
                                    }
                                    contentItem: StyledText {
                                        text: dev.connected ? "Disc." : "Conn."
                                        font.pixelSize: 10
                                        color: parent.parent.hovered ? Appearence.colors.baseColor : Appearence.colors.textColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: {
                                        let net = dev.network;
                                        if (dev.connected && net)
                                            net.disconnect();
                                        else if (net && !net.connected)
                                            net.connect();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Loader {
        width: parent.width
        active: root.hasWifiDev
        visible: active
        sourceComponent: Column {
            spacing: 4

            Rectangle {
                width: parent.width
                implicitHeight: 1
                visible: NetworkService.wifi?.networks?.values?.length > 0
                color: Appearence.colors.borderColor
            }

            Repeater {
                model: NetworkService.getSortedNetworks()

                delegate: Item {
                    required property WifiNetwork modelData
                    readonly property var net: modelData

                    x: 2
                    width: parent.width - 4
                    implicitHeight: 38

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width
                            height: parent.height - 4
                            radius: 4
                            color: parent.containsMouse ? Appearence.colors.hoverColor : "transparent"

                            RowLayout {
                                width: parent.width
                                implicitHeight: 34
                                spacing: 4

                                StyledText {
                                    text: "󰤨"
                                    font.family: Appearence.font.nerdFont
                                    font.pixelSize: 13
                                    color: net.connected ? Appearence.colors.accentColor : Appearence.colors.textMutedColor
                                    Layout.leftMargin: 10
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: net.name || net.ssid || "Unknown"
                                    font.pixelSize: 13
                                    color: Appearence.colors.whiteColor
                                    elide: Text.ElideRight
                                }

                                StyledText {
                                    text: `${Math.round(net.signalStrength * 100)}%`
                                    font.pixelSize: 11
                                    color: Appearence.colors.textMutedColor
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Button {
                                    implicitWidth: 54
                                    implicitHeight: 20
                                    hoverEnabled: true
                                    Layout.rightMargin: 10
                                    background: Rectangle {
                                        radius: 4
                                        color: parent.hovered ? Appearence.colors.accentColor : "transparent"
                                        border.color: parent.hovered ? Appearence.colors.accentColor : Appearence.colors.textMutedColor
                                        border.width: 1
                                    }
                                    contentItem: StyledText {
                                        text: net.connected ? "Disc." : "Conn."
                                        font.pixelSize: 10
                                        color: parent.parent.hovered ? Appearence.colors.baseColor : Appearence.colors.textColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: {
                                        if (net.connected)
                                            net.disconnect();
                                        else
                                            net.connect();
                                    }
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
        visible: root.hasWifiDev ? (NetworkService.wifi?.networks?.values?.length === 0) : !root.hasEthDev
        color: Appearence.colors.whiteColor
        opacity: 0.5
        text: root.hasWifiDev ? "No networks found" : (root.hasEthDev ? "" : "No network adapters")
        font.pixelSize: 12
        horizontalAlignment: Text.AlignHCenter
        padding: 4
    }
}
