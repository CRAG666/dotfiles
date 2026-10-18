import QtQuick

// Spotlight's keys, pressed in the search field (help.js lists them); a key
// that is not Spotlight's goes on to the field
QtObject {
    id: root
    property var host
    property var preview   // a Preview
    property var grid   // a ResultGrid
    property var clipboardStore

    function handle(event) {
        const ctrl = (event.modifiers & Qt.ControlModifier) !== 0;
        const shift = (event.modifiers & Qt.ShiftModifier) !== 0;
        const quiet = host.search.selectedText === "";
        const listing = host.form || host.actionTarget;
        if (ctrl && (event.key === Qt.Key_Question || event.key === Qt.Key_Slash) && !listing) {
            host.mode = host.mode === "help" ? "" : "help";
        } else if (ctrl && event.key === Qt.Key_K) {
            if (host.actionTarget)
                host.closeActions();
            else
                host.openActions();
        } else if (ctrl && event.key >= Qt.Key_1 && event.key < Qt.Key_1 + host.chips.length && !listing) {
            const picked = host.chips[event.key - Qt.Key_1].mode;
            host.mode = host.mode === picked ? "" : picked;
        } else if (ctrl && event.key === Qt.Key_C && quiet) {
            host.copyItem(host.selection);
        } else if (ctrl && event.key === Qt.Key_X && quiet) {
            host.act(host.selection, "delete", false);
        } else if (ctrl && event.key === Qt.Key_P) {
            host.act(host.selection, "pin", false);
        } else if (ctrl && event.key === Qt.Key_E) {
            host.act(host.selection, "edit", false);
        } else if (ctrl && event.key === Qt.Key_R) {
            host.act(host.selection, "rename", false);
        } else if (ctrl && event.key === Qt.Key_T && host.mode === "clipboard") {
            clipboardStore.cycleFilter();
        } else if (ctrl && (event.key === Qt.Key_Up || event.key === Qt.Key_Down)) {
            preview.scroll(event.key === Qt.Key_Down ? 120 : -120);
        } else if (ctrl && event.key === Qt.Key_Home) {
            host.pick(0);
        } else if (ctrl && event.key === Qt.Key_End) {
            host.pick(host.results.length - 1);
        } else if (event.key === Qt.Key_Escape) {
            host.back();
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            host.activate(host.selection, { ctrl, shift });
        } else if (event.key === Qt.Key_Tab) {
            if (listing)
                host.step(1);
            else
                host.cycleMode(1);
        } else if (event.key === Qt.Key_Backtab) {
            if (listing)
                host.step(-1);
            else
                host.cycleMode(-1);
        } else if (host.gridView && (event.key === Qt.Key_Left || event.key === Qt.Key_Right)) {
            host.step(event.key === Qt.Key_Right ? 1 : -1);
        } else if (host.gridView && (event.key === Qt.Key_Up || event.key === Qt.Key_Down)) {
            grid.stepRow(event.key === Qt.Key_Down ? 1 : -1);
        } else if (event.key === Qt.Key_Right && host.completion) {
            host.search.text = host.results[0].title;
        } else if (event.key === Qt.Key_Down) {
            host.step(1);
        } else if (event.key === Qt.Key_Up && !host.search.text && !host.results.length && host.lastQuery && !listing) {
            host.search.text = host.lastQuery;
        } else if (event.key === Qt.Key_Up) {
            host.step(-1);
        } else if (event.key === Qt.Key_PageDown) {
            host.pick(host.current + 8);
        } else if (event.key === Qt.Key_PageUp) {
            host.pick(host.current - 8);
        } else {
            return;
        }
        event.accepted = true;
    }
}
