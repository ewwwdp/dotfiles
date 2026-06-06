pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool sidebarOpen: false
    property bool isSessionOpen: false
    property bool dndEnabled: false
    property bool gamemodeEnabled: false

    IpcHandler {
        target: "root"

        function sidebar(): void {
            root.sidebarOpen = !root.sidebarOpen;
        }
    }
}
