pragma Singleton
pragma ComponentBehavior: Bound

import qs
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property var wallpaperConfig: ({})

    function wallpaperForScreen(screenName) {
        return `${Directories.wallpapersPath}${wallpaperConfig[screenName]}`;
    }

    FileView {
        id: backgroundsConfig
        path: Qt.resolvedUrl("../../backgrounds.json")
        onLoaded: {
            root.wallpaperConfig = JSON.parse(backgroundsConfig.text());
        }
    }
}
