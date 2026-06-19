import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.modules.common

PanelWindow {
    id: root

    required property PolkitAuth auth

    property color accent: Appearence.colors.accentColor
    property color background: Appearence.colors.popupBgColor
    property color foreground: Appearence.colors.whiteColor
    property color borderColor: Appearence.colors.popupBorderColor
    property color borderError: Appearence.colors.errorColor
    property color scrim: Appearence.colors.scrimColor

    readonly property int cornerRadius: 10

    visible: auth.dialogVisible
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"
    WlrLayershell.namespace: "quickshell:polkitdialog"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    readonly property int cardWidth: Math.min(400, Math.max(320, root.width - 16))
    readonly property int cardHeight: Math.min(contentColumn.implicitHeight + 16, root.height - 16)

    Rectangle {
        anchors.fill: parent
        color: root.scrim
    }

    MouseArea {
        anchors.fill: parent
        onClicked: refocus()
    }

    Rectangle {
        id: card
        width: root.cardWidth
        height: root.cardHeight
        radius: root.cornerRadius
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: auth.shakeOffset
        color: root.background
        border.width: 1
        border.color: auth.errorFlash ? root.borderError : root.borderColor

        Behavior on border.color {
            ColorAnimation {
                duration: 200
            }
        }

        clip: true

        Item {
            id: keyCatcher
            anchors.fill: parent
            focus: true

            Keys.priority: Keys.BeforeItem
            Keys.onPressed: function (event) {
                if (event.key === Qt.Key_Escape) {
                    auth.cancelRequest();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (auth.responseRequired)
                        auth.submitResponse(passwordInput.text);
                    event.accepted = true;
                }
            }
        }

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "\uf023"
                    font.family: Appearence.font.nerdFont
                    font.pixelSize: 20
                    color: auth.errorFlash ? root.borderError : root.accent
                }

                Text {
                    Layout.fillWidth: true
                    text: "Authentication"
                    font.pixelSize: 16
                    color: root.foreground
                }
            }

            Text {
                Layout.fillWidth: true
                text: auth.currentMessage
                font.pixelSize: 13
                color: root.foreground
                opacity: 0.7
                wrapMode: Text.Wrap
                visible: auth.currentMessage.length > 0
            }

            Text {
                Layout.fillWidth: true
                text: auth.currentSupplementary
                font.pixelSize: 12
                color: root.foreground
                opacity: 0.5
                wrapMode: Text.Wrap
                visible: auth.currentSupplementary.length > 0
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: inputRow.implicitHeight + 10
                color: Appearence.colors.popupBorderColor
                radius: 0

                RowLayout {
                    id: inputRow
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 5

                    Text {
                        text: "\uf13e"
                        font.family: Appearence.font.nerdFont
                        font.pixelSize: 16
                        color: auth.errorFlash ? root.borderError : root.accent
                    }

                    TextInput {
                        id: passwordInput
                        Layout.fillWidth: true
                        verticalAlignment: TextInput.AlignVCenter
                        activeFocusOnPress: true
                        clip: true
                        selectionColor: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.45)
                        selectedTextColor: root.foreground
                        font.family: Appearence.font.nerdFont
                        font.pixelSize: 16
                        echoMode: auth.responseVisible ? TextInput.Normal : TextInput.Password
                        passwordCharacter: "\u2022"
                        color: auth.errorFlash ? root.borderError : root.foreground
                        cursorVisible: activeFocus && !auth.submitted && !auth.errorFlash
                        readOnly: auth.submitted || auth.errorFlash
                        enabled: auth.dialogVisible
                        visible: true
                        onAccepted: auth.submitResponse(passwordInput.text)
                        Keys.onPressed: function (event) {
                            if (event.key === Qt.Key_Escape) {
                                auth.cancelRequest();
                                event.accepted = true;
                            }
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: auth.errorFlash ? "Wrong password" : (auth.submitted ? "Checking..." : "Enter password")
                            color: auth.errorFlash ? root.borderError : root.foreground
                            opacity: auth.errorFlash ? 1 : 0.36
                            font.family: Appearence.font.nerdFont
                            font.pixelSize: 16
                            elide: Text.ElideRight
                            visible: passwordInput.visible && passwordInput.text.length === 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            enabled: passwordInput.visible
                            onClicked: passwordInput.forceActiveFocus()
                        }
                    }
                }
            }
        }
    }

    function refocus() {
        if (!auth.dialogVisible)
            return;
        passwordInput.forceActiveFocus();
    }

    Connections {
        target: auth

        function onRequestStarted() {
            passwordInput.text = "";
            Qt.callLater(root.refocus);
        }

        function onAuthenticationFailed() {
            passwordInput.text = "";
            Qt.callLater(root.refocus);
        }
    }
}
