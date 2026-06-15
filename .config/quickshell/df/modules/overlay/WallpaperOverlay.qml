import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.modules.common

Scope {
    id: root

    property string selectedScreen: Hyprland.focusedMonitor?.name ?? ""
    property int thumbnailSize: 140

    ListModel {
        id: wallpaperModel
    }

    LazyLoader {
        active: GlobalStates.wallpaperPickerOpen

        PanelWindow {
            id: panelWindow
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            color: "transparent"
            exclusiveZone: 0

            WlrLayershell.namespace: "quickshell:wallpaper"
            WlrLayershell.layer: WlrLayer.Overlay

            HyprlandFocusGrab {
                windows: [panelWindow]
                active: GlobalStates.wallpaperPickerOpen
                onCleared: () => {
                    if (!active)
                        GlobalStates.wallpaperPickerOpen = false;
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                focus: true

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape)
                        GlobalStates.wallpaperPickerOpen = false;
                }

                Item {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        bottom: container.top
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: GlobalStates.wallpaperPickerOpen = false
                    }
                }

                Rectangle {
                    id: container
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: Math.min(parent.width - 80, 885)
                    height: root.thumbnailSize + 30
                    radius: 16
                    color: "#ee11111b"
                    border.width: 1
                    border.color: "#313244"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Flickable {
                            id: wallpaperFlickable
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            contentWidth: row.implicitWidth
                            contentHeight: row.implicitHeight
                            boundsBehavior: Flickable.StopAtBounds
                            interactive: true
                            flickDeceleration: 2500

                            WheelHandler {
                                onWheel: event => {
                                    event.accepted = true;
                                    wallpaperFlickable.contentX = Math.max(0, Math.min(wallpaperFlickable.contentWidth - wallpaperFlickable.width, wallpaperFlickable.contentX - event.angleDelta.y));
                                }
                                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                            }

                            Row {
                                id: row
                                spacing: 8

                                Repeater {
                                    model: wallpaperModel

                                    Rectangle {
                                        required property string fileName
                                        property bool isCurrent: root.selectedScreen && WallpaperConfig.wallpaperConfig[root.selectedScreen] === fileName

                                        width: root.thumbnailSize * 2
                                        height: root.thumbnailSize
                                        radius: 12
                                        color: wallpaperMouse.containsMouse ? "#45475a" : (isCurrent ? "#1e1e2e" : "#181825")
                                        border.width: isCurrent ? 2 : 1
                                        border.color: isCurrent ? "#c0caf5" : "#313244"

                                        Behavior on color {
                                            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                                        }
                                        Behavior on border.color {
                                            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                                        }

                                        Rectangle {
                                            anchors.fill: parent
                                            anchors.margins: 4
                                            radius: 6
                                            clip: true

                                            Image {
                                                anchors.fill: parent
                                                source: `${Directories.wallpapersPath}${fileName}`
                                                fillMode: Image.PreserveAspectCrop
                                                asynchronous: true
                                                cache: false
                                                sourceSize.width: root.thumbnailSize * 2
                                                sourceSize.height: root.thumbnailSize * 2
                                            }
                                        }

                                        MouseArea {
                                            id: wallpaperMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (root.selectedScreen) {
                                                    WallpaperConfig.setWallpaperForScreen(root.selectedScreen, fileName);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Process {
        id: wallpaperLister
        command: ["ls", "-1", Directories.wallpapersPath]
        running: false

        stdout: SplitParser {
            onRead: data => {
                const ext = data.split('.').pop().toLowerCase();
                if (["png", "jpg", "jpeg", "bmp", "webp", "gif"].indexOf(ext) >= 0) {
                    wallpaperModel.append({
                        fileName: data
                    });
                }
            }
        }
    }

    Connections {
        target: GlobalStates
        function onWallpaperPickerOpenChanged() {
            if (GlobalStates.wallpaperPickerOpen) {
                wallpaperModel.clear();
                wallpaperLister.running = true;
            }
        }
    }
}
