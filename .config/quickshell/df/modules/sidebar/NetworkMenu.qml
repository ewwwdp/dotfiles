import qs.modules.common
import qs.services
import QtQuick

ToggleMenuButton {
    id: root

    active: NetworkService.wifiEnabled || NetworkService.ethConnected
    iconText: NetworkService.materialSymbol
    opacity: NetworkService.hasNetwork ? 1.0 : 0.4
    mouseEnabled: NetworkService.hasNetwork

    function activate() {
        if (NetworkService.hasWifi) {
            NetworkService.toggleWifi();
        } else {
            showMenu = NetworkService.hasNetwork && !showMenu;
        }
    }

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
