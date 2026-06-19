import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQml.Models
import qs
import qs.services
import qs.modules.common

Scope {
    id: root

    property bool showPinnedOnly: false

    function togglePin(id, content) {
        if (Clipboard.isPinned(id)) {
            Clipboard.unpinEntry(id);
        } else {
            Clipboard.pinEntry(id, content);
        }
        visualModel.applyFilter();
    }

    function getFilteredCount() {
        if (!showPinnedOnly)
            return Clipboard.list.count;
        var count = 0;
        for (var i = 0; i < Clipboard.list.count; i++) {
            if (Clipboard.isPinned(Clipboard.list.get(i).id))
                count++;
        }
        return count;
    }

    DelegateModel {
        id: visualModel
        model: Clipboard.list

        groups: [
            DelegateModelGroup {
                name: "shown"
                includeByDefault: true
            }
        ]

        filterOnGroup: "shown"

        function applyFilter() {
            for (var i = 0; i < items.count; i++) {
                var item = items.get(i);
                var pinned = Clipboard.isPinned(item.model.id);
                if (showPinnedOnly && !pinned) {
                    item.groups = ["items"];
                } else {
                    item.groups = ["shown", "items"];
                }
            }
        }
    }

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
                                    text: showPinnedOnly ? "\uf276" : "\uf0ea"
                                    font.family: Appearence.font.nerdFont
                                    font.pixelSize: 20
                                    color: Appearence.colors.accentColor
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: showPinnedOnly ? "Pinned" : "Clipboard"
                                    font.pixelSize: 16
                                    color: "#ffffff"
                                }

                                Text {
                                    text: "(" + (showPinnedOnly ? getFilteredCount() + "/" + Clipboard.list.count : Clipboard.list.count) + ")"
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
                                    model: visualModel

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
                                        if (event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace || event.key === Qt.Key_X) {
                                            var item = clipboardList.itemAtIndex(clipboardList.currentIndex);
                                            if (item && !Clipboard.isPinned(item.model.id)) {
                                                Clipboard.deleteEntry(item.model.id);
                                            }
                                        } else if (event.key === Qt.Key_Space) {
                                            var item = clipboardList.itemAtIndex(clipboardList.currentIndex);
                                            if (item) {
                                                root.togglePin(item.model.id, item.model.content);
                                            }
                                        } else if (event.key === Qt.Key_P) {
                                            root.showPinnedOnly = !root.showPinnedOnly;
                                            visualModel.applyFilter();
                                            clipboardList.currentIndex = 0;
                                        }
                                    }

                                    Keys.onReturnPressed: {
                                        var item = clipboardList.itemAtIndex(clipboardList.currentIndex);
                                        if (item) {
                                            Clipboard.copyToClipboard(item.model.id);
                                            GlobalStates.clipboardOpen = false;
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
                                            visualModel.applyFilter();
                                            if (Clipboard.pendingListReset) {
                                                clipboardList.currentIndex = 0;
                                                Clipboard.pendingListReset = false;
                                            }
                                        }
                                    }

                                    delegate: MouseArea {
                                        required property var model

                                        implicitHeight: model.isBinary ? 64 : 44
                                        implicitWidth: ListView.view.width

                                        onClicked: {
                                            Clipboard.copyToClipboard(model.id);
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

                                            Text {
                                                text: "\uf08d"
                                                font.family: Appearence.font.nerdFont
                                                font.pixelSize: 12
                                                color: Appearence.colors.accentColor
                                                visible: Clipboard.pinnedIds.indexOf(model.id) >= 0
                                                Layout.alignment: Qt.AlignTop
                                                Layout.topMargin: 2
                                            }

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 2

                                                Text {
                                                    visible: !model.isBinary
                                                    Layout.fillWidth: true
                                                    text: model.content
                                                    wrapMode: Text.Wrap
                                                    maximumLineCount: 1
                                                    elide: Text.ElideRight
                                                    font.pixelSize: 14
                                                    color: "#ffffff"
                                                }

                                                Text {
                                                    visible: model.isBinary
                                                    Layout.fillWidth: true
                                                    text: model.binaryType + " (" + model.binarySize + ")"
                                                    font.pixelSize: 14
                                                    color: "#ffffff"
                                                }

                                                RowLayout {
                                                    visible: model.isBinary
                                                    Layout.fillWidth: true
                                                    spacing: 4

                                                    BusyIndicator {
                                                        visible: model.previewSource === ""
                                                        Layout.preferredWidth: 20
                                                        Layout.preferredHeight: 20
                                                    }

                                                    Image {
                                                        visible: model.previewSource !== ""
                                                        Layout.preferredWidth: 60
                                                        Layout.preferredHeight: 40
                                                        source: model.previewSource
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
                                                enabled: Clipboard.pinnedIds.indexOf(model.id) === -1
                                                opacity: enabled ? 1.0 : 0.3
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
                                                onClicked: {
                                                    if (!Clipboard.isPinned(model.id)) {
                                                        Clipboard.deleteEntry(model.id);
                                                    }
                                                }
                                            }
                                        }

                                        Component.onCompleted: {
                                            if (model.isBinary && model.previewSource === "")
                                                Clipboard.loadImagePreview(Clipboard.findIndex(model.id));
                                        }
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: clipboardList.count === 0
                                    color: "#ffffff"
                                    opacity: 0.5
                                    text: showPinnedOnly ? "No pinned items" : "You haven't copied anything!"
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
