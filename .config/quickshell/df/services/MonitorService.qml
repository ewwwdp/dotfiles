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

    readonly property var internalMonitorPatterns: ["eDP", "LVDS", "DSI"]

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
        if (monitorCount === 0) {
            return "none";
        } else if (monitorCount === 1) {
            return hasInternalMonitor ? "internal" : "external";
        } else if (monitorCount >= 2) {
            const firstMonitor = monitors[0];
            let allSameResolution = true;

            for (let i = 1; i < monitors.length; i++) {
                if (monitors[i].width !== firstMonitor.width || monitors[i].height !== firstMonitor.height) {
                    allSameResolution = false;
                    break;
                }
            }

            return allSameResolution ? "mirror" : "split";
        }
        return "unknown";
    }
}
