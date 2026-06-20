import qs
import qs.modules.common
import qs.services
import QtQuick

ToggleMenuButton {
    id: root

    active: BluetoothService.ready
    iconText: BluetoothService.materialSymbol
    opacity: BluetoothService.hasDefaultAdapter ? 1.0 : 0.4
    mouseEnabled: BluetoothService.hasDefaultAdapter

    function activate() {
        BluetoothService.toggle();
    }

    onClicked: event => {
        event.accepted = true;
        if (event.button === Qt.RightButton) {
            showMenu = BluetoothService.ready && !showMenu;
        } else {
            showMenu = false;
            BluetoothService.toggle();
        }
    }
}
