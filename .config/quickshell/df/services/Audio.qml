pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    property bool ready: Pipewire.defaultAudioSink?.ready ?? false
    property PwNode sink: Pipewire.defaultAudioSink
    property PwNode source: Pipewire.defaultAudioSource

    PwObjectTracker {
        objects: [sink, source]
    }
}
