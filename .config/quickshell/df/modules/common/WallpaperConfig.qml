pragma Singleton
pragma ComponentBehavior: Bound

import qs
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property var wallpaperConfig: ({})

    property string defaultWallpaper: "sunflowers.png"

    function wallpaperForScreen(screenName) {
        const file = wallpaperConfig[screenName];
        if (file) return `${Directories.wallpapersPath}${file}`;
        return `${Directories.wallpapersPath}${root.defaultWallpaper}`;
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
