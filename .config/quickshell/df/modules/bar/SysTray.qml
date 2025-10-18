import qs.modules.common
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

Item {
    id: root
    visible: {
        SystemTray.items.values.length > 0;
    }
    required property var bar

    implicitWidth: rowLayout.implicitWidth
    implicitHeight: 20
    Rectangle {
        width: rowLayout.width + 16
        height: rowLayout.height + 5
        color: mouseArea.containsMouse ? Appearence.colors.hoverColor : "transparent"
        radius: 10
        anchors.centerIn: parent
        MouseArea {
            id: mouseArea
            hoverEnabled: true
            anchors.fill: parent
        }
        RowLayout {
            id: rowLayout
            anchors.centerIn: parent
            spacing: 5

            ListModel {
                id: sortedModel
            }

            Component.onCompleted: {
                sortItems();
            }

            Connections {
                target: SystemTray.items

                function onObjectRemovedPost() {
                    rowLayout.sortItems();
                }
                function onObjectInsertedPost() {
                    rowLayout.sortItems();
                }
            }

            function sortItems() {
                sortedModel.clear();
                let tempArray = [];
                if (SystemTray.items && SystemTray.items.values) {
                    const values = SystemTray.items.values;
                    for (let i = 0; i < values.length; i++) {
                        const item = values[i];
                        if (item) {
                            tempArray.push(item);
                        }
                    }
                }

                tempArray.sort(function (a, b) {
                    const aId = (a && a.id) ? String(a.id) : "";
                    const bId = (b && b.id) ? String(b.id) : "";
                    const idCompare = aId.localeCompare(bId);
                    if (idCompare !== 0) {
                        return idCompare;
                    }
                    const aName = (a && a.tooltipTitle) ? String(a.tooltipTitle) : "";
                    const bName = (b && b.tooltipTitle) ? String(b.tooltipTitle) : "";
                    return aName.localeCompare(bName);
                });

                for (let i = 0; i < tempArray.length; i++) {
                    sortedModel.append({
                        "itemObject": tempArray[i]
                    });
                }
            }

            Repeater {
                model: sortedModel
                SysTrayItem {
                    required property SystemTrayItem modelData
                    bar: root.bar
                    item: modelData
                }
            }
        }
    }
}
