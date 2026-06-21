import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Networking
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

                    property bool showPassword: false
                    property string passwordText: ""
                    property string connectError: ""
                    property bool connecting: false

                    x: 2
                    width: parent.width - 4
                    implicitHeight: showPassword ? (connectError.length > 0 ? 100 : 72) : 38

                    Connections {
                        target: net
                        function onConnectionFailed(reason) {
                            if (connecting) {
                                connecting = false;
                                showPassword = true;
                                connectError = reason === ConnectionFailReason.NoSecrets ? "Wrong password" : "Connection failed";
                            }
                        }
                        function onConnectedChanged() {
                            if (net.connected) {
                                showPassword = false;
                                passwordText = "";
                                connectError = "";
                                connecting = false;
                            }
                        }
                    }

                    Column {
                        anchors.fill: parent
                        spacing: 4

                        MouseArea {
                            width: parent.width
                            height: 34
                            hoverEnabled: true

                            Rectangle {
                                anchors.fill: parent
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
                                            text: net.connected ? "Disc." : (connecting ? "..." : (net.known ? "Forget" : "Conn."))
                                            font.pixelSize: 10
                                            color: parent.parent.hovered ? Appearence.colors.baseColor : Appearence.colors.textColor
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: {
                                            if (net.connected) {
                                                net.disconnect();
                                            } else if (net.known) {
                                                net.forget();
                                            } else if (showPassword) {
                                                if (passwordText.length > 0 && !connecting) {
                                                    connecting = true;
                                                    connectError = "";
                                                    net.connectWithPsk(passwordText);
                                                }
                                            } else if (net.security === WifiSecurityType.Open || net.security === WifiSecurityType.Owe) {
                                                net.connect();
                                            } else {
                                                showPassword = true;
                                                connectError = "";
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        RowLayout {
                            visible: showPassword
                            spacing: 4
                            x: 10
                            width: parent.width - 20

                            TextField {
                                id: passwordField
                                Layout.fillWidth: true
                                implicitHeight: 26
                                echoMode: TextInput.Password
                                passwordCharacter: "\u2022"
                                passwordMaskDelay: 0
                                placeholderText: "Enter password"
                                color: Appearence.colors.whiteColor
                                placeholderTextColor: Appearence.colors.textMutedColor
                                background: Rectangle {
                                    radius: 4
                                    color: Appearence.colors.surfaceColor
                                    border.color: Appearence.colors.borderColor
                                    border.width: 1
                                }
                                onAccepted: {
                                    if (text.length > 0 && !connecting) {
                                        connecting = true;
                                        connectError = "";
                                        net.connectWithPsk(text);
                                    }
                                }
                                onTextChanged: passwordText = text
                                Component.onCompleted: {
                                    forceActiveFocus();
                                }
                            }

                            Button {
                                implicitWidth: 26
                                implicitHeight: 26
                                hoverEnabled: true
                                background: Rectangle {
                                    radius: 4
                                    color: parent.hovered ? Appearence.colors.accentColor : "transparent"
                                    border.color: Appearence.colors.accentColor
                                    border.width: 1
                                }
                                contentItem: StyledText {
                                    text: "✓"
                                    font.pixelSize: 12
                                    color: parent.parent.hovered ? Appearence.colors.baseColor : Appearence.colors.accentColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    if (passwordField.text.length > 0 && !connecting) {
                                        connecting = true;
                                        connectError = "";
                                        net.connectWithPsk(passwordField.text);
                                    }
                                }
                            }

                            Button {
                                implicitWidth: 26
                                implicitHeight: 26
                                hoverEnabled: true
                                background: Rectangle {
                                    radius: 4
                                    color: parent.hovered ? Appearence.colors.errorColor : "transparent"
                                    border.color: Appearence.colors.textMutedColor
                                    border.width: 1
                                }
                                contentItem: StyledText {
                                    text: "✗"
                                    font.pixelSize: 12
                                    color: parent.parent.hovered ? Appearence.colors.whiteColor : Appearence.colors.textMutedColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    showPassword = false;
                                    passwordText = "";
                                    connectError = "";
                                    connecting = false;
                                }
                            }
                        }

                        StyledText {
                            width: parent.width
                            visible: connectError.length > 0
                            text: connectError
                            font.pixelSize: 10
                            color: Appearence.colors.errorColor
                            horizontalAlignment: Text.AlignHCenter
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
