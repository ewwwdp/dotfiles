import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import QtQuick.Controls.Fusion
import qs
import qs.modules.common
import qs.services

Rectangle {
    id: root
    required property LockContext context
    property var screenName
    readonly property color backgroundFallback: "#11111b"
    readonly property color textColor: "#cdd6f4"
    readonly property color textMuted: Qt.rgba(0xcd / 255, 0xd6 / 255, 0xf4 / 255, 0.75)
    readonly property color inputBg: "#181825"
    readonly property color inputText: "#cdd6f4"
    readonly property color borderColor: "#313244"
    readonly property color failColor: "#f38ba8"
    readonly property color accentColor: "#89b4fa"

    color: backgroundFallback

    Image {
        id: blurPass1
        anchors.fill: parent
        source: WallpaperConfig.wallpaperForScreen(root.screenName)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        opacity: status === Image.Ready ? 1 : 0

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 2.0
            blurMax: 30
            blurMultiplier: 1
        }
        Behavior on opacity {
            animation: Appearence.animation.elementMoveEnter.numberAnimation.createObject(this)
        }
    }

    // Date label
    Text {
        id: dateLabel
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -300
        }

        color: textMuted
        font.family: Appearence.font.nerdFont
        font.pixelSize: 22
        renderType: Text.NativeRendering

        text: {
            const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
            const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
            const d = DateTime.date;
            return `${days[d.getDay()]}, ${months[d.getMonth()]} ${d.getDate()}`;
        }
    }

    // Time label
    Text {
        id: timeLabel
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -200
        }

        color: textColor
        font.family: Appearence.font.nerdFont
        font.weight: Font.ExtraBold
        font.pixelSize: 95
        renderType: Text.NativeRendering
        text: DateTime.time
    }

    // Password input field
    ColumnLayout {
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        spacing: 10

        Rectangle {
            id: inputFieldContainer
            implicitWidth: 250
            implicitHeight: 60
            color: inputBg
            radius: 12
            border.width: root.context.showFailure ? 2 : 1
            border.color: {
                if (root.context.showFailure)
                    return failColor;
                if (passwordField.activeFocus)
                    return accentColor;
                return borderColor;
            }

            Behavior on border.color {
                animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
            }

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#0a0a0a"
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 3
                shadowOpacity: 0.6
                shadowBlur: 0.4
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 0

                TextField {
                    id: passwordField
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    background: Rectangle {
                        color: "transparent"
                    }
                    color: inputText
                    font.family: Appearence.font.nerdFont
                    font.pixelSize: 16

                    echoMode: TextInput.Password
                    passwordCharacter: "●"
                    passwordMaskDelay: 0
                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment: TextInput.AlignVCenter
                    inputMethodHints: Qt.ImhSensitiveData
                    focus: true
                    enabled: !root.context.unlockInProgress

                    font.letterSpacing: 4

                    leftPadding: 8
                    rightPadding: 8
                    topPadding: 4
                    bottomPadding: 4

                    onTextChanged: root.context.currentText = this.text

                    onAccepted: root.context.tryUnlock()

                    Connections {
                        target: root.context
                        function onCurrentTextChanged() {
                            passwordField.text = root.context.currentText;
                        }
                    }
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: `󰌾 ${Quickshell.env("USER")}`
            color: textMuted
            font.family: Appearence.font.nerdFont
            font.pixelSize: 16
        }

        Text {
            visible: root.context.showFailure
            Layout.alignment: Qt.AlignHCenter
            text: `Incorrect password (${root.context.attemptCount || 0})`
            color: failColor
            font.family: Appearence.font.nerdFont
            font.pixelSize: 16
        }
    }
}
