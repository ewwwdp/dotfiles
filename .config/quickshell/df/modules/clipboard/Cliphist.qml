import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.services
import qs.modules.common

Scope {
    id: root

    LazyLoader {
        active: GlobalStates.clipboardOpen

        onActiveChanged: {
            if (active) {
                Clipboard.pendingListReset = true;
                Clipboard.fetchListProc = true;
            }
        }

        PanelWindow {
            id: clipboardWindow
            color: "transparent"
            implicitWidth: content.width
            implicitHeight: content.height
            WlrLayershell.namespace: "quickshell:cliphist"

            HyprlandFocusGrab {
                windows: [clipboardWindow]
                active: GlobalStates.clipboardOpen
                onCleared: GlobalStates.clipboardOpen = false
            }

            MouseArea {
                anchors.fill: parent
                onPressed: GlobalStates.clipboardOpen = false

                MouseArea {
                    anchors.centerIn: parent
                    width: content.width
                    height: content.height

                    Rectangle {
                        id: content
                        width: 450
                        height: Math.min(clipboardList.contentHeight + headerRow.implicitHeight + 50, 600)
                        color: "#171717"
                        radius: 10
                        border.color: "#262626"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 0

                            RowLayout {
                                id: headerRow
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "\uf0ea"
                                    font.family: Appearence.font.nerdFont
                                    font.pixelSize: 20
                                    color: Appearence.colors.accentColor
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: "Clipboard"
                                    font.pixelSize: 16
                                    color: "#ffffff"
                                }

                                Text {
                                    text: "(" + Clipboard.list.count + ")"
                                    font.pixelSize: 12
                                    color: "#888888"
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Button {
                                    id: clearBtn
                                    implicitWidth: 32
                                    implicitHeight: 32
                                    hoverEnabled: true
                                    background: Rectangle {
                                        radius: 8
                                        color: clearBtn.hovered ? Appearence.colors.hoverColor : "transparent"
                                    }
                                    contentItem: Text {
                                        text: "\uf1f8"
                                        font.family: Appearence.font.nerdFont
                                        font.pixelSize: 14
                                        color: Appearence.colors.accentColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: Clipboard.clearHistory()
                                }

                                Button {
                                    id: closeBtn
                                    implicitWidth: 32
                                    implicitHeight: 32
                                    hoverEnabled: true
                                    background: Rectangle {
                                        radius: 8
                                        color: closeBtn.hovered ? Appearence.colors.hoverColor : "transparent"
                                    }
                                    contentItem: Text {
                                        text: "\uf00d"
                                        font.family: Appearence.font.nerdFont
                                        font.pixelSize: 14
                                        color: Appearence.colors.accentColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: GlobalStates.clipboardOpen = false
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                ListView {
                                    id: clipboardList
                                    anchors.fill: parent
                                    clip: true
                                    focus: true
                                    model: Clipboard.list

                                    topMargin: 4
                                    bottomMargin: clipboardList.count === 0 ? 0 : 4

                                    ScrollBar.vertical: ScrollBar {
                                        policy: ScrollBar.AsNeeded
                                        width: 6
                                    }

                                    add: Transition {
                                        NumberAnimation {
                                            property: "opacity"
                                            from: 0
                                            to: 1
                                            duration: 150
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    displaced: Transition {
                                        NumberAnimation {
                                            property: "y"
                                            duration: 200
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    move: Transition {
                                        NumberAnimation {
                                            property: "y"
                                            duration: 200
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    remove: Transition {
                                        NumberAnimation {
                                            property: "opacity"
                                            to: 0
                                            duration: 150
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    highlight: Rectangle {
                                        radius: 8
                                        color: Appearence.colors.accentColor
                                        opacity: 0.15

                                        Behavior on color {
                                            animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                                        }
                                    }

                                    Keys.onPressed: function (event) {
                                        if (event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace) {
                                            if (clipboardList.currentIndex >= 0) {
                                                var model = clipboardList.model;
                                                if (model && clipboardList.currentIndex < model.count) {
                                                    var item = model.get(clipboardList.currentIndex);
                                                    Clipboard.deleteEntry(item.id);
                                                }
                                            }
                                        }
                                    }

                                    Keys.onReturnPressed: {
                                        if (clipboardList.currentIndex >= 0) {
                                            var model = clipboardList.model;
                                            if (model && clipboardList.currentIndex < model.count) {
                                                var item = model.get(clipboardList.currentIndex);
                                                Clipboard.copyToClipboard(item.id);
                                                GlobalStates.clipboardOpen = false;
                                            }
                                        }
                                    }

                                    Keys.onEscapePressed: GlobalStates.clipboardOpen = false

                                    keyNavigationEnabled: true
                                    keyNavigationWraps: true
                                    highlightMoveVelocity: -1
                                    highlightMoveDuration: 100
                                    highlightRangeMode: ListView.ApplyRange
                                    snapMode: ListView.SnapToItem

                                    Connections {
                                        target: Clipboard
                                        function onListUpdated() {
                                            if (Clipboard.pendingListReset) {
                                                clipboardList.currentIndex = 0;
                                                Clipboard.pendingListReset = false;
                                            }
                                        }
                                    }

                                    delegate: MouseArea {
                                        required property var modelData
                                        required property int index

                                        implicitHeight: modelData.isBinary ? 64 : 44
                                        implicitWidth: ListView.view.width

                                        onClicked: {
                                            Clipboard.copyToClipboard(modelData.id);
                                            GlobalStates.clipboardOpen = false;
                                        }

                                        RowLayout {
                                            anchors {
                                                left: parent.left
                                                leftMargin: 10
                                                right: parent.right
                                                rightMargin: 10
                                                verticalCenter: parent.verticalCenter
                                            }
                                            spacing: 10

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 2

                                                Text {
                                                    visible: !modelData.isBinary
                                                    Layout.fillWidth: true
                                                    text: modelData.content
                                                    wrapMode: Text.Wrap
                                                    maximumLineCount: 1
                                                    elide: Text.ElideRight
                                                    font.pixelSize: 14
                                                    color: "#ffffff"
                                                }

                                                Text {
                                                    visible: modelData.isBinary
                                                    Layout.fillWidth: true
                                                    text: modelData.binaryType + " (" + modelData.binarySize + ")"
                                                    font.pixelSize: 14
                                                    color: "#ffffff"
                                                }

                                                RowLayout {
                                                    visible: modelData.isBinary
                                                    Layout.fillWidth: true
                                                    spacing: 4

                                                    BusyIndicator {
                                                        visible: modelData.previewSource === ""
                                                        Layout.preferredWidth: 20
                                                        Layout.preferredHeight: 20
                                                    }

                                                    Image {
                                                        visible: modelData.previewSource !== ""
                                                        Layout.preferredWidth: 60
                                                        Layout.preferredHeight: 40
                                                        source: modelData.previewSource
                                                        fillMode: Image.PreserveAspectFit
                                                        asynchronous: true
                                                        smooth: true
                                                        opacity: status === Image.Ready ? 1 : 0

                                                        Behavior on opacity {
                                                            NumberAnimation {
                                                                duration: 200
                                                                easing.type: Easing.OutCubic
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            Button {
                                                implicitWidth: 24
                                                implicitHeight: 24
                                                hoverEnabled: true
                                                Layout.alignment: Qt.AlignTop
                                                background: Rectangle {
                                                    radius: 6
                                                    color: parent.hovered || parent.activeFocus ? Appearence.colors.hoverColor : "transparent"
                                                    border.color: parent.activeFocus ? Appearence.colors.accentColor : "transparent"
                                                    border.width: parent.activeFocus ? 2 : 0

                                                    Behavior on color {
                                                        animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                                                    }
                                                    Behavior on border.color {
                                                        animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                                                    }
                                                }
                                                contentItem: Text {
                                                    text: "\uf00d"
                                                    font.family: Appearence.font.nerdFont
                                                    font.pixelSize: 12
                                                    color: Appearence.colors.accentColor
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                                onClicked: Clipboard.deleteEntry(modelData.id)
                                            }
                                        }

                                        Component.onCompleted: {
                                            if (modelData.isBinary && modelData.previewSource === "")
                                                Clipboard.loadImagePreview(index);
                                        }
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: clipboardList.count === 0
                                    color: "#ffffff"
                                    opacity: 0.5
                                    text: "You haven't copied anything!"
                                    font.pixelSize: 14
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
