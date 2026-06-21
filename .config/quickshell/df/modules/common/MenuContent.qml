import QtQuick
import qs.modules.common

Rectangle {
    id: root

    property bool open: false

    default property alias data: contentColumn.data

    visible: open || fadeTimer.running
    opacity: open ? 1 : 0
    scale: open ? 1 : 0.95

    Behavior on opacity {
        animation: Appearence.animation.standardEnter.numberAnimation.createObject(this)
    }
    Behavior on scale {
        animation: Appearence.animation.standardEnter.numberAnimation.createObject(this)
    }

    onOpenChanged: {
        if (!open)
            fadeTimer.start();
    }

    Timer {
        id: fadeTimer
        interval: 250
    }

    implicitHeight: contentColumn.implicitHeight + 16
    clip: true
    radius: 12
    color: Appearence.colors.surfaceColor
    border.width: 1
    border.color: Appearence.colors.borderColor

    Column {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4
    }
}
