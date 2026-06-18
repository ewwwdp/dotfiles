import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import qs.services
import qs.modules.common
import qs

Scope {
    id: root

    LazyLoader {
        active: GlobalStates.clipboardOpen

        PanelWindow {
            id: window
            implicitWidth: 400
            implicitHeight: 560
            anchors {
                right: true
                bottom: true
                top: true
                left: true
            }
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay

            Item {
                id: rootItem
                anchors.fill: parent
                anchors.margins: 10
                focus: true

                property var filteredItems: []

                function getItem(idx) {
                    var items = searchField.text === "" ? Clipboard.list : filteredItems;
                    if (items.get !== undefined) {
                        return items.get(idx);
                    } else {
                        return items[idx];
                    }
                }

                function updateFilter() {
                    var query = searchField.text.toLowerCase().trim();
                    if (query === "") {
                        filteredItems = [];
                        return;
                    }

                    var result = [];
                    for (var i = 0; i < Clipboard.list.count; i++) {
                        var item = Clipboard.list.get(i);
                        var match = false;

                        if (!item.isBinary && item.content.toLowerCase().includes(query)) {
                            match = true;
                        } else if (item.isBinary && item.binaryType.toLowerCase().includes(query)) {
                            match = true;
                        }

                        if (match) {
                            result.push({
                                id: item.id,
                                content: item.content,
                                isBinary: item.isBinary,
                                binaryType: item.binaryType,
                                binarySize: item.binarySize,
                                binaryDimensions: item.binaryDimensions,
                                previewSource: item.previewSource,
                                originalIndex: i
                            });
                        }
                    }
                    filteredItems = result;
                }

                Connections {
                    target: Clipboard.list
                    function onCountChanged() {
                        rootItem.updateFilter();
                    }
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        GlobalStates.clipboardOpen = false;
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Delete && (event.modifiers & Qt.ControlModifier)) {
                        Clipboard.clearHistory();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Up) {
                        if (clipboardList.currentIndex > 0) {
                            clipboardList.currentIndex--;
                        }
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Down) {
                        if (clipboardList.currentIndex < clipboardList.count - 1) {
                            clipboardList.currentIndex++;
                        }
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (clipboardList.currentIndex >= 0 && clipboardList.count > 0) {
                            var item = rootItem.getItem(clipboardList.currentIndex);
                            if (item) {
                                Clipboard.copyToClipboard(item.id);
                                GlobalStates.clipboardOpen = false;
                            }
                        }
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Delete) {
                        if (clipboardList.currentIndex >= 0 && clipboardList.count > 0) {
                            var item = rootItem.getItem(clipboardList.currentIndex);
                            if (item) {
                                Clipboard.deleteEntry(item.id);
                            }
                        }
                        event.accepted = true;
                    } else if (event.key === Qt.Key_F && (event.modifiers & Qt.ControlModifier)) {
                        searchField.forceActiveFocus();
                        event.accepted = true;
                    }
                }

                Rectangle {
                    id: shadow
                    anchors.fill: parent
                    anchors.topMargin: 4
                    anchors.leftMargin: 4
                    color: "#20000000"
                    radius: 25
                }

                Rectangle {
                    id: bg
                    anchors.fill: parent
                    color: Appearence.colors.barBackgroundColor
                    radius: 25
                }

                ColumnLayout {
                    anchors.fill: bg
                    anchors.topMargin: 20
                    anchors.bottomMargin: 15
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: "\uf0ea"
                            font.family: Appearence.font.nerdFont
                            font.pixelSize: 20
                            color: Appearence.colors.accentColor
                        }

                        RowLayout {
                            Text {
                                text: "Clipboard"
                                font.family: "Outfit SemiBold"
                                font.pixelSize: 18
                                color: Appearence.colors.polkitText
                            }

                            Text {
                                text: "• " + clipboardList.count + (clipboardList.count === 1 ? " item" : " items")
                                font.pixelSize: 12
                                color: Appearence.colors.barBorderColor
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "\uf1f8"
                            font.family: Appearence.font.nerdFont
                            flat: true
                            implicitWidth: 35
                            implicitHeight: 35
                            onClicked: Clipboard.clearHistory()
                        }

                        Button {
                            text: "\uf00d"
                            font.family: Appearence.font.nerdFont
                            flat: true
                            implicitWidth: 35
                            implicitHeight: 35
                            onClicked: GlobalStates.clipboardOpen = false
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "\uf002"
                            font.family: Appearence.font.nerdFont
                            font.pixelSize: 14
                            color: Appearence.colors.barBorderColor
                        }

                        TextField {
                            id: searchField
                            Layout.fillWidth: true
                            placeholderText: "Search..."
                            font.pixelSize: 14
                            color: Appearence.colors.polkitText
                            background: Rectangle {
                                color: "transparent"
                            }

                            onTextChanged: {
                                clipboardList.currentIndex = -1;
                                rootItem.updateFilter();
                            }

                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Escape) {
                                    searchField.text = "";
                                    searchField.focus = false;
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Down) {
                                    if (clipboardList.count > 0) {
                                        clipboardList.currentIndex = 0;
                                    }
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    event.accepted = false;
                                }
                            }
                        }

                        ListView {
                            id: clipboardList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 5
                            clip: true
                            model: searchField.text === "" ? Clipboard.list : rootItem.filteredItems
                            boundsBehavior: Flickable.DragAndOvershootBounds

                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AsNeeded
                                width: 6
                            }

                            ColumnLayout {
                                anchors.centerIn: parent
                                visible: clipboardList.count === 0

                                Text {
                                    color: Appearence.colors.barBorderColor
                                    text: searchField.text === "" ? "You haven't copied anything!" : "Nothing found"
                                    font.pixelSize: 14
                                }
                            }

                            add: Transition {
                                NumberAnimation {
                                    property: "opacity"
                                    from: 0
                                    to: 1
                                    duration: 150
                                    easing.type: Easing.OutExpo
                                }
                            }

                            remove: Transition {
                                NumberAnimation {
                                    property: "opacity"
                                    to: 0
                                    duration: 150
                                    easing.type: Easing.OutExpo
                                }
                            }

                            displaced: Transition {
                                NumberAnimation {
                                    properties: "y"
                                    duration: 350
                                    easing.type: Easing.OutExpo
                                }
                            }

                            delegate: Rectangle {
                                required property var modelData
                                required property int index

                                width: ListView.view.width
                                height: contentLayout.height + 20
                                radius: 20
                                border.width: clipboardList.currentIndex === index ? 1 : 0
                                border.color: Qt.rgba(Appearence.colors.polkitText.r, Appearence.colors.polkitText.g, Appearence.colors.polkitText.b, 0.2)
                                color: {
                                    if (clipboardList.currentIndex === index) {
                                        return Appearence.colors.polkitBackground;
                                    }
                                    return mouseArea.containsMouse ? Appearence.colors.polkitBackground : Appearence.colors.hoverColor;
                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                        easing.type: Easing.OutExpo
                                    }
                                }

                                Behavior on border.width {
                                    NumberAnimation {
                                        duration: 150
                                        easing.type: Easing.OutExpo
                                    }
                                }

                                Component.onCompleted: {
                                    var idx = modelData.originalIndex !== undefined ? modelData.originalIndex : index;
                                    if (modelData.isBinary && modelData.previewSource === "") {
                                        Clipboard.loadImagePreview(idx);
                                    }
                                }

                                RowLayout {
                                    id: contentLayout
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        top: parent.top
                                        margins: 10
                                    }
                                    spacing: 5

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 5

                                        Text {
                                            visible: !modelData.isBinary
                                            Layout.fillWidth: true
                                            text: modelData.content
                                            wrapMode: Text.Wrap
                                            maximumLineCount: 3
                                            elide: Text.ElideRight
                                            font.pixelSize: 13
                                            color: Appearence.colors.polkitText
                                        }

                                        Rectangle {
                                            visible: modelData.isBinary && modelData.previewSource !== ""
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 150
                                            radius: 8
                                            color: Appearence.colors.hoverColor
                                            clip: true

                                            Image {
                                                anchors.fill: parent
                                                source: modelData.previewSource
                                                fillMode: Image.PreserveAspectFit
                                                asynchronous: true
                                                smooth: true
                                                opacity: status === Image.Ready ? 1 : 0

                                                Behavior on opacity {
                                                    NumberAnimation {
                                                        duration: 350
                                                        easing.type: Easing.OutExpo
                                                    }
                                                }
                                            }
                                        }

                                        RowLayout {
                                            visible: modelData.isBinary && modelData.previewSource === ""
                                            Layout.fillWidth: true
                                            spacing: 5

                                            BusyIndicator {
                                                Layout.preferredWidth: 12
                                                Layout.preferredHeight: 12
                                            }

                                            Text {
                                                text: `Loading ${modelData.binaryType}...`
                                                font.pixelSize: 10
                                                color: Appearence.colors.barBorderColor
                                            }
                                        }
                                    }

                                    Button {
                                        text: "\uf00d"
                                        font.family: Appearence.font.nerdFont
                                        font.pixelSize: 12
                                        flat: true
                                        implicitWidth: 25
                                        implicitHeight: 25
                                        Layout.alignment: Qt.AlignTop
                                        onClicked: Clipboard.deleteEntry(modelData.id)
                                    }
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    z: -1
                                    onClicked: {
                                        Clipboard.copyToClipboard(modelData.id);
                                        GlobalStates.clipboardOpen = false;
                                    }
                                }
                            }
                        }
                    }
                }
                HyprlandFocusGrab {
                    id: grab
                    windows: [window]
                }

                onVisibleChanged: {
                    if (visible)
                        grab.active = true;
                }

                Connections {
                    target: grab
                    function onActiveChanged() {
                        if (!grab.active) {
                            GlobalStates.clipboardOpen = false;
                        }
                    }
                }
            }
        }
    }
}
