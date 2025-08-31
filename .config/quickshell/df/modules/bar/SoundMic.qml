import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.services

Item {
    id: root
    property bool isMutedSink: Audio.sink?.audio?.muted ?? true
    property bool isMutedSource: Audio.source?.audio?.muted ?? true
    // Update properties when audio state changes
    Connections {
        target: Audio.sink?.audio ?? null
        function onMutedChanged() {
            if (!Audio.ready)
                return;
            root.isMutedSink = Audio.sink.audio.muted;
        }
    }

    Connections {
        target: Audio.source?.audio ?? null
        function onMutedChanged() {
            if (!Audio.ready)
                return;
            root.isMutedSource = Audio.source.audio.muted;
        }
    }
    implicitWidth: idleText.implicitWidth
    implicitHeight: 20
    Rectangle {
        id: statusLayout
        width: idleText.width + 16
        height: idleText.height + 5
        color: mouseArea.containsMouse ? Appearence.colors.hoverColor : "transparent"
        radius: 10
        anchors.centerIn: parent
        WheelHandler {
            onWheel: event => {
                const step = 0.01;
                if (event.angleDelta.y > 0) {
                    Audio.sink.audio.volume = Math.min(Audio.sink.audio.volume + step, 1);
                }
                if (event.angleDelta.y < 0) {
                    Audio.sink.audio.volume -= step;
                }
                event.accepted = true;
            }
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        }
        MouseArea {
            id: mouseArea
            hoverEnabled: true
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    Audio.sink.audio.muted = !Audio.sink.audio.muted;
                }
                if (mouse.button === Qt.RightButton) {
                    Audio.source.audio.muted = !Audio.source.audio.muted;
                }
                if (mouse.button === Qt.MiddleButton) {
                    Quickshell.execDetached(["pavucontrol"]);
                }
                mouse.accepted = true;
            }
            onEntered: balTooltip.tooltipVisible = true
            onExited: balTooltip.tooltipVisible = false
        }
        RowLayout {
            id: idleText
            anchors.centerIn: parent
            spacing: 4

            // Sound/Speaker status
            StyledText {
                id: soundIcon
                font.family: Appearence.font.nerdFont
                font.pixelSize: 12
                color: Appearence.colors.accentColor
                text: root.isMutedSink ? "󰟎" : ""
            }

            // Microphone status
            StyledText {
                id: micIcon
                font.family: Appearence.font.nerdFont
                font.pixelSize: 12
                color: Appearence.colors.accentColor
                text: root.isMutedSource ? "󰍭" : "" // Muted/unmuted mic
            }
        }
        Behavior on color {
            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }
    CustomTooltip {
        id: balTooltip
        text: `${Math.round((Audio.sink?.audio.volume ?? 0) * 100)}% | ${Audio.sink?.description}`
        tooltipVisible: false
        targetItem: root
        positionAbove: false
    }
}
