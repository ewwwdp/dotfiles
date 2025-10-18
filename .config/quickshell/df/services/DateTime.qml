pragma Singleton
pragma ComponentBehavior: Bound
import qs
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
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

    function getCalendar() {
        const now = clock.date;
        const year = now.getFullYear();
        const month = now.getMonth();
        const today = now.getDate();

        const firstDay = (new Date(year, month, 1).getDay() + 6) % 7;
        const daysInMonth = new Date(year, month + 1, 0).getDate();
        const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

        let cal = `${monthNames[month]} ${year}\n`;
        cal += "Mo Tu We Th Fr Sa Su\n";

        for (let i = 0; i < firstDay; i++) {
            cal += "   ";
        }

        let currentCol = firstDay;
        for (let day = 1; day <= daysInMonth; day++) {
            const dayStr = day < 10 ? '0' + day : '' + day;

            if (currentCol === 6) {
                cal += dayStr + "\n";
                currentCol = 0;
            } else {
                cal += dayStr + " ";
                currentCol++;
            }
        }
        let end = cal.length - 1;
        while (end >= 0 && (cal[end] === ' ' || cal[end] === '\n' || cal[end] === '\t')) {
            end--;
        }

        const result = cal.substring(0, end + 1);
        return result + (currentCol > 0 ? '\n' : '');
    }
}
