import QtQuick
import QtQuick.Window 2.15

Window {
    id: tooltipWindow
    property string text: ""
    property bool tooltipVisible: false
    property Item targetItem: null
    property int delay: 500
    property string textFont: Appearence.font.readFont

    property bool positionAbove: true

    flags: Qt.ToolTip | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    visible: false

    Timer {
        id: showTimer
        interval: tooltipWindow.delay
        repeat: false
        onTriggered: tooltipWindow._showNow()
    }

    onTooltipVisibleChanged: {
        if (tooltipVisible) {
            if (delay > 0) {
                showTimer.restart();
            } else {
                _showNow();
            }
        } else {
            _hideNow();
        }
    }

    function _showNow() {
        width = Math.max(12, tooltipText.implicitWidth + 6);
        height = Math.max(12, tooltipText.implicitHeight + 4);

        if (!targetItem)
            return;

        var pos;
        if (positionAbove) {
            pos = targetItem.mapToGlobal(0, 0);
            x = pos.x - width / 2 + targetItem.width / 2;
            y = pos.y - height - 12;
        } else {
            pos = targetItem.mapToGlobal(0, targetItem.height);
            x = pos.x - width / 2 + targetItem.width / 2;
            y = pos.y + 12;
        }
        visible = true;
    }

    function _hideNow() {
        visible = false;
        showTimer.stop();
    }

    Connections {
        target: tooltipWindow.targetItem
        function onXChanged() {
            if (tooltipWindow.visible)
                tooltipWindow._showNow();
        }
        function onYChanged() {
            if (tooltipWindow.visible)
                tooltipWindow._showNow();
        }
        function onWidthChanged() {
            if (tooltipWindow.visible)
                tooltipWindow._showNow();
        }
        function onHeightChanged() {
            if (tooltipWindow.visible)
                tooltipWindow._showNow();
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Appearence.colors.barBackgroundColor
        border.color: Appearence.colors.accentColor
        border.width: 1
        opacity: 0.97
        z: 1
    }

    StyledText {
        id: tooltipText
        text: tooltipWindow.text
        color: Appearence.colors.accentColor
        font.family: tooltipWindow.textFont
        font.pixelSize: 11
        anchors.centerIn: parent
        wrapMode: Text.Wrap
        padding: 8
        z: 2
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onExited: tooltipWindow.tooltipVisible = false
        cursorShape: Qt.ArrowCursor
    }

    onTextChanged: {
        width = Math.max(minimumWidth, tooltipText.implicitWidth + 6);
        height = Math.max(minimumHeight, tooltipText.implicitHeight + 4);
    }
}
