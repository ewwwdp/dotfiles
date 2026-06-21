import qs.core
import QtQuick
import Quickshell
import Quickshell.Wayland

Scope {
    LockContext {
        id: lockContext

        onUnlocked: {
            GlobalStates.screenLocked = false;
        }
    }

    WlSessionLock {
        id: lock
        locked: GlobalStates.screenLocked
        WlSessionLockSurface {
            id: wlSurface
            LockSurface {
                anchors.fill: parent
                context: lockContext
                screenName: wlSurface.screen.name
            }
        }
    }

    Connections {
        target: GlobalStates
        function onScreenLockedChanged() {
            lock.locked = GlobalStates.screenLocked;
        }
    }
}
