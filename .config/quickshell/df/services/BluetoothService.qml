pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import qs
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root
    property int updateInterval: 5000
    property string connectedDevicesText
    property string materialSymbol: "󰂲"
    property bool ready: Bluetooth.defaultAdapter?.state != 4 ?? false

    Connections {
        target: Bluetooth.defaultAdapter ?? null
        function onStateChanged() {
            root.ready = Bluetooth.defaultAdapter?.state != 4 ?? false;
        }
    }
    Timer {
        interval: 10
        running: root.ready || GlobalStates.sidebarOpen
        repeat: true
        onTriggered: {
            root.update();
            interval = root.updateInterval;
        }
    }

    function update() {
        let devices = Bluetooth.defaultAdapter?.devices?.values.filter(d => d.connected) || {};
        if (devices.length > 0) {
            connectedDevicesText = devices.map(d => `${d.name || d.deviceName} (${d.address})`).join("\n");
            materialSymbol = "󰂱";
        } else if (root.ready) {
            connectedDevicesText = "enabled";
            materialSymbol = "";
        } else {
            connectedDevicesText = "disabled";
            materialSymbol = "󰂲";
        }
    }
}
