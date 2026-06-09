import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common

PanelWindow {
    id: root

    required property PolkitAuth auth

    property color accent: Appearence.colors.polkitAccent
    property color background: Appearence.colors.polkitBackground
    property color foreground: Appearence.colors.polkitText
    property color borderColor: Appearence.colors.polkitBorder
    property color borderError: Appearence.colors.polkitBorderError
    property color scrim: Appearence.colors.polkitScrim

    readonly property int cornerRadius: 12
    property int contentMargin: 12
    property int fieldHeight: 42

    visible: auth.dialogVisible
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "df-polkit"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    readonly property int cardWidth: Math.min(312, Math.max(260, root.width - 16))
    readonly property int cardHeight: root.height > 0 ? Math.min(fieldHeight + contentMargin * 2, root.height - 16) : fieldHeight + contentMargin * 2

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
        border.width: Math.max(1, 2)
        border.color: auth.errorFlash ? root.borderError : root.borderColor

        Behavior on border.color {
            ColorAnimation { duration: 200 }
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

        Row {
            anchors.fill: parent
            anchors.margins: root.contentMargin
            spacing: 14

            Text {
                text: "\uf023"
                color: auth.errorFlash ? Appearence.colors.polkitTextError : root.accent
                font.family: Appearence.font.nerdFont
                font.pixelSize: 24
                width: 26
                height: root.fieldHeight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Item {
                width: parent.width - 40
                height: root.fieldHeight

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    verticalAlignment: TextInput.AlignVCenter
                    activeFocusOnPress: true
                    clip: true
                    selectionColor: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.45)
                    selectedTextColor: root.foreground
                    font.family: Appearence.font.nerdFont
                    font.pixelSize: 24
                    echoMode: auth.responseVisible ? TextInput.Normal : TextInput.Password
                    passwordCharacter: "\u2022"
                    color: auth.errorFlash ? Appearence.colors.polkitTextError : root.foreground
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
                }

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: auth.errorFlash ? "Wrong" : (auth.submitted ? "Checking..." : "Enter password")
                    color: auth.errorFlash ? Appearence.colors.polkitTextError : root.foreground
                    opacity: auth.errorFlash ? 1 : 0.36
                    font.family: Appearence.font.nerdFont
                    font.pixelSize: 24
                    elide: Text.ElideRight
                    visible: passwordInput.visible && passwordInput.text.length === 0
                }

                Rectangle {
                    width: Math.max(1, 2)
                    height: 24
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: auth.errorFlash ? Appearence.colors.polkitTextError : root.foreground
                    visible: passwordInput.visible && passwordInput.activeFocus && passwordInput.text.length === 0 && !auth.submitted && !auth.errorFlash
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
