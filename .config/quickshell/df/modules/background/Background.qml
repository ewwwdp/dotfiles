import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.core
import qs.modules.common

LazyLoader {
    active: true

    component: Item {
        id: root

        Variants {
            model: Quickshell.screens

            PanelWindow {
                id: panel
                required property ShellScreen modelData

                screen: modelData
                visible: true
                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }
                color: "transparent"
                updatesEnabled: true

                WlrLayershell.namespace: "quickshell:background"
                WlrLayershell.layer: WlrLayer.Background
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                exclusionMode: ExclusionMode.Ignore

                StyledImage {
                    anchors.fill: parent
                    source: WallpaperConfig.wallpaperForScreen(panel.modelData?.name ?? "")
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                }
            }
        }
    }
}
