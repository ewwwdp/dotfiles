pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool isLaptop: true
    property bool sidebarOpen: false
    property bool isSessionOpen: false
    property bool dndEnabled: false
    property bool gamemodeEnabled: false
    property bool screenLocked: false
    property bool calendarOpen: false
    property bool launcherOpen: false
    property bool wallpaperPickerOpen: false
    property bool clipboardOpen: false

    IpcHandler {
        target: "root"

        function sidebar(): void {
            root.sidebarOpen = !root.sidebarOpen;
        }

        function lock() {
            root.screenLocked = true;
        }

        function wallpaper() {
            root.wallpaperPickerOpen = !root.wallpaperPickerOpen;
        }

        function clipboard() {
            root.clipboardOpen = !root.clipboardOpen;
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
