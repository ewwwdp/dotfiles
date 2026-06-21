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
            root.configData = JSON.parse(configFile.text());
        }
    }
}
