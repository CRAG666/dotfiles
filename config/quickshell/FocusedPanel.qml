import Quickshell
import QtQuick

// A layer-shell window on FocusedOutput's screen. Quickshell must not move a
// mapped layer surface: setScreen desyncs its visibility, and the next close by
// the compositor (the output gone during suspend) leaves a QWindow that maps
// again as an ordinary, transparent window (quickshell#1291). So it unmaps,
// moves and maps again. Set `mapped`, not `visible`, and call follow() before
// showing it: the compositor's close unmaps it behind your back.
PanelWindow {
    id: root
    property bool mapped: true

    function follow() {
        const target = FocusedOutput.screen;
        const show = mapped && target !== null;
        if (screen === target && visible === show)
            return;
        visible = false;
        screen = target;
        visible = show;
    }

    Component.onCompleted: follow()
    onMappedChanged: follow()

    Connections {
        target: FocusedOutput
        function onScreenChanged() {
            root.follow();
        }
    }
}
