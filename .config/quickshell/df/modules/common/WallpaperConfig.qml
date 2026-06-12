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

    function setWallpaperForScreen(screenName, wallpaperFile) {
        wallpaperConfig[screenName] = wallpaperFile;
        const path = Qt.resolvedUrl("../../backgrounds.json").toString();
        const localPath = path.startsWith("file://") ? path.substring(7) : path;
        Quickshell.execDetached(["sh", "-c", `${Quickshell.shellDir}/scripts/set-wallpaper.sh '${screenName}' '${wallpaperFile}' '${localPath}'`]);
    }

    FileView {
        id: backgroundsConfig
        path: Qt.resolvedUrl("../../backgrounds.json")
        watchChanges: true
        onFileChanged: this.reload()
        onLoaded: {
            root.wallpaperConfig = JSON.parse(backgroundsConfig.text());
        }
    }
}
