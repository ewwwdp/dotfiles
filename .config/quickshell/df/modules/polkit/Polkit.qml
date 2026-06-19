import QtQuick
import Quickshell
import qs.modules.common

Scope {
    PolkitAuth {
        id: auth
    }

    PolkitDialog {
        auth: auth
    }
}
