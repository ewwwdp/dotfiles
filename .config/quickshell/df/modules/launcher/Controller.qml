pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.core

Scope {
    id: root

    LazyLoader {
        active: GlobalStates.launcherOpen

        PanelWindow {
            id: launcherWindow
            color: "transparent"
            implicitWidth: content.width
            implicitHeight: content.height
            WlrLayershell.namespace: "quickshell:launcher"

            HyprlandFocusGrab {
                windows: [launcherWindow]
                active: true
                onCleared: GlobalStates.launcherOpen = false
            }

            MouseArea {
                anchors.fill: parent
                onPressed: GlobalStates.launcherOpen = false

                MouseArea {
                    anchors.centerIn: parent
                    width: content.width
                    height: content.height

                    LaunchContent { id: content }
                }
            }
        }
    }
}
