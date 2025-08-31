import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.services

Scope {
    id: root

    Connections {
        target: Audio.sink?.audio ?? null

        function onVolumeChanged() {
            if (!Audio.ready)
                return;
            root.shouldShowOsd = true;
            hideTimer.restart();
        }
        function onMutedChanged() {
            if (!Audio.ready)
                return;
            root.shouldShowOsd = true;
            hideTimer.restart();
        }
    }
    property bool shouldShowOsd: false

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.shouldShowOsd = false
    }

    LazyLoader {
        active: root.shouldShowOsd

        PanelWindow {

            anchors.bottom: true
            margins.bottom: screen.height / 5
            exclusiveZone: 0

            implicitWidth: 500
            implicitHeight: 50
            color: "transparent"

            mask: Region {}

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: "#80000000"

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 15
                    }

                    StyledText {
                        font {
                            pixelSize: 30
                            family: Appearence.font.nerdFont
                        }
                        text: Audio.sink?.audio.muted ? "\udb81\udd81" : "\udb81\udd7e"
                        color: Appearence.colors.accentColor
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 10
                        radius: 20
                        color: "#50ffffff"

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }
                            color: Appearence.colors.accentColor
                            implicitWidth: parent.width * (Audio.sink?.audio.muted ? 0 : ((Audio.sink?.audio.volume >= 1 ? 1 : Audio.sink?.audio.volume) ?? 0))
                            radius: parent.radius
                            Behavior on implicitWidth {
                                animation: Appearence.animation.elementMoveEnter.numberAnimation.createObject(this)
                            }
                        }
                    }
                    StyledText {
                        text: `${Math.round((Audio.sink?.audio.volume ?? 0) * 100)}%`
                        font.family: Appearence.font.readFont
                        color: Appearence.colors.accentColor
                    }
                }
            }
        }
    }
}
