pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Networking
import QtQuick

Singleton {
    id: root
    property bool ethernet: Networking.devices.values.find(d => d.type === DeviceType.Wired)?.connected ?? false
    property string networkName: ethernet ? "Wired" : "Disconnected"
    property string materialSymbol: ethernet ? "󰱓" : ""
}
