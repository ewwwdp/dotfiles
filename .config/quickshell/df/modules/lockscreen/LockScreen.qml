import qs
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
            LockSurface {
                anchors.fill: parent
                context: lockContext
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
