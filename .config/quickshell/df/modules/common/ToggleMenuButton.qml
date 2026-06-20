import QtQuick
import qs.modules.common

Rectangle {
    id: root

    property bool isFocused: false
    property bool active: false
    property string iconText: ""
    property color activeColor: Appearence.colors.accentColor
    property color inactiveColor: Appearence.colors.baseColor
    property color activeTextColor: Appearence.colors.surfaceHoverColor
    property color inactiveTextColor: Appearence.colors.textColor
    property alias acceptedButtons: mouseArea.acceptedButtons
    property alias mouseEnabled: mouseArea.enabled
    property bool showMenu: false
    property bool colorAnimEnabled: true

    signal clicked(var event)

    function activate() {
    }

    width: 48
    height: 48
    radius: 24
    color: active ? activeColor : inactiveColor
    border.width: 2
    border.color: isFocused ? Appearence.colors.focusColor : Appearence.colors.textMutedColor
    scale: mouseArea.containsMouse ? 1.1 : 1.0

    StyledText {
        color: root.active ? root.activeTextColor : root.inactiveTextColor
        anchors.centerIn: parent
        text: root.iconText
        font.family: Appearence.font.nerdFont
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            event.accepted = true;
            root.clicked(event);
        }
    }

    Behavior on scale {
        animation: Appearence.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
    Behavior on color {
        animation: Appearence.animation.elementMove.colorAnimation.createObject(this)
        enabled: root.colorAnimEnabled
    }
}
