//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_SCALE_FACTOR=1
import qs.modules.bar
import qs.modules.overlay
import qs.modules.sidebar
import qs.modules.session
import qs.modules.notificationPopup

import QtQuick
import Quickshell

ShellRoot {
    id: root
    LazyLoader {
        active: true
        component: Bar {}
    }
    LazyLoader {
        active: true
        component: SoundOverlay {}
    }
    // LazyLoader {
    //     active: false
    //     component: ReloadPopup {}
    // }

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
}
