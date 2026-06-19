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
    property bool hasDefaultAdapter: Bluetooth.defaultAdapter != null
    property bool ready: Bluetooth.defaultAdapter?.enabled ?? false

    Connections {
        target: Bluetooth.defaultAdapter ?? null
        function onEnabledChanged() {
            root.update();
        }
        function onStateChanged() {
            root.update();
        }
    }

    Connections {
        target: Bluetooth
        function onDefaultAdapterChanged() {
            root.update();
        }
    }

    Component.onCompleted: root.update()

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    property bool hasConnected: adapter?.devices?.values?.some(d => d.connected) ?? false

    function toggle() {
        if (!hasDefaultAdapter)
            return;
        Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
    }

    function toggleScan() {
        if (adapter)
            adapter.discovering = !adapter.discovering;
    }

    function getSortedDevices() {
        if (!adapter) return [];
        let devices = [...adapter.devices.values];
        devices.sort((a, b) => {
            if (a.connected && !b.connected) return -1;
            if (b.connected && !a.connected) return 1;
            if (a.bonded && !b.bonded) return -1;
            if (b.bonded && !a.bonded) return 1;
            return (a.name || "").localeCompare(b.name || "");
        });
        return devices;
    }

    function update() {
        let devices = Bluetooth.defaultAdapter?.devices?.values.filter(d => d.connected) || [];
        if (devices?.length > 0) {
            connectedDevicesText = devices.map(d => `${d.name || d.deviceName} (${d.address})`).join("\n");
            materialSymbol = "󰂱";
        } else if (root.ready) {
            connectedDevicesText = "enabled";
            materialSymbol = "";
        } else if (Bluetooth.defaultAdapter?.state === BluetoothAdapterState.Blocked) {
            connectedDevicesText = "blocked (rfkill)";
            materialSymbol = "󰂲";
        } else {
            connectedDevicesText = "disabled";
            materialSymbol = "󰂲";
        }
    }
}
