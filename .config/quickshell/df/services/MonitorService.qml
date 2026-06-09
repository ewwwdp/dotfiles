pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import qs
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var monitors: []
    property int monitorCount: 0
    property string activeMonitors: ""
    property bool hasExternalMonitor: false
    property bool hasInternalMonitor: false
    property string currentMode: "default"
    readonly property var availableModes: ["default", "vertical", "both-vertical"]

    readonly property var internalMonitorPatterns: ["eDP", "LVDS", "DSI", "DP"]

    Component.onCompleted: {
        update();
    }

    Process {
        id: monitorProcess
        command: ["hyprctl", "monitors", "all", "-j"]

        stdout: StdioCollector {
            id: devicesCollector
            onStreamFinished: {
                const monitorData = JSON.parse(devicesCollector.text);

                root.monitors = monitorData;
                root.monitorCount = monitorData.length;

                root.hasExternalMonitor = false;
                root.hasInternalMonitor = false;

                let names = [];
                for (let i = 0; i < monitorData.length; i++) {
                    const monitor = monitorData[i];
                    const name = monitor.name || "";
                    names.push(name);
                    let isInternal = false;
                    for (let j = 0; j < root.internalMonitorPatterns.length; j++) {
                        if (name.includes(root.internalMonitorPatterns[j])) {
                            isInternal = true;
                            break;
                        }
                    }

                    if (isInternal) {
                        root.hasInternalMonitor = true;
                    } else {
                        root.hasExternalMonitor = true;
                    }
                }

                root.activeMonitors = names.join(", ");
            }
        }
    }

    function update() {
        monitorProcess.running = true;
    }

    function getMonitor(name) {
        for (let i = 0; i < monitors.length; i++) {
            if (monitors[i].name === name) {
                return monitors[i];
            }
        }
        return null;
    }

    function getMonitorNames() {
        return monitors.map(m => m.name);
    }

    function getMonitorsText() {
        if (monitorCount === 0) {
            return "No monitors detected";
        }

        let text = [];
        for (let i = 0; i < monitors.length; i++) {
            const m = monitors[i];
            text.push(`${m.name}: ${m.width}x${m.height}@${m.refreshRate}Hz`);
        }
        return text.join("\n");
    }

    function getCurrentMode() {
        return root.currentMode;
    }

    function switchMode(mode) {
        if (root.availableModes.indexOf(mode) < 0)
            return;
        Quickshell.execDetached(["sh", "-c",
            `sed -i 's/config\\.monitors\\.[a-z-]*/config.monitors.${mode}/' "$HOME/.config/hypr/config/monitors.lua" && hyprctl reload`]);
        root.currentMode = mode;
    }
}
