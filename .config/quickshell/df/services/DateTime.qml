pragma Singleton
pragma ComponentBehavior: Bound

import qs.core
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    readonly property date date: clock.date
    property string time: Qt.locale().toString(clock.date, "hh:mm")
    property string uptime: "0h, 0m"

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Process {
        id: uptimeProcess
        command: ["cat", "/proc/uptime"]
        running: GlobalStates.sidebarOpen
        stdout: StdioCollector {
            onStreamFinished: {
                const uptimeSeconds = Number(this.text.split(" ")[0] ?? 0);
                root.uptime = root.formatUptime(uptimeSeconds);
            }
        }
    }

    function formatUptime(uptimeSeconds) {
        const days = Math.floor(uptimeSeconds / 86400);
        const hours = Math.floor((uptimeSeconds % 86400) / 3600);
        const minutes = Math.floor((uptimeSeconds % 3600) / 60);
        const parts = [];
        if (days > 0)
            parts.push(`${days}d`);
        if (hours > 0)
            parts.push(`${hours}h`);
        if (minutes > 0 || parts.length === 0)
            parts.push(`${minutes}m`);
        return parts.join(", ");
    }

    function formatBatteryTime(seconds) {
        const h = Math.floor(seconds / 3600);
        const m = Math.floor((seconds % 3600) / 60);
        if (h > 0)
            return h + "h " + m + "m";
        return m + "m";
    }

    function formatTimestamp(timestamp) {
        if (!timestamp)
            return "Now";

        const now = Date.now();
        const diffMs = now - timestamp;
        var diffMins = Math.floor(diffMs / 60000);

        if (diffMins < 1)
            return "Now";
        if (diffMins < 60)
            return diffMins + " min ago";

        var diffHours = Math.floor(diffMins / 60);
        if (diffHours === 1)
            return "1 hour ago";
        if (diffHours < 24)
            return diffHours + " hours ago";

        var diffDays = Math.floor(diffHours / 24);
        if (diffDays === 1)
            return "1 day ago";
        return diffDays + " days ago";
    }
}
