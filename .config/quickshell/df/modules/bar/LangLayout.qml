import QtQuick
import qs.modules.common
import qs.services

BarItem {
    content: StyledText {
        id: innerItem
        anchors.centerIn: parent
        font.family: Appearence.font.readFont
        font.pixelSize: 13
        color: Appearence.colors.accentColor
        text: XcbLayout.currentLayoutCode
        elide: Text.ElideRight
    }
}
