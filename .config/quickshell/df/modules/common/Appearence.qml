pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

Singleton {
    id: root

    property QtObject animation
    property QtObject animationCurves
    property QtObject colors
    property QtObject font
    property QtObject sizes

    colors: QtObject {
        property color backgroundBarColor: "#000000"
        property color accentColor: "#c0caf5"
        property color hoverColor: "#13131D"
        property color barBackgroundColor: "#060709"
        property color barBorderColor: "#313244"

        property color baseColor: "#11111b"
        property color surfaceColor: "#181825"
        property color surfaceHoverColor: "#45475a"
        property color borderColor: "#313244"
        property color textColor: "#cdd6f4"
        property color textMutedColor: "#6c7086"
        property color errorColor: "#f38ba8"
        property color focusColor: "#89b4fa"
        property color popupBgColor: "#171717"
        property color popupBorderColor: "#262626"
        property color whiteColor: "#ffffff"
        property color scrimColor: "#80000000"
        property color wlogoutBgColor: "#13141c"
        property color wlogoutButtonColor: "#06060d"
        property color wlogoutButtonHoverColor: "#181923"
        property color wlogoutIconColor: "#D4BFF9"
        property color wallpaperBgColor: "#ee11111b"
        property color wallpaperCurrentColor: "#1e1e2e"
        property color clockColor: "#c0caf5"
    }

    FileView {
        id: themeFile
        path: `${Directories.themesPath}/${Config.configData.theme ?? "catppuccin-mocha"}.json`
        watchChanges: true
        onFileChanged: this.reload()
        onLoaded: {
            try {
                const data = JSON.parse(themeFile.text());
                for (const key in data) {
                    if (key in root.colors) {
                        root.colors[key] = data[key];
                    }
                }
                console.info("[Appearence] Theme file loaded");
            } catch (e) {
                console.error("[Appearence] Failed to parse theme:", e);
            }
        }
    }

    font: QtObject {
        readonly property string nerdFont: "JetBrainsMono Nerd Font"
        readonly property string readFont: "Fira Sans Semibold"
    }

    animationCurves: QtObject {
        readonly property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.90, 1, 1]
        readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1.00, 1, 1]
        readonly property list<real> expressiveSlowSpatial: [0.39, 1.29, 0.35, 0.98, 1, 1]
        readonly property list<real> expressiveEffects: [0.34, 0.80, 0.34, 1.00, 1, 1]
        readonly property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedFirstHalf: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82]
        readonly property list<real> emphasizedLastHalf: [5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
        readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
        readonly property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
        readonly property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
        readonly property real expressiveFastSpatialDuration: 350
        readonly property real expressiveDefaultSpatialDuration: 500
        readonly property real expressiveSlowSpatialDuration: 650
        readonly property real expressiveEffectsDuration: 200
    }

    animation: QtObject {
        property QtObject elementMove: QtObject {
            property int duration: animationCurves.expressiveDefaultSpatialDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveDefaultSpatial
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMove.duration
                    easing.type: root.animation.elementMove.type
                    easing.bezierCurve: root.animation.elementMove.bezierCurve
                }
            }
            property Component colorAnimation: Component {
                ColorAnimation {
                    duration: root.animation.elementMove.duration
                    easing.type: root.animation.elementMove.type
                    easing.bezierCurve: root.animation.elementMove.bezierCurve
                }
            }
        }
        property QtObject elementMoveEnter: QtObject {
            property int duration: 400
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.emphasizedDecel
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMoveEnter.duration
                    easing.type: root.animation.elementMoveEnter.type
                    easing.bezierCurve: root.animation.elementMoveEnter.bezierCurve
                }
            }
        }
        property QtObject elementMoveExit: QtObject {
            property int duration: 200
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.emphasizedAccel
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMoveExit.duration
                    easing.type: root.animation.elementMoveExit.type
                    easing.bezierCurve: root.animation.elementMoveExit.bezierCurve
                }
            }
        }
        property QtObject elementMoveFast: QtObject {
            property int duration: animationCurves.expressiveEffectsDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveEffects
            property int velocity: 850
            property Component colorAnimation: Component {
                ColorAnimation {
                    duration: root.animation.elementMoveFast.duration
                    easing.type: root.animation.elementMoveFast.type
                    easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
                }
            }
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMoveFast.duration
                    easing.type: root.animation.elementMoveFast.type
                    easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
                }
            }
        }

        property QtObject clickBounce: QtObject {
            property int duration: 200
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveFastSpatial
            property int velocity: 850
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.clickBounce.duration
                    easing.type: root.animation.clickBounce.type
                    easing.bezierCurve: root.animation.clickBounce.bezierCurve
                }
            }
        }
        property QtObject scroll: QtObject {
            property int duration: 400
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.standardDecel
        }
        property QtObject menuDecel: QtObject {
            property int duration: 350
            property int type: Easing.OutExpo
        }

        property QtObject colorSnap: QtObject {
            property int duration: 200
            property int type: Easing.Linear
            property Component colorAnimation: Component {
                ColorAnimation {
                    duration: root.animation.colorSnap.duration
                    easing.type: root.animation.colorSnap.type
                }
            }
        }
        property QtObject opacityFade: QtObject {
            property int duration: 150
            property int type: Easing.Linear
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.opacityFade.duration
                    easing.type: root.animation.opacityFade.type
                }
            }
        }
        property QtObject elementResize: QtObject {
            property int duration: 150
            property int type: Easing.OutCubic
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementResize.duration
                    easing.type: root.animation.elementResize.type
                }
            }
        }
        property QtObject standardEnter: QtObject {
            property int duration: 200
            property int type: Easing.OutCubic
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.standardEnter.duration
                    easing.type: root.animation.standardEnter.type
                }
            }
        }
        property QtObject fadeIn: QtObject {
            property int duration: 200
            property int type: Easing.OutExpo
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.fadeIn.duration
                    easing.type: root.animation.fadeIn.type
                }
            }
        }
        property QtObject listItemFade: QtObject {
            property int duration: 100
            property int type: Easing.Linear
        }
    }
}
