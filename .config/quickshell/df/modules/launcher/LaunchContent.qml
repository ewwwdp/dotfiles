import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs
import qs.modules.common

Item {
    id: root
    height: 7 + searchContainer.implicitHeight + list.topMargin * 2 + list.delegateHeight * 10
    width: 450

    property var launcherHistory: []

    FileView {
        id: launcherFileView
        path: Qt.resolvedUrl(Directories.launcherCache)
        onLoaded: {
            root.launcherHistory = JSON.parse(launcherFileView.text());
        }
        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                root.launcherHistory = [];
                launcherFileView.setText("[]");
            }
        }
    }

    function recordLaunch(appName: string): void {
        let history = [...root.launcherHistory];
        let found = false;
        for (let i = 0; i < history.length; i++) {
            if (history[i].name === appName) {
                history[i].count++;
                found = true;
                break;
            }
        }
        if (!found) {
            history.push({
                name: appName,
                count: 1
            });
        }
        history.sort((a, b) => b.count - a.count);
        if (history.length > 50)
            history = history.slice(0, 50);
        root.launcherHistory = history;
        launcherFileView.setText(JSON.stringify(history));
    }

    Rectangle {
        id: content
        height: 7 + searchContainer.implicitHeight + list.topMargin + list.bottomMargin + Math.min(list.contentHeight, list.delegateHeight * 10)
        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        width: 450
        color: "#171717"
        radius: 10
        border.color: "#262626"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 7
            anchors.bottomMargin: 0
            spacing: 0

            Rectangle {
                id: searchContainer
                Layout.fillWidth: true
                implicitHeight: searchbox.implicitHeight + 10
                color: "#262626"
                radius: 0
                border.color: "transparent"
                border.width: 0

                RowLayout {
                    id: searchbox
                    anchors.fill: parent
                    anchors.margins: 5

                    StyledText {
                        id: soundIcon
                        font.family: Appearence.font.nerdFont
                        font.pixelSize: 20
                        color: Appearence.colors.accentColor
                        text: "\ue68f"
                    }

                    TextInput {
                        id: search
                        Layout.fillWidth: true
                        color: "#ffffff"

                        focus: true
                        Keys.forwardTo: [list]
                        Keys.onEscapePressed: GlobalStates.launcherOpen = false

                        Keys.onPressed: event => {
                            if (event.modifiers & Qt.ControlModifier) {
                                if (event.key == Qt.Key_J) {
                                    list.currentIndex = list.currentIndex == list.count - 1 ? 0 : list.currentIndex + 1;
                                    event.accepted = true;
                                } else if (event.key == Qt.Key_K) {
                                    list.currentIndex = list.currentIndex == 0 ? list.count - 1 : list.currentIndex - 1;
                                    event.accepted = true;
                                }
                            }
                        }

                        onAccepted: {
                            if (list.currentItem) {
                                list.currentItem.clicked(null);
                            }
                        }

                        onTextChanged: {
                            list.currentIndex = 0;
                        }
                    }
                }
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                cacheBuffer: 0
                model: ScriptModel {
                    values: DesktopEntries.applications.values.map(object => {
                        const stxt = search.text.toLowerCase();
                        const ntxt = object.name.toLowerCase();
                        let si = 0;
                        let ni = 0;

                        let matches = [];
                        let startMatch = -1;

                        for (let si = 0; si != stxt.length; ++si) {
                            const sc = stxt[si];

                            while (true) {
                                if (ni == ntxt.length)
                                    return null;

                                const nc = ntxt[ni++];

                                if (nc == sc) {
                                    if (startMatch == -1)
                                        startMatch = ni;
                                    break;
                                } else {
                                    if (startMatch != -1) {
                                        matches.push({
                                            index: startMatch,
                                            length: ni - startMatch
                                        });

                                        startMatch = -1;
                                    }
                                }
                            }
                        }

                        if (startMatch != -1) {
                            matches.push({
                                index: startMatch,
                                length: ni - startMatch + 1
                            });
                        }

                        return {
                            object: object,
                            matches: matches
                        };
                    }).filter(entry => entry !== null).sort((() => {
                            const history = root.launcherHistory;
                            const counts = {};
                            for (const entry of history)
                                counts[entry.name] = entry.count;

                            return (a, b) => {
                                const ca = counts[a.object.name] ?? 0;
                                const cb = counts[b.object.name] ?? 0;

                                if (ca !== cb)
                                    return cb - ca;

                                let ai = 0;
                                let bi = 0;
                                let s = 0;

                                while (ai != a.matches.length && bi != b.matches.length) {
                                    const am = a.matches[ai];
                                    const bm = b.matches[bi];

                                    s = bm.length - am.length;
                                    if (s != 0)
                                        return s;

                                    s = am.index - bm.index;
                                    if (s != 0)
                                        return s;

                                    ++ai;
                                    ++bi;
                                }

                                s = a.matches.length - b.matches.length;
                                if (s != 0)
                                    return s;

                                s = a.object.name.length - b.object.name.length;
                                if (s != 0)
                                    return s;

                                return a.object.name.localeCompare(b.object.name);
                            };
                        })()).map(entry => entry.object)

                    onValuesChanged: list.currentIndex = 0
                }

                topMargin: 7
                bottomMargin: list.count == 0 ? 0 : 7

                add: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 100
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
                    border.color: "transparent"
                    border.width: 0
                }

                keyNavigationEnabled: true
                keyNavigationWraps: true
                highlightMoveVelocity: -1
                highlightMoveDuration: 100
                preferredHighlightBegin: list.topMargin
                preferredHighlightEnd: list.height - list.bottomMargin
                highlightRangeMode: ListView.ApplyRange
                snapMode: ListView.SnapToItem

                readonly property real delegateHeight: 48

                delegate: MouseArea {
                    required property DesktopEntry modelData

                    implicitHeight: list.delegateHeight
                    implicitWidth: ListView.view.width

                    onClicked: {
                        root.recordLaunch(modelData.name);
                        Quickshell.execDetached(["uwsm", "app", "--"].concat(modelData.command));
                        GlobalStates.launcherOpen = false;
                    }

                    RowLayout {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: 10
                            right: parent.right
                            rightMargin: 10
                        }
                        spacing: 10

                        IconImage {
                            Layout.alignment: Qt.AlignVCenter
                            asynchronous: true
                            implicitSize: 40
                            source: Quickshell.iconPath(modelData.icon)
                            Rectangle {
                                anchors.fill: parent
                                color: "#262626"
                                radius: 6
                                z: -1
                            }
                        }
                        Text {
                            text: modelData.name
                            color: "#ffffff"
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignLeft
                            Layout.alignment: Qt.AlignVCenter
                            font.pixelSize: 16
                        }
                    }
                }
            }
        }
    }
}
