import QtQuick
import Quickshell
import qs.modules.common

Scope {
    PolkitAuth {
        id: auth
    }

    PolkitDialog {
        auth: auth
        accent: Appearence.colors.polkitAccent
        background: Appearence.colors.polkitBackground
        foreground: Appearence.colors.polkitText
        borderColor: Appearence.colors.polkitBorder
        borderError: Appearence.colors.polkitBorderError
        scrim: Appearence.colors.polkitScrim
    }
}
