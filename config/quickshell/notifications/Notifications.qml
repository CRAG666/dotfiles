import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import qs

// The notification server, in place of dunst: banners at the top right of the
// focused screen, newest on top, with a sound by urgency. A notification
// carrying a stack tag (x-dunst-stack-tag or x-canonical-private-synchronous)
// replaces the one shown with the same tag. Do Not Disturb lets only critical
// ones through. The last 50 are kept, with the Do Not Disturb state, in
// $XDG_STATE_HOME/notifications/history.json for Spotlight's Notifications
// view, which changes them through the IPC handler below. The banner surface
// stays mapped, hidden in the background layer, like Spotlight's.
Scope {
    id: root
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/notifications"
    readonly property string sounds: Quickshell.env("HOME") + "/.config/quickshell/notifications"
    readonly property var shown: server.trackedNotifications.values
    property bool dnd: false
    property var history: []

    function stackTag(notification) {
        return notification.hints["x-dunst-stack-tag"] ?? notification.hints["x-canonical-private-synchronous"] ?? "";
    }

    function plain(markup) {
        return markup.replace(/<[^>]*>/g, "").replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&quot;/g, "\"").replace(/&#39;/g, "'").replace(/&amp;/g, "&");
    }

    function receive(notification) {
        const critical = notification.urgency === NotificationUrgency.Critical;
        const tag = stackTag(notification);
        if (tag)
            for (const other of shown.filter(other => stackTag(other) === tag))
                other.dismiss();
        if (!notification.lastGeneration && !notification.transient)
            remember(notification);
        // left untracked, it is discarded without a banner
        if (dnd && !critical)
            return;
        notification.tracked = true;
        // remapped if its output went away (see Spotlight.open)
        win.visible = true;
        Wallpaper.refresh();
        if (!notification.lastGeneration)
            Quickshell.execDetached(["pw-play", `${sounds}/${critical ? "critical" : "normal"}.wav`]);
    }

    function remember(notification) {
        const icon = notification.appIcon && !notification.appIcon.includes("/") ? notification.appIcon : notification.desktopEntry;
        const tag = stackTag(notification);
        const entry = { id: `${Date.now()}-${notification.id}`, time: Date.now(), app: notification.appName, icon, tag, summary: notification.summary, body: plain(notification.body), critical: notification.urgency === NotificationUrgency.Critical };
        // like the banner, a tagged notification replaces the last one with its tag
        history = [entry, ...history.filter(other => !tag || other.tag !== tag)].slice(0, 50);
        save();
    }

    function save() {
        store.setText(JSON.stringify({ dnd, items: history }));
    }

    function dismissAll() {
        for (const notification of shown.slice())
            notification.dismiss();
    }

    Component.onCompleted: Quickshell.execDetached(["mkdir", "-p", stateDir])

    NotificationServer {
        id: server
        actionsSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true
        onNotification: notification => root.receive(notification)
    }

    FileView {
        id: store
        path: root.stateDir + "/history.json"
        blockLoading: true
        printErrors: false
        onLoaded: {
            const saved = JSON.parse(text());
            root.dnd = saved.dnd ?? false;
            root.history = saved.items ?? [];
        }
    }

    IpcHandler {
        target: "notifications"

        function remove(id: string): void {
            root.history = root.history.filter(entry => entry.id !== id);
            root.save();
        }

        function clear(): void {
            root.history = [];
            root.save();
        }

        function toggleDnd(): void {
            root.dnd = !root.dnd;
            root.save();
        }

        function dismissAll(): void {
            root.dismissAll();
        }
    }

    PanelWindow {
        id: win
        readonly property real u: Math.min(screen.width / 1920, screen.height / 1080) * 1.2
        readonly property bool active: root.shown.length > 0
        // room for the cards' shadow on the left
        readonly property int gutter: Math.round(30 * u)
        readonly property int overhang: Math.round(8 * u)
        screen: FocusedOutput.screen
        color: "transparent"
        WlrLayershell.layer: active ? WlrLayer.Overlay : WlrLayer.Background
        WlrLayershell.namespace: "qs-notifications"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore
        anchors {
            top: true
            right: true
            bottom: true
        }
        implicitWidth: Math.round(345 * u) + gutter + Math.round(16 * u)
        mask: active ? cards : noInput

        // the ✕ of a card overhangs its top-left corner
        Region {
            id: cards
            x: stack.x - win.overhang
            y: stack.y - win.overhang
            width: stack.width + win.overhang
            height: stack.height + win.overhang
        }
        Region {
            id: noInput
        }

        // the one blur behind every card (see Glass)
        WallBlur {
            id: wallBlur
            visible: false
            x: win.width - win.screen.width
            width: win.screen.width
            height: win.screen.height
        }

        // bottom to top: the newest, last in the model, sits on top
        ListView {
            id: stack
            x: win.gutter
            y: Math.round(16 * win.u)
            width: Math.round(345 * win.u)
            height: contentHeight
            interactive: false
            spacing: Math.round(10 * win.u)
            verticalLayoutDirection: ListView.BottomToTop
            model: server.trackedNotifications
            displaced: Transition {
                NumberAnimation {
                    properties: "y"
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            delegate: NotificationCard {
                required property var modelData
                notification: modelData
                u: win.u
                backdrop: wallBlur
                onCloseAll: root.dismissAll()
            }
        }
    }
}
