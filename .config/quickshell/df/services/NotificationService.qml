pragma Singleton
pragma ComponentBehavior: Bound

import qs
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root
    component Notif: QtObject {
        id: wrapper
        required property int notificationId
        property Notification notification
        property list<NotificationAction> actions: notification?.actions ?? []
        property bool popup: false
        property string appIcon: notification?.appIcon ?? ""
        property string appName: notification?.appName ?? ""
        property string body: notification?.body ?? ""
        property string image: notification?.image ?? ""
        property string summary: notification?.summary ?? ""
        property double time
        property string urgency: notification?.urgency.toString() ?? "normal"
        property Timer timer

        onNotificationChanged: {
            if (notification === null) {
                root.discardNotification(notificationId);
            }
        }
    }

    function notifToJSON(notif) {
        return {
            "notificationId": notif.notificationId,
            "actions": notif.actions,
            "appIcon": notif.appIcon,
            "appName": notif.appName,
            "body": notif.body,
            "image": notif.image,
            "summary": notif.summary,
            "time": notif.time,
            "urgency": notif.urgency
        };
    }
    function notifToString(notif) {
        return JSON.stringify(notifToJSON(notif), null, 2);
    }

    component NotifTimer: Timer {
        required property int notificationId
        interval: 5000
        running: true
        onTriggered: () => {
            root.timeoutNotification(notificationId);
            destroy();
        }
    }

    property bool silent: false
    property var filePath: Directories.notificationsPath
    property list<Notif> list: []
    property var popupList: list.filter(notif => notif.popup)
    property bool popupInhibited: GlobalStates.sidebarOpen
    Component {
        id: notifComponent
        Notif {}
    }
    Component {
        id: notifTimerComponent
        NotifTimer {}
    }

    function stringifyList(list) {
        return JSON.stringify(list.map(notif => notifToJSON(notif)), null, 2);
    }

    property int idOffset
    signal initDone
    signal notify(notification: var)
    signal discard(id: int)
    signal discardAll
    signal timeout(id: var)

    NotificationServer {
        id: notifServer
        actionIconsSupported: true
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true
        keepOnReload: false
        persistenceSupported: true

        onNotification: notification => {
            notification.tracked = true;
            const newNotifObject = notifComponent.createObject(root, {
                "notificationId": notification.id + root.idOffset,
                "notification": notification,
                "time": Date.now()
            });
            root.list = [...root.list, newNotifObject];

            if (!root.popupInhibited) {
                newNotifObject.popup = true;
                if (notification.expireTimeout != 0) {
                    newNotifObject.timer = notifTimerComponent.createObject(root, {
                        "notificationId": newNotifObject.notificationId,
                        "interval": notification.expireTimeout < 0 ? 5000 : notification.expireTimeout
                    });
                }
            }

            root.notify(newNotifObject);
            notifFileView.setText(root.stringifyList(root.list));
        }
    }

    function discardNotification(id) {
        console.info("[Notifications] Discarding notification with ID: " + id);
        const index = root.list.findIndex(notif => notif.notificationId === id);
        const notifServerIndex = notifServer.trackedNotifications.values.findIndex(notif => notif.id + root.idOffset === id);
        if (index !== -1) {
            root.list.splice(index, 1);
            notifFileView.setText(stringifyList(root.list));
            triggerListChange();
        }
        if (notifServerIndex !== -1) {
            notifServer.trackedNotifications.values[notifServerIndex].dismiss();
        }
        root.discard(id);
    }

    function discardAllNotifications() {
        root.list = [];
        triggerListChange();
        notifFileView.setText(stringifyList(root.list));
        notifServer.trackedNotifications.values.forEach(notif => {
            notif.dismiss();
        });
        root.discardAll();
    }

    function timeoutNotification(id) {
        const index = root.list.findIndex(notif => notif.notificationId === id);
        if (root.list[index] != null)
            root.list[index].popup = false;
        root.timeout(id);
    }

    function timeoutAll() {
        root.popupList.forEach(notif => {
            root.timeout(notif.notificationId);
            notif.popup = false;
        });
    }

    function attemptInvokeAction(id, notifIdentifier) {
        const notifServerIndex = notifServer.trackedNotifications.values.findIndex(notif => notif.id + root.idOffset === id);
        if (notifServerIndex !== -1) {
            const notifServerNotif = notifServer.trackedNotifications.values[notifServerIndex];
            const action = notifServerNotif.actions.find(action => action.identifier === notifIdentifier);
            action.invoke();
        }
        root.discardNotification(id);
    }

    function triggerListChange() {
        root.list = root.list.slice(0);
    }

    function refresh() {
        notifFileView.reload();
    }

    Component.onCompleted: {
        refresh();
    }

    FileView {
        id: notifFileView
        path: Qt.resolvedUrl(root.filePath)
        onLoaded: {
            const fileContents = notifFileView.text();
            root.list = JSON.parse(fileContents).map(notif => {
                return notifComponent.createObject(root, {
                    "notificationId": notif.notificationId,
                    "actions": notif.actions,
                    "appIcon": notif.appIcon,
                    "appName": notif.appName,
                    "body": notif.body,
                    "image": notif.image,
                    "summary": notif.summary,
                    "time": notif.time,
                    "urgency": notif.urgency
                });
            });
            // Find largest notificationId
            let maxId = 0;
            root.list.forEach(notif => {
                maxId = Math.max(maxId, notif.notificationId);
            });

            console.info("[Notifications] File loaded");
            root.idOffset = maxId;
            root.initDone();
        }
        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                console.info("[Notifications] File not found, creating new file.");
                root.list = [];
                notifFileView.setText(root.stringifyList(root.list));
            } else {
                console.error("[Notifications] Error loading file: " + error);
            }
        }
    }
}
