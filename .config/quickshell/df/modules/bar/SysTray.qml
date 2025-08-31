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

            Repeater {
                model: SystemTray.items

                SysTrayItem {
                    required property SystemTrayItem modelData

                    bar: root.bar
                    item: modelData
                }
            }
        }
    }
}
