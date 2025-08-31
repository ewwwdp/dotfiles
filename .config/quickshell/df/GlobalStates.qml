pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool sidebarOpen: false
    property bool isSessionOpen: false
    property bool dndEnabled: false
    property bool gamemodeEnabled: false
    property bool wifiEnabled: false
    property bool idleInhibitorEnabled: false
}
