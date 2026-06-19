import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.services

BarButton {
    id: root
    text: (isMutedSink ? "󰟎" : "") + " " + (isMutedSource ? "󰍭" : "")
    useNerdFont: true
    fontSize: 12

    property bool isMutedSink: Audio.sink?.audio?.muted ?? true
    property bool isMutedSource: Audio.source?.audio?.muted ?? true

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

    onClicked: Audio.sink.audio.muted = !Audio.sink.audio.muted
    onEntered: tooltip.tooltipVisible = true
    onExited: tooltip.tooltipVisible = false

    WheelHandler {
        onWheel: event => {
            event.accepted = true;
            const step = 0.01;
            if (event.angleDelta.y > 0)
                Audio.sink.audio.volume = Math.min(Audio.sink.audio.volume + step, 1);
            if (event.angleDelta.y < 0)
                Audio.sink.audio.volume -= step;
        }
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

    MouseArea {
        acceptedButtons: Qt.RightButton | Qt.MiddleButton
        anchors.fill: parent
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                Audio.source.audio.muted = !Audio.source.audio.muted;
            else if (mouse.button === Qt.MiddleButton)
                Quickshell.execDetached(["pavucontrol"]);
        }
    }

    CustomTooltip {
        id: tooltip
        text: `${Math.round((Audio.sink?.audio.volume ?? 0) * 100)}% | ${Audio.sink?.description}`
        tooltipVisible: false
        targetItem: root
        positionAbove: false
    }
}
