pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var monitors: []
    property int monitorCount: 0
    property int activeMonitorCount: 0
    property bool hasMultipleMonitors: false
    property string currentMode: "default"
    property var monitorModes: []

    function hexToChar(hex) {
        if (!hex)
            return "\uf108";
        return String.fromCodePoint(parseInt(hex, 16));
    }

    Component.onCompleted: {
        update();
        readCurrentMode();
        refreshModes();
    }

    Process {
        id: monitorProcess
        command: ["hyprctl", "monitors", "all", "-j"]

        stdout: StdioCollector {
            id: devicesCollector
            onStreamFinished: {
                let monitorData;
                try {
                    monitorData = JSON.parse(devicesCollector.text);
                } catch (e) {
                    console.error("[MonitorService] Failed to parse hyprctl output:", e);
                    monitorData = [];
                }

                root.monitors = monitorData;
                root.monitorCount = monitorData.length;

                root.activeMonitorCount = monitorData.filter(m => !m.disabled).length;
                root.hasMultipleMonitors = root.monitorCount > 1;
            }
        }
    }

    Process {
        id: modeLister
        command: ["sh", "-c", "for f in \"$HOME/.config/hypr/config/monitors/\"*.lua; do\n  [ -f \"$f\" ] || continue\n  name=$(basename \"$f\" .lua)\n  meta=$(head -1 \"$f\" 2>/dev/null)\n  icon=$(echo \"$meta\" | sed -nE 's/.*-- @meta icon=([^ ]*).*/\\1/p')\n  label=$(echo \"$meta\" | sed -nE 's/.*label=([^ ]*).*/\\1/p')\n  echo \"$name|$icon|$label\"\ndone"]

        stdout: StdioCollector {
            id: modeCollector
            onStreamFinished: {
                root.monitorModes = modeCollector.text.trim().split("\n").filter(line => line.length > 0).map(line => {
                    const parts = line.split("|");
                    return {
                        mode: parts[0],
                        icon: root.hexToChar(parts[1]),
                        label: parts[2] || parts[0].charAt(0).toUpperCase() + parts[0].slice(1).replace("-", " ")
                    };
                });
            }
        }
    }

    Process {
        id: modeReader
        command: ["sh", "-c", "sed -nE 's/.*config\\.monitors\\.([a-z-]*).*/\\1/p' \"$HOME/.config/hypr/config/monitors.lua\""]

        stdout: StdioCollector {
            id: modeReaderCollector
            onStreamFinished: {
                const mode = modeReaderCollector.text.trim();
                if (mode.length > 0)
                    root.currentMode = mode;
            }
        }
    }

    function update() {
        monitorProcess.running = true;
    }

    function refreshModes() {
        if (modeLister)
            modeLister.running = true;
    }

    function readCurrentMode() {
        if (modeReader)
            modeReader.running = true;
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
            if (m.disabled)
                continue;
            text.push(`${m.name}: ${m.width}x${m.height}@${m.refreshRate}Hz`);
        }
        return text.join("\n");
    }

    function getCurrentMode() {
        return root.currentMode;
    }

    function switchMode(mode) {
        if (!mode)
            return;
        Quickshell.execDetached(["sh", "-c", `sed -i 's/config\\.monitors\\.[a-z-]*/config.monitors.${mode}/' "$HOME/.config/hypr/config/monitors.lua" && hyprctl reload && hyprctl notify -1 3000 "rgb(40a02b)" "Monitor mode: ${mode}"`]);
        root.currentMode = mode;
    }
}
