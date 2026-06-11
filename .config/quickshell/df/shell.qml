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

import QtQuick
import Quickshell

ShellRoot {
    id: root
    LazyLoader {
        active: true
        component: Background {}
    }
    LazyLoader {
        active: true
        component: Bar {}
    }
    LazyLoader {
        active: true
        component: SoundOverlay {}
    }
    LazyLoader {
        active: true
        component: MonitorsOverlay {}
    }
    LazyLoader {
        active: true
        component: Sidebar {}
    }
    LazyLoader {
        active: true
        component: Session {}
    }
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
    LazyLoader {
        active: true
        component: CalendarOverlay {}
    }
    LazyLoader {
        active: true
        component: Screenshot.Controller {}
    }
    LazyLoader {
        active: true
        component: Launcher.Controller {}
    }
}
