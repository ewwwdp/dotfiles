import qs
import qs.services
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    width: 48
    height: 48
    radius: 24
    color: GlobalStates.wifiEnabled ? Appearence.colors.accentColor : "#11111b"
    border.width: 1
    border.color: "#6c7086"
    scale: mouseArea.containsMouse ? 1.1 : 1.0

    StyledText {
        color: GlobalStates.wifiEnabled ? "#45475a" : "#cdd6f4"
        anchors.centerIn: parent
        text: GlobalStates.wifiEnabled ? (Network.wifi ? "" : "󰤯") : "󰤭"
        font.family: Appearence.font.nerdFont
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            if (event.button === Qt.LeftButton) {
                toggleWifi.running = true;
            }
            if (event.button === Qt.RightButton) {
                Quickshell.execDetached(["sh", "-c", "if pgrep -x nm-applet > /dev/null; then killall nm-applet; else nm-applet & fi"]);
            }
            event.accepted = true;
        }
    }

    Timer {
        id: timerRunner
        interval: 10
        running: GlobalStates.sidebarOpen
        repeat: true
        onTriggered: {
            checkWifiModule.running = true;
            timerRunner.interval = 2000;
        }
    }

    Process {
        id: checkWifiModule
        command: ["sh", "-c", "nmcli radio wifi"]
        stdout: SplitParser {
            onRead: data => {
                GlobalStates.wifiEnabled = data.trim() == "enabled";
            }
        }
    }

    Process {
        id: toggleWifi
        command: ["sh", "-c", "nmcli radio wifi | grep -q enabled && nmcli radio wifi off || nmcli radio wifi on"]
    }
    Behavior on color {
        animation: Appearence.animation.elementMove.colorAnimation.createObject(this)
    }
    Behavior on scale {
        animation: Appearence.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
}
