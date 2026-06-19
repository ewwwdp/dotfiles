import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.modules.common
import qs.services

Scope {
    id: root

    readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

    property date currentDate: DateTime.date
    property int viewYear: currentDate.getFullYear()
    property int viewMonth: currentDate.getMonth()

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate();
    }

    function firstDayOfMonth(year, month) {
        return (new Date(year, month, 1).getDay() + 6) % 7;
    }

    LazyLoader {
        active: GlobalStates.calendarOpen

        PanelWindow {
            id: panelWindow
            anchors.top: true
            margins.top: 5
            exclusiveZone: 0
            implicitWidth: 280
            implicitHeight: 280
            color: "transparent"

            WlrLayershell.namespace: "quickshell:calendaroverlay"

            HyprlandFocusGrab {
                windows: [panelWindow]
                active: GlobalStates.calendarOpen
                onCleared: () => {
                    if (!active)
                        GlobalStates.calendarOpen = false;
                }
            }

            Rectangle {
                id: container
                anchors.fill: parent
                radius: 12
                color: Appearence.colors.baseColor
                border.width: 1
                border.color: Appearence.colors.borderColor
                focus: true

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape)
                        GlobalStates.calendarOpen = false;
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            implicitWidth: 28
                            implicitHeight: 28
                            radius: 6
                            color: prevBtn.containsMouse ? Appearence.colors.surfaceHoverColor : "transparent"

                            Behavior on color {
                                animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "◀"
                                color: Appearence.colors.accentColor
                                font.pixelSize: 12
                            }

                            MouseArea {
                                id: prevBtn
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    root.viewMonth--;
                                    if (root.viewMonth < 0) {
                                        root.viewMonth = 11;
                                        root.viewYear--;
                                    }
                                }
                            }
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: root.monthNames[root.viewMonth] + " " + root.viewYear
                    color: Appearence.colors.textColor
                    font.pixelSize: 14
                            font.weight: Font.Medium
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Rectangle {
                            implicitWidth: 28
                            implicitHeight: 28
                            radius: 6
                            color: nextBtn.containsMouse ? Appearence.colors.surfaceHoverColor : "transparent"

                            Behavior on color {
                                animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "▶"
                                color: Appearence.colors.accentColor
                                font.pixelSize: 12
                            }

                            MouseArea {
                                id: nextBtn
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    root.viewMonth++;
                                    if (root.viewMonth > 11) {
                                        root.viewMonth = 0;
                                        root.viewYear++;
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Appearence.colors.borderColor
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Grid {
                            id: calendarGrid
                            anchors.fill: parent
                            columns: 7
                            spacing: 2

                            readonly property int cellWidth: width > (columns - 1) * spacing ? Math.floor((width - (columns - 1) * spacing) / columns) : 0
                            readonly property int cellHeight: 28

                            Repeater {
                                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

                                StyledText {
                                    width: calendarGrid.cellWidth
                                    height: 24
                                    text: modelData
                                    color: Appearence.colors.textMutedColor
                                    font.pixelSize: 11
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Repeater {
                                model: root.firstDayOfMonth(root.viewYear, root.viewMonth)

                                Item {
                                    width: calendarGrid.cellWidth
                                    height: calendarGrid.cellHeight
                                }
                            }

                            Repeater {
                                model: root.daysInMonth(root.viewYear, root.viewMonth)

                                Rectangle {
                                    required property int index

                                    readonly property int dayNumber: index + 1
                                    readonly property bool isToday: {
                                        const d = root.currentDate;
                                        return root.viewYear === d.getFullYear() && root.viewMonth === d.getMonth() && dayNumber === d.getDate();
                                    }

                                    width: calendarGrid.cellWidth
                                    height: calendarGrid.cellHeight
                                    radius: 6
                                    color: isToday ? Appearence.colors.accentColor : (dayMouse.containsMouse ? Appearence.colors.surfaceHoverColor : "transparent")

                                    Behavior on color {
                                        animation: Appearence.animation.elementMoveFast.colorAnimation.createObject(this)
                                    }

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: parent.dayNumber.toString()
                                        color: parent.isToday ? Appearence.colors.baseColor : Appearence.colors.textColor
                                        font.pixelSize: 12
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    MouseArea {
                                        id: dayMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
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
