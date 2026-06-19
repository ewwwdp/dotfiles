pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import qs
import Quickshell
import Quickshell.Networking

Singleton {
    id: root
    property string connectedText
    property string networkName: wifiConnected ? "WiFi" : (ethConnected ? "Wired" : "Disconnected")
    property string materialSymbol: wifiConnected ? "󰤨" : (ethConnected ? "󰱓" : "")

    property WifiDevice wifi: null
    property WiredDevice eth: null
    property WifiNetwork activeNetwork: null
    property bool wifiConnected: false
    property bool ethConnected: false
    property bool hasWifi: false
    property bool hasEth: false
    property bool hasNetwork: false
    property bool wifiEnabled: false

    Connections {
        target: Networking
        function onWifiEnabledChanged() { root.refresh(); }
    }
    Connections {
        target: Networking.devices
        function onValuesChanged() { root.refresh(); }
    }

    Component.onCompleted: root.refresh()

    property var watchedDevices: []

    function watchDevice(dev) {
        if (root.watchedDevices.includes(dev))
            return;
        root.watchedDevices.push(dev);
        dev.connectedChanged.connect(() => root.refresh());
    }

    function getWiredDevices() {
        if (!Networking.devices?.values)
            return [];
        return Networking.devices.values.filter(d => d.type === DeviceType.Wired);
    }

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    function toggleScan() {
        if (wifi)
            wifi.scannerEnabled = !wifi.scannerEnabled;
    }

    function getSortedNetworks() {
        if (!wifi)
            return [];
        let networks = [...wifi.networks.values];
        networks.sort((a, b) => {
            if (a.connected && !b.connected)
                return -1;
            if (b.connected && !a.connected)
                return 1;
            if (a.bonded && !b.bonded)
                return -1;
            if (b.bonded && !a.bonded)
                return 1;
            return b.signalStrength - a.signalStrength;
        });
        return networks;
    }

    function refresh() {
        let devs = Networking.devices?.values;
        let currentDevs = devs ?? [];

        for (let i = root.watchedDevices.length - 1; i >= 0; i--) {
            if (!currentDevs.includes(root.watchedDevices[i])) {
                try { root.watchedDevices[i].connectedChanged.disconnect(root.refresh); } catch (e) {}
                root.watchedDevices.splice(i, 1);
            }
        }

        for (let dev of currentDevs)
            root.watchDevice(dev);

        wifi = devs?.find(d => d.type === DeviceType.Wifi) ?? null;
        let wiredDevs = devs?.filter(d => d.type === DeviceType.Wired) ?? [];
        eth = wiredDevs[0] ?? null;
        hasWifi = wifi != null;
        hasEth = wiredDevs.length > 0;
        hasNetwork = hasWifi || hasEth;
        wifiEnabled = Networking.wifiEnabled ?? false;
        wifiConnected = wifi?.connected ?? false;
        ethConnected = wiredDevs.some(d => d.connected ?? false);
        activeNetwork = wifi?.networks?.values?.find(n => n.connected) ?? null;

        if (wifiConnected) {
            connectedText = activeNetwork ? `${activeNetwork.name} (${Math.round(activeNetwork.signalStrength * 100)}%)` : "WiFi connected";
        } else if (ethConnected) {
            connectedText = "Ethernet connected";
        } else if (wifiEnabled) {
            connectedText = "WiFi enabled";
        } else if (hasWifi) {
            connectedText = "WiFi disabled";
        } else if (hasEth) {
            connectedText = "Ethernet disconnected";
        } else {
            connectedText = "No network";
        }
    }
}
