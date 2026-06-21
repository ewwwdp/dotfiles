pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.UPower
import QtQuick
import Quickshell.Io
import qs.core

Singleton {
    id: root

    readonly property UPowerDevice device: {
        const devList = UPower.devices.values;
        for (let i = 0; i < devList.length; ++i) {
            if (devList[i].type === UPowerDeviceType.Battery)
                return devList[i];
        }
        return UPower.displayDevice;
    }
    property bool available: device?.type === UPowerDeviceType.Battery
    property var chargeState: device?.state ?? UPowerDeviceState.Unknown
    property bool isCharging: chargeState === UPowerDeviceState.Charging
    property bool isPluggedIn: chargeState === UPowerDeviceState.Charging || chargeState === UPowerDeviceState.PendingCharge
    property real percentage: (device?.percentage ?? 0) * 100

    readonly property var _batteryCfg: Config.configData.battery ?? ({})
    property int lowThreshold: _batteryCfg.lowThreshold ?? 20
    property int criticalThreshold: _batteryCfg.criticalThreshold ?? 10
    property int fullThreshold: _batteryCfg.fullThreshold ?? 95

    property bool isLow: available && (percentage <= lowThreshold)
    property bool isCritical: available && (percentage <= criticalThreshold)
    property bool isFull: available && (percentage >= fullThreshold)

    property bool isLowAndNotCharging: isLow && !isCharging
    property bool isCriticalAndNotCharging: isCritical && !isCharging
    property bool isFullAndCharging: isFull && isCharging

    property real energyRate: device?.changeRate ?? 0
    property real timeToEmpty: device?.timeToEmpty ?? 0
    property real timeToFull: device?.timeToFull ?? 0

    property real health: {
        const devList = UPower.devices.values;
        for (let i = 0; i < devList.length; ++i) {
            const dev = devList[i];
            if (dev.isLaptopBattery && dev.healthSupported) {
                const h = dev.healthPercentage;
                if (h === 0)
                    return 0.01;
                return h < 1 ? h * 100 : h;
            }
        }
        return 0;
    }

    onIsLowAndNotChargingChanged: {
        if (!root.available || !isLowAndNotCharging)
            return;
        const cfg = Config.configData.battery ?? {};
        Quickshell.execDetached(["notify-send", cfg.lowTitle ?? "Low battery", cfg.lowBody ?? "Consider plugging in your device", "-u", "critical", "-a", "Shell", "--hint=int:transient:1",]);
    }

    onIsCriticalAndNotChargingChanged: {
        if (!root.available || !isCriticalAndNotCharging)
            return;
        const cfg = Config.configData.battery ?? {};
        Quickshell.execDetached(["notify-send", cfg.criticalTitle ?? "Critically low battery", cfg.criticalBody ?? "Please charge!", "-u", "critical", "-a", "Shell", "--hint=int:transient:1",]);
    }

    onIsFullAndChargingChanged: {
        if (!root.available || !isFullAndCharging)
            return;
        const cfg = Config.configData.battery ?? {};
        Quickshell.execDetached(["notify-send", cfg.fullTitle ?? "Battery full", cfg.fullBody ?? "Please unplug the charger", "-a", "Shell", "--hint=int:transient:1",]);
    }
}
