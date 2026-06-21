pragma Singleton
pragma ComponentBehavior: Bound

import qs.core
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var wallpaperConfig: Config.configData.wallpapers ?? ({})
    readonly property string defaultWallpaper: Config.configData.defaultWallpaper ?? "sunflowers.png"

    function wallpaperForScreen(screenName) {
        const file = wallpaperConfig[screenName];
        if (file && typeof file === "string")
            return `${Directories.wallpapersPath}${file}`;
        return `${Directories.wallpapersPath}${root.defaultWallpaper}`;
    }

    function setWallpaperForScreen(screenName, wallpaperFile) {
        wallpaperConfig[screenName] = wallpaperFile;
        const path = Directories.configPath;
        const localPath = path.startsWith("file://") ? path.substring(7) : path;
        Quickshell.execDetached(["sh", "-c", `${Quickshell.shellDir}/scripts/set-wallpaper.sh '${screenName}' '${wallpaperFile}' '${localPath}'`]);
    }
}
