pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.core
import qs.modules.common

Scope {
    id: root
    property bool shooting: false
    property bool visible: false
    readonly property string path: Directories.screenshotPath

    IpcHandler {
        target: "screenshot"
        function takeScreenshot() {
            root.shooting = true;
        }
    }
    onShootingChanged: {
        if (shooting) {
            grimProc.running = true;
        } else {
            visible = false;
        }
    }

    Process {
        id: grimProc
        command: ["grim", "-l", "0", "-s", "1", root.path]
        onExited: code => {
            if (code == 0) {
                root.visible = true;
            } else {
                console.log("screenshot failed");
                root.shooting = false;
            }
        }
    }

    Process {
        id: magickProc
        command: ["magick", root.path, "-crop", `${selection.normal.width}x${selection.normal.height}+${selection.normal.x}+${selection.normal.y}`, "-quality", "70", "-page", "0x0+0+0", root.path,]
        onExited: wlCopy.running = true
    }

    Process {
        id: wlCopy
        command: ["sh", "-c", `wl-copy < '${root.path}'`]
        onExited: dismissAnim.start()
    }

    QtObject {
        id: selection
        property real x1
        property real y1
        property real x2
        property real y2
        readonly property real x: Math.min(x1, x2)
        readonly property real y: Math.min(y1, y2)
        readonly property real w: Math.max(x1, x2) - x
        readonly property real h: Math.max(y1, y2) - y
        readonly property rect normal: Qt.rect(x - topleft.x, y - topleft.y, w, h)
    }

    readonly property point topleft: Quickshell.screens.reduce((point, screen) => {
        return Qt.point(Math.min(point.x, screen.x), Math.min(point.y, screen.y));
    }, Qt.point(Number.POSITIVE_INFINITY, Number.POSITIVE_INFINITY))

    function normalizedScreenRect(screen: ShellScreen): rect {
        const p = topleft;
        return Qt.rect(screen.x - p.x, screen.y - p.y, screen.width, screen.height);
    }

    SequentialAnimation {
        id: dismissAnim
        PauseAnimation {
            duration: 200
        }
        ScriptAction {
            script: root.shooting = false
        }
    }

    LazyLoader {
        loading: root.shooting
        active: root.visible

        Variants {
            model: Quickshell.screens

            property bool capturing: false

            Component.onCompleted: {
                selection.x1 = selection.y1 = selection.x2 = selection.y2 = 0;
                capturing = false;
            }

            PanelWindow {
                id: panel
                required property var modelData
                screen: modelData
                visible: root.visible
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.namespace: "quickshell:screenshot"
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }

                Image {
                    anchors.fill: parent
                    source: root.visible ? root.path : ""
                    fillMode: Image.PreserveAspectCrop
                    sourceClipRect: root.normalizedScreenRect(panel.screen)

                    NumberAnimation on opacity {
                        from: 0.0
                        to: 1.0
                        duration: Appearence.animation.fadeIn.duration
                        easing.type: Appearence.animation.fadeIn.type
                        running: root.visible
                    }
                }

                MouseArea {
                    id: area
                    anchors.fill: parent
                    enabled: !capturing
                    cursorShape: capturing ? Qt.WaitCursor : Qt.CrossCursor

                    onPressed: {
                        selection.x1 = mouseX + panel.screen.x;
                        selection.x2 = selection.x1;
                        selection.y1 = mouseY + panel.screen.y;
                        selection.y2 = selection.y1;
                    }

                    onPositionChanged: {
                        selection.x2 = mouseX + panel.screen.x;
                        selection.y2 = mouseY + panel.screen.y;
                    }

                    onReleased: {
                        if (selection.w > 0 && selection.h > 0) {
                            capturing = true;
                            magickProc.running = true;
                        } else {
                            wlCopy.running = true;
                        }
                    }
                }

                CutoutRect {
                    anchors.fill: parent
                    innerX: selection.x - panel.screen.x
                    innerY: selection.y - panel.screen.y
                    innerW: selection.w
                    innerH: selection.h

                    innerBorderColor: capturing ? "#00ff20" : "white"

                    PropertyAnimation on innerBorderColor {
                        running: capturing
                        to: "#00ff20"
                        duration: Appearence.animation.colorSnap.duration
                    }
                }

                Rectangle {
                    readonly property real sx: selection.x - panel.screen.x
                    readonly property real sy: selection.y - panel.screen.y
                    x: Math.min(Math.max(sx + selection.w + 8, 0), panel.width - width)
                    y: Math.max(sy - height - 8, 0)
                    width: txt.implicitWidth + 8
                    height: txt.implicitHeight + 8
                    visible: selection.w > 0 && selection.h > 0
                    color: "#bb000000"
                    radius: 4

                    Text {
                        id: txt
                        anchors.centerIn: parent
                        text: `${Math.round(selection.w)} × ${Math.round(selection.h)}`
                        color: "white"
                        font.pixelSize: 13
                        font.bold: true
                        style: Text.Outline
                        styleColor: "#cc000000"
                    }
                }
            }
        }
    }
}
