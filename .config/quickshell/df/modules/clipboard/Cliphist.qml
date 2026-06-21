import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQml.Models
import qs.core
import qs.services
import qs.modules.common

Scope {
    id: root

    property bool showPinnedOnly: false

    readonly property var _kb: (() => {
            function key(name) {
                const named = {
                    "Escape": Qt.Key_Escape,
                    "Tab": Qt.Key_Tab,
                    "Backspace": Qt.Key_Backspace,
                    "Return": Qt.Key_Return,
                    "Enter": Qt.Key_Enter,
                    "Delete": Qt.Key_Delete,
                    "Space": Qt.Key_Space,
                    "Insert": Qt.Key_Insert,
                    "Home": Qt.Key_Home,
                    "End": Qt.Key_End,
                    "PageUp": Qt.Key_PageUp,
                    "PageDown": Qt.Key_PageDown,
                    "Up": Qt.Key_Up,
                    "Down": Qt.Key_Down,
                    "Left": Qt.Key_Left,
                    "Right": Qt.Key_Right,
                    "CapsLock": Qt.Key_CapsLock,
                    "NumLock": Qt.Key_NumLock,
                    "ScrollLock": Qt.Key_ScrollLock,
                    "Print": Qt.Key_Print,
                    "Pause": Qt.Key_Pause,
                    "Menu": Qt.Key_Menu,
                    "Period": Qt.Key_Period,
                    "Comma": Qt.Key_Comma,
                    "Slash": Qt.Key_Slash,
                    "Backslash": Qt.Key_Backslash,
                    "Semicolon": Qt.Key_Semicolon,
                    "Apostrophe": Qt.Key_Apostrophe,
                    "Minus": Qt.Key_Minus,
                    "Equal": Qt.Key_Equal,
                    "BracketLeft": Qt.Key_BracketLeft,
                    "BracketRight": Qt.Key_BracketRight,
                    "QuoteLeft": Qt.Key_QuoteLeft
                };
                for (let i = 1; i <= 35; i++)
                    named["F" + i] = Qt["Key_F" + i];
                return named[name] ?? (name.length === 1 ? name.toUpperCase().charCodeAt(0) : 0);
            }
            const C = Config.configData.clipboard ?? {};
            const def = ["Delete", "Backspace", "X"];
            return {
                deleteKeys: (C.deleteKeys ?? def).map(n => key(n)).filter(k => k),
                pinKey: key(C.pinKey) || Qt.Key_Space,
                toggleKey: key(C.togglePinnedKey) || Qt.Key_P,
                copyKey: key(C.copyKey) || Qt.Key_Return,
                closeKey: key(C.closeKey) || Qt.Key_Escape
            };
        })()

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
                        color: Appearence.colors.popupBgColor
                        radius: 10
                        border.color: Appearence.colors.popupBorderColor
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
                                    color: Appearence.colors.whiteColor
                                }

                                Text {
                                    text: "(" + (showPinnedOnly ? getFilteredCount() + "/" + Clipboard.list.count : Clipboard.list.count) + ")"
                                    font.pixelSize: 12
                                    color: Appearence.colors.textMutedColor
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
                                            duration: Appearence.animation.elementResize.duration
                                            easing.type: Appearence.animation.elementResize.type
                                        }
                                    }

                                    displaced: Transition {
                                        NumberAnimation {
                                            property: "y"
                                            duration: Appearence.animation.standardEnter.duration
                                            easing.type: Appearence.animation.standardEnter.type
                                        }
                                    }

                                    move: Transition {
                                        NumberAnimation {
                                            property: "y"
                                            duration: Appearence.animation.standardEnter.duration
                                            easing.type: Appearence.animation.standardEnter.type
                                        }
                                    }

                                    remove: Transition {
                                        NumberAnimation {
                                            property: "opacity"
                                            to: 0
                                            duration: Appearence.animation.elementResize.duration
                                            easing.type: Appearence.animation.elementResize.type
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
                                        const k = event.key;
                                        if (k === root._kb.closeKey) {
                                            GlobalStates.clipboardOpen = false;
                                        } else if (root._kb.deleteKeys.indexOf(k) >= 0) {
                                            var item = clipboardList.itemAtIndex(clipboardList.currentIndex);
                                            if (item && !Clipboard.isPinned(item.model.id)) {
                                                Clipboard.deleteEntry(item.model.id);
                                            }
                                        } else if (k === root._kb.pinKey) {
                                            var item = clipboardList.itemAtIndex(clipboardList.currentIndex);
                                            if (item) {
                                                root.togglePin(item.model.id, item.model.content);
                                            }
                                        } else if (k === root._kb.toggleKey) {
                                            root.showPinnedOnly = !root.showPinnedOnly;
                                            visualModel.applyFilter();
                                            clipboardList.currentIndex = 0;
                                        } else if (k === root._kb.copyKey) {
                                            var item = clipboardList.itemAtIndex(clipboardList.currentIndex);
                                            if (item) {
                                                Clipboard.copyToClipboard(item.model.id);
                                                GlobalStates.clipboardOpen = false;
                                            }
                                        }
                                    }

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
                                                    color: Appearence.colors.whiteColor
                                                }

                                                Text {
                                                    visible: model.isBinary
                                                    Layout.fillWidth: true
                                                    text: model.binaryType + " (" + model.binarySize + ")"
                                                    font.pixelSize: 14
                                                    color: Appearence.colors.whiteColor
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
                                                            animation: Appearence.animation.standardEnter.numberAnimation.createObject(this)
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
                                    color: Appearence.colors.whiteColor
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
