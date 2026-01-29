import QtQuick

Text {
    id: root
    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    font {
        hintingPreference: Font.PreferFullHinting
    }
    color: Appearence?.colors.accentColor ?? "black"
}
