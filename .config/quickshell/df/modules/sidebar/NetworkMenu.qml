import qs
import qs.modules.common
import qs.services
import QtQuick

Rectangle {
    id: root

    property bool isFocused: false
    property bool showMenu: false

    function activate() {
        if (NetworkService.hasWifi) {
            NetworkService.toggleWifi();
        } else {
            showMenu = NetworkService.hasNetwork && !showMenu;
        }
    }

    readonly property bool isActive: NetworkService.wifiEnabled || NetworkService.ethConnected

    width: 48
    height: 48
    radius: 24
    color: isActive ? Appearence.colors.accentColor : Appearence.colors.baseColor
    border.width: 2
    border.color: isFocused ? Appearence.colors.focusColor : Appearence.colors.textMutedColor
    scale: mouseArea.containsMouse ? 1.1 : 1.0
    opacity: NetworkService.hasNetwork ? 1.0 : 0.4

    StyledText {
        color: isActive ? Appearence.colors.surfaceHoverColor : Appearence.colors.textColor
        anchors.centerIn: parent
        text: NetworkService.materialSymbol
        font.family: Appearence.font.nerdFont
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: NetworkService.hasNetwork
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            event.accepted = true;
            if (event.button === Qt.RightButton) {
                showMenu = NetworkService.hasNetwork && !showMenu;
            } else if (NetworkService.hasWifi) {
                showMenu = false;
                NetworkService.toggleWifi();
            } else {
                showMenu = !showMenu;
            }
        }
    }

    Behavior on color {
        animation: Appearence.animation.elementMove.colorAnimation.createObject(this)
    }
    Behavior on scale {
        animation: Appearence.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
}
