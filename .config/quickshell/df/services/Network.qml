pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Networking
import QtQuick

Singleton {
    id: root
    property bool ethernet: Networking.devices.values[0]?.connected ?? false
    property string networkName: ethernet ? "Wired" : "Disconnected"
    property string materialSymbol: ethernet ? "󰱓" : ""
}
