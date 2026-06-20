import qs
import qs.modules.common
import QtQuick
import Quickshell

ToggleMenuButton {
    id: root

    active: GlobalStates.gamemodeEnabled
    iconText: GlobalStates.gamemodeEnabled ? "" : ""
    acceptedButtons: Qt.LeftButton

    function activate() {
        Quickshell.execDetached(["sh", "-c", `${Quickshell.shellDir}/scripts/gamemode.sh`]);
        GlobalStates.gamemodeEnabled = !GlobalStates.gamemodeEnabled;
    }

    onClicked: event => {
        root.activate();
    }
}
