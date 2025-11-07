pragma Singleton
pragma ComponentBehavior: Bound

import Qt.labs.platform
import QtQuick
import Quickshell

Singleton {
    readonly property string cache: StandardPaths.standardLocations(StandardPaths.CacheLocation)[0]
    readonly property string notificationsPath: `${Directories.cache}/notifications/notifications.json`
    readonly property string screenshotPath: Quickshell.cachePath("screenshot.png")
}
