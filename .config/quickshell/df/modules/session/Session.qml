import qs
import QtQuick
import Quickshell

Scope {
    Loader {

        active: GlobalStates.isSessionOpen
        sourceComponent: WLogout {
            LogoutButton {
                command: "loginctl lock-session"
                keybind: Qt.Key_L
                text: "Lock"
                icon: ""
            }

            LogoutButton {
                command: "loginctl terminate-user $USER"
                keybind: Qt.Key_E
                text: "Logout"
                icon: "󰍃"
            }

            LogoutButton {
                command: "systemctl suspend"
                keybind: Qt.Key_U
                text: "Suspend"
                icon: "󰏦"
            }

            LogoutButton {
                command: "systemctl hibernate"
                keybind: Qt.Key_H
                text: "Hibernate"
                icon: "󰤁"
            }

            LogoutButton {
                command: "systemctl poweroff"
                keybind: Qt.Key_S
                text: "Shutdown"
                icon: ""
            }

            LogoutButton {
                command: "systemctl reboot"
                keybind: Qt.Key_R
                text: "Reboot"
                icon: "󰑐"
            }
        }
    }
}
