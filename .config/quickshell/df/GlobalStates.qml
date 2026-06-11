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
    property bool screenLocked: false
    property bool calendarOpen: false
    property bool launcherOpen: false

    IpcHandler {
        target: "root"

        function sidebar(): void {
            root.sidebarOpen = !root.sidebarOpen;
        }

        function lock() {
            root.screenLocked = true;
        }
    }

    IpcHandler {
        target: "launcher"

        function open(): void {
            root.launcherOpen = true;
        }

        function close(): void {
            root.launcherOpen = false;
        }

        function toggle(): void {
            root.launcherOpen = !root.launcherOpen;
        }
    }
}
