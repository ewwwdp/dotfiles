pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool wifi: false
    property bool ethernet: false
    property int updateInterval: 5000
    property string networkName: ""
    property int networkStrength: 0
    property string materialSymbol: ethernet ? "󰱓" : (root.networkName.length > 0 && root.networkName != "lo") ? (root.networkStrength > 80 ? "󰤨" : root.networkStrength > 60 ? "󰤥" : root.networkStrength > 40 ? "󰤢" : root.networkStrength > 20 ? "󰤟" : "󰤯") : ""

    function update() {
        updateConnectionType.startCheck();
        if (wifi) {
            updateNetworkName.running = true;
            updateNetworkStrength.running = true;
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            root.update();
            interval = root.updateInterval;
        }
    }

    Component.onCompleted: root.update()

    Process {
        id: updateConnectionType
        property string buffer: ""
        command: ["sh", "-c", "nmcli -t -f NAME,TYPE,DEVICE c show --active"]

        function startCheck() {
            buffer = "";
            running = true;
        }

        stdout: SplitParser {
            onRead: data => updateConnectionType.buffer += data + "\n"
        }

        onExited: {
            const lines = updateConnectionType.buffer.trim().split('\n');
            let hasEthernet = false;
            let hasWifi = false;
            for (let line of lines) {
                if (line.includes("ethernet"))
                    hasEthernet = true;
                else if (line.includes("wireless"))
                    hasWifi = true;
            }
            root.ethernet = hasEthernet;
            root.wifi = hasWifi;
        }
    }

    Process {
        id: updateNetworkName
        command: ["sh", "-c", "nmcli -t -f NAME c show --active | head -1"]
        stdout: SplitParser {
            onRead: data => root.networkName = data.trim()
        }
    }

    Process {
        id: updateNetworkStrength
        command: ["sh", "-c", "iw dev wlp0s20f3 link | awk '/signal:/ {print $2}'"]
        stdout: SplitParser {
            onRead: data => {
                const dBm = parseInt(data);
                let percent = Math.min(100, Math.max(0, 2 * (dBm + 100)));
                root.networkStrength = percent;
            }
        }
    }
}
