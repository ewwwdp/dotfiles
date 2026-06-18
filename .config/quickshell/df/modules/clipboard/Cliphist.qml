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
            if (active) Clipboard.fetchListProc = true;
        }

        PanelWindow {
            id: clipboardWindow
            color: "transparent"
            implicitWidth: content.width
            implicitHeight: content.height
            WlrLayershell.namespace: "shell:clipboard"

            HyprlandFocusGrab {
                windows: [clipboardWindow]
                active: true
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
                                    text: "\uf1f8"
                                    font.family: Appearence.font.nerdFont
                                    font.pixelSize: 14
                                    flat: true
                                    implicitWidth: 32
                                    implicitHeight: 32
                                    onClicked: Clipboard.clearHistory()
                                }

                                Button {
                                    text: "\uf00d"
                                    font.family: Appearence.font.nerdFont
                                    font.pixelSize: 14
                                    flat: true
                                    implicitWidth: 32
                                    implicitHeight: 32
                                    onClicked: GlobalStates.clipboardOpen = false
                                }
                            }

                            ListView {
                                id: clipboardList
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                focus: true
                                model: Clipboard.list

                                topMargin: 4
                                bottomMargin: clipboardList.count === 0 ? 0 : 4

                                ScrollBar.vertical: ScrollBar {
                                    policy: ScrollBar.AsNeeded
                                    width: 6
                                }

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    visible: clipboardList.count === 0

                                    Text {
                                        color: "#ffffff"
                                        opacity: 0.5
                                        text: "You haven't copied anything!"
                                        font.pixelSize: 14
                                    }
                                }

                                displaced: Transition {
                                    NumberAnimation {
                                        property: "y"
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }
                                    NumberAnimation {
                                        property: "opacity"
                                        to: 1
                                        duration: 100
                                    }
                                }

                                move: Transition {
                                    NumberAnimation {
                                        property: "y"
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }
                                    NumberAnimation {
                                        property: "opacity"
                                        to: 1
                                        duration: 100
                                    }
                                }

                                remove: Transition {
                                    NumberAnimation {
                                        property: "y"
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }
                                    NumberAnimation {
                                        property: "opacity"
                                        to: 0
                                        duration: 100
                                    }
                                }

                                highlight: Rectangle {
                                    radius: 8
                                    color: "#262626"
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
                                        clipboardList.currentIndex = 0;
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
                                                    Layout.preferredWidth: 10
                                                    Layout.preferredHeight: 10
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
                                            text: "\uf00d"
                                            font.family: Appearence.font.nerdFont
                                            font.pixelSize: 12
                                            flat: true
                                            implicitWidth: 24
                                            implicitHeight: 24
                                            Layout.alignment: Qt.AlignTop
                                            onClicked: Clipboard.deleteEntry(modelData.id)
                                        }
                                    }

                                    Component.onCompleted: {
                                        var idx = modelData.originalIndex !== undefined ? modelData.originalIndex : index;
                                        if (modelData.isBinary && modelData.previewSource === "")
                                            Clipboard.loadImagePreview(idx);
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
