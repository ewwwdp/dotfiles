pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

Singleton {
    id: root

    property var configData: ({})
    readonly property bool isLaptop: configData.isLaptop ?? false

    FileView {
        id: configFile
        path: Directories.configPath
        watchChanges: true
        onFileChanged: this.reload()
        onLoaded: {
            try {
                root.configData = JSON.parse(configFile.text());
            } catch (e) {
                console.error("[Config] Failed to parse config.json:", e);
                root.configData = ({});
            }
        }
    }
}
