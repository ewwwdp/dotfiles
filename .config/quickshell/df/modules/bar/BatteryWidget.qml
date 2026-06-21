import QtQuick
import Quickshell.Services.UPower
import qs.core
import qs.modules.common
import qs.services

BarButton {
    id: root
    visible: BatteryState.available && !BatteryState.isFullAndCharging
    text: {
        let pct = BatteryState.percentage;
        let icon;
        if (pct <= 15)
            icon = "";
        else if (pct <= 35)
            icon = "";
        else if (pct <= 55)
            icon = "";
        else if (pct <= 75)
            icon = "";
        else
            icon = "";

        if (BatteryState.isCharging)
            icon = "";

        return icon;
    }

    textItem.color: {
        if (BatteryState.isCriticalAndNotCharging)
            return Appearence.colors.errorColor;
        if (BatteryState.isLowAndNotCharging)
            return Appearence.colors.errorColor;
        return Appearence.colors.accentColor;
    }

    useNerdFont: true
    fontSize: 12
    horizontalPadding: 10

    onEntered: tooltip.tooltipVisible = true
    onExited: tooltip.tooltipVisible = false

    CustomTooltip {
        id: tooltip
        tooltipVisible: false
        targetItem: root
        positionAbove: false
        text: {
            let time;
            if (BatteryState.isCharging && BatteryState.timeToFull > 0)
                time = "full in " + DateTime.formatBatteryTime(BatteryState.timeToFull);
            else if (BatteryState.chargeState === UPowerDeviceState.Discharging && BatteryState.timeToEmpty > 0)
                time = "empty in " + DateTime.formatBatteryTime(BatteryState.timeToEmpty);

            if (time)
                return Math.round(BatteryState.percentage) + "% | " + time;
            return Math.round(BatteryState.percentage) + "%";
        }
    }
}
