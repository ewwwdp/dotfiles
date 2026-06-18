//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_SCALE_FACTOR=1
import qs.modules.bar
import qs.modules.overlay
import qs.modules.sidebar
import qs.modules.session
import qs.modules.lockscreen
import qs.modules.background
import qs.modules.notificationPopup
import qs.modules.polkit
import qs.modules.screenshot as Screenshot
import qs.modules.launcher as Launcher
import qs.modules.clipboard

import QtQuick
import Quickshell

ShellRoot {
    id: root

    Background {}

    Bar {}

    SoundOverlay {}

    MonitorsOverlay {}

    LazyLoader {
        active: true
        component: Sidebar {}
    }

    Session {}

    LazyLoader {
        active: true
        component: NotificationPopup {}
    }
    LazyLoader {
        active: true
        component: LockScreen {}
    }
    LazyLoader {
        active: true
        component: Polkit {}
    }

    CalendarOverlay {}

    Screenshot.Controller {}

    WallpaperOverlay {}

    Launcher.Controller {}

    Cliphist {}
}
