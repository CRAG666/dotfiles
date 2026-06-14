import QtQuick
import Quickshell.Services.Mpris

// Centred media player: progress bar, title, artist, controls.
// Icon glyphs use \u escapes (Nerd Font / FontAwesome) so they survive editing.
Column {
    id: root
    property real u: 1
    property bool dark: Theme.playerDark
    spacing: 13 * u
    visible: root.playing          // only while something is actually playing

    // pick the playing MPRIS player, else the first available
    property MprisPlayer player: {
        const ps = Mpris.players.values;
        for (let i = 0; i < ps.length; i++)
            if (ps[i].playbackState === MprisPlaybackState.Playing)
                return ps[i];
        return ps.length ? ps[0] : null;
    }

    // refresh the position readout once per second, but only while something
    // is actually playing — otherwise the shell stays fully idle
    property int tick: 0
    Timer { interval: 1000; running: root.playing; repeat: true; onTriggered: root.tick++ }

    property real len: player ? player.length : 0
    property real pos: (root.tick, player ? player.position : 0)
    property bool playing: player !== null && player.playbackState === MprisPlaybackState.Playing

    function fmt(sec) {
        if (!sec || sec < 0) sec = 0;
        const m = Math.floor(sec / 60);
        const s = Math.floor(sec % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    // ── progress row ──────────────────────────────────────────
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 14 * u

        WText {
            anchors.verticalCenter: parent.verticalCenter
            dark: root.dark
            text: root.fmt(root.pos)
            font.family: Theme.mono
            font.pixelSize: 15 * u
            color: Theme.muted(root.dark)
        }
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 560 * u
            height: Math.max(5, 7 * u)
            radius: height / 2
            color: Theme.track(root.dark)

            Rectangle {
                height: parent.height
                radius: height / 2
                color: Theme.orange(root.dark)
                width: parent.width * (root.len > 0 ? Math.min(root.pos / root.len, 1) : 0)
            }
        }
        WText {
            anchors.verticalCenter: parent.verticalCenter
            dark: root.dark
            text: root.fmt(root.len)
            font.family: Theme.mono
            font.pixelSize: 15 * u
            color: Theme.muted(root.dark)
        }
    }

    // ── title / artist ────────────────────────────────────────
    WText {
        anchors.horizontalCenter: parent.horizontalCenter
        dark: root.dark
        text: player ? (player.trackTitle || "") : ""
        font.pixelSize: 28 * u
        font.weight: Font.Bold
        font.letterSpacing: 1 * u
    }
    WText {
        anchors.horizontalCenter: parent.horizontalCenter
        dark: root.dark
        text: player ? (player.trackArtist || "").toUpperCase() : ""
        color: Theme.muted(root.dark)
        font.pixelSize: 16 * u
        font.letterSpacing: 4 * u
    }

    // ── controls (decorative on the background layer) ─────────
    component Ctl: Item {
        property string glyph: ""
        property real sz: 34 * root.u
        implicitWidth: sz * 1.3
        implicitHeight: sz * 1.3
        WText {
            anchors.centerIn: parent
            dark: root.dark
            text: parent.glyph
            font.family: Theme.mono
            font.pixelSize: parent.sz
            color: Theme.orange(root.dark)
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 38 * u

        Ctl { glyph: "" }                              // rewind
        Ctl { glyph: root.playing ? "" : "" }    // pause / play
        Ctl { glyph: "" }                              // forward
    }
}
