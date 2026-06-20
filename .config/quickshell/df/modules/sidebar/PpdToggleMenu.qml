import QtQuick
import Quickshell.Services.UPower
import qs.modules.common

ToggleMenuButton {
    id: root

    colorAnimEnabled: false
    iconText: switch (PowerProfiles.profile) {
    case PowerProfile.PowerSaver:
        return "";
    case PowerProfile.Balanced:
        return " ";
    case PowerProfile.Performance:
        return "";
    }

    function activate() {
        if (PowerProfiles.hasPerformanceProfile) {
            switch (PowerProfiles.profile) {
            case PowerProfile.PowerSaver:
                PowerProfiles.profile = PowerProfile.Balanced;
                break;
            case PowerProfile.Balanced:
                PowerProfiles.profile = PowerProfile.Performance;
                break;
            case PowerProfile.Performance:
                PowerProfiles.profile = PowerProfile.PowerSaver;
                break;
            }
        } else {
            PowerProfiles.profile = PowerProfiles.profile == PowerProfile.Balanced ? PowerProfile.PowerSaver : PowerProfile.Balanced;
        }
    }

    onClicked: event => {
        root.activate();
    }
}
