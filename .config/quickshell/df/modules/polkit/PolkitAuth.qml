import QtQuick
import Quickshell
import Quickshell.Services.Polkit

Scope {
    id: root

    signal authenticationSucceeded()
    signal authenticationFailed()
    signal authenticationCancelled()
    signal requestStarted()

    property bool closing: false
    property bool submitted: false
    property bool responseRequired: false
    property bool responseVisible: false
    property bool failed: false
    property bool errorFlash: false
    property int shakeOffset: 0
    property string currentMessage: ""
    property string currentPrompt: ""
    property string currentSupplementary: ""

    readonly property bool dialogVisible: polkitAgent.isActive || closing

    function resetSnapshot() {
        currentMessage = "";
        currentPrompt = "";
        currentSupplementary = "";
        responseRequired = false;
        responseVisible = false;
        failed = false;
        errorFlash = false;
        submitted = false;
    }

    function syncFromFlow() {
        var flow = polkitAgent.flow;
        if (!flow)
            return;
        currentMessage = String(flow.message || "Authentication is needed...");
        currentPrompt = String(flow.inputPrompt || "");
        currentSupplementary = String(flow.supplementaryMessage || "");
        responseRequired = !!flow.isResponseRequired;
        responseVisible = !!flow.responseVisible;
        failed = !!flow.failed;

        if (responseRequired)
            submitted = false;
    }

    function beginFlow() {
        closeTimer.stop();
        closing = false;
        submitted = false;
        syncFromFlow();
        root.requestStarted();
        Qt.callLater(triggerRefocus);
    }

    function triggerRefocus() {
        root.requestStarted();
    }

    function submitResponse(password) {
        var flow = polkitAgent.flow;
        if (!flow || !flow.isResponseRequired)
            return;
        submitted = true;
        errorFlash = false;
        flow.submit(password);
    }

    function cancelRequest() {
        var flow = polkitAgent.flow;
        submitted = false;
        closing = true;
        closeTimer.restart();
        if (flow)
            flow.cancelAuthenticationRequest();
    }

    function triggerFailureFeedback() {
        submitted = false;
        errorFlash = true;
        errorTimer.restart();
        shakeAnimation.restart();
    }

    Timer {
        id: closeTimer
        interval: 300
        repeat: false
        onTriggered: {
            closing = false;
            resetSnapshot();
        }
    }

    Timer {
        id: errorTimer
        interval: 1200
        repeat: false
        onTriggered: root.errorFlash = false
    }

    SequentialAnimation {
        id: shakeAnimation
        NumberAnimation {
            target: root
            property: "shakeOffset"
            to: -8
            duration: 35
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: root
            property: "shakeOffset"
            to: 8
            duration: 50
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: root
            property: "shakeOffset"
            to: 0
            duration: 55
            easing.type: Easing.OutQuad
        }
    }

    PolkitAgent {
        id: polkitAgent
        path: "/org/qs/PolkitAgent"

        onAuthenticationRequestStarted: root.beginFlow()
        onIsActiveChanged: {
            if (isActive)
                root.syncFromFlow();
            else if (!root.closing)
                root.resetSnapshot();
        }
        onIsRegisteredChanged: {
            if (isRegistered)
                console.info("polkit agent registered");
            else
                console.warn("polkit agent not registered; another agent may be running");
        }
    }

    Connections {
        target: polkitAgent.flow

        function onIsResponseRequiredChanged() {
            root.syncFromFlow();
            if (!polkitAgent.flow || !polkitAgent.flow.isResponseRequired)
                root.requestStarted();
            Qt.callLater(root.triggerRefocus);
        }

        function onInputPromptChanged() { root.syncFromFlow(); }
        function onResponseVisibleChanged() { root.syncFromFlow(); }
        function onSupplementaryMessageChanged() { root.syncFromFlow(); }
        function onFailedChanged() { root.syncFromFlow(); }

        function onAuthenticationFailed() {
            root.syncFromFlow();
            root.triggerFailureFeedback();
            root.authenticationFailed();
        }

        function onAuthenticationSucceeded() {
            root.closing = true;
            closeTimer.restart();
            root.authenticationSucceeded();
        }

        function onAuthenticationRequestCancelled() {
            root.closing = true;
            closeTimer.restart();
            root.authenticationCancelled();
        }
    }
}
