pragma Singleton
pragma ComponentBehavior: Bound
import qs
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property string time: Qt.locale().toString(clock.date, "hh:mm")
    property var dateT: clock.date
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
}
