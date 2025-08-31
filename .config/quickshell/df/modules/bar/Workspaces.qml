import QtQuick
import Quickshell.Hyprland
import qs.modules.common

Item {
    id: root
    required property var barRoot
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(barRoot.screen)
    readonly property int maxInGroup: 5
    readonly property int workspaceGroup: Math.floor((monitor.activeWorkspace?.id - 1) / maxInGroup)
    property list<bool> workspaceOccupied: []
    property int workspaceButtonWidth: 12
    property int workspaceIndexInGroup: (monitor.activeWorkspace?.id - 1) % maxInGroup
    readonly property string inactiveColor: "transparent"
    readonly property string occupiedColor: "#2b2b2b"
    readonly property string backgroundColor: "transparent"
    function updateWorkspaceOccupied() {
        workspaceOccupied = Array.from({
            length: maxInGroup
        }, (_, i) => {
            return Hyprland.workspaces.values.some(ws => ws.id === workspaceGroup * maxInGroup + i + 1);
        });
    }

    Component.onCompleted: updateWorkspaceOccupied()

    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            root.updateWorkspaceOccupied();
        }
    }
    // Black bacground
    Rectangle {
        z: -1
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: -5
        color: Appearence.colors.pureBlackColor
        width: rowLayout.width
        height: rowLayout.height

        radius: 10
        WheelHandler {
            onWheel: event => {
                const direction = event.angleDelta.y > 0 ? "r-1" : event.angleDelta.y < 0 ? "r+1" : null;
                if (direction)
                    Hyprland.dispatch(`workspace ${direction}`);
                event.accepted = true;
            }

            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        }
    }

    Row {
        id: rowLayout
        spacing: 0
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: -5
        Repeater {
            model: root.maxInGroup

            Rectangle {
                id: rect
                property bool isHovered: false
                property int workspaceId: root.workspaceGroup * root.maxInGroup + index + 1
                property bool isActive: workspaceId === (monitor.activeWorkspace?.id ?? -1)
                property bool isOccupied: root.workspaceOccupied[index]

                width: workspaceButtonWidth + 18
                height: 24
                radius: width / (2 / 3)
                color: (isActive || isHovered) ? Appearence.colors.hoverColor : "transparent"
                Behavior on color {
                    animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                }
                MouseArea {
                    hoverEnabled: true
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch(`workspace ${workspaceId}`)
                    onHoveredChanged: rect.isHovered = !rect.isHovered
                }

                Rectangle {
                    id: circle
                    width: workspaceButtonWidth
                    height: workspaceButtonWidth
                    anchors.centerIn: parent
                    radius: workspaceButtonWidth / 2
                    border.color: {
                        if (rect.isActive | rect.isOccupied)
                            return Appearence.colors.accentColor;
                        return root.occupiedColor;
                    }
                    border.width: 1

                    color: {
                        if (rect.isActive)
                            return Appearence.colors.accentColor;
                        return root.inactiveColor;
                    }

                    Behavior on color {
                        animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                    }
                }
            }
        }
    }
}
