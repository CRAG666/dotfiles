pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Samples CPU / RAM / TEMP / NET / uptime every 2s straight from /proc and
// /sys via FileView — no subprocesses on the hot path. Rates (CPU %, net B/s)
// are deltas between consecutive samples, so no blocking sleep is needed
// either. The only process ever spawned is a one-shot hwmon lookup at startup.
Singleton {
    id: root
    property real cpu: 0
    property real ram: 0
    property string ramtxt: "—"
    property string ramshort: "—"
    property real temp: 0
    property string netdown: "—"
    property string netup: "—"
    property real netpct: 0
    property string uptime: "—"

    // previous sample, for deltas
    property real _prevIdle: 0
    property real _prevTotal: 0
    property real _prevRx: -1
    property real _prevTx: -1
    property double _prevMs: 0
    property string _iface: ""

    // resolved once at startup: the CPU die/package temperature sensor
    Process {
        running: true
        command: ["sh", "-c",
            "for d in /sys/class/hwmon/hwmon*; do case \"$(cat \"$d/name\" 2>/dev/null)\" in k10temp|zenpower|coretemp) echo \"$d/temp1_input\"; exit;; esac; done; [ -r /sys/class/thermal/thermal_zone0/temp ] && echo /sys/class/thermal/thermal_zone0/temp"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split("\n")[0];
                if (p) tempFile.path = p;
            }
        }
    }

    // /proc and /sys reads complete in microseconds, so blocking reloads keep
    // the sampling fully synchronous (no async-load races).
    FileView { id: statFile;   path: "/proc/stat";      blockAllReads: true; printErrors: false }
    FileView { id: memFile;    path: "/proc/meminfo";   blockAllReads: true; printErrors: false }
    FileView { id: routeFile;  path: "/proc/net/route"; blockAllReads: true; printErrors: false }
    FileView { id: uptimeFile; path: "/proc/uptime";    blockAllReads: true; printErrors: false }
    FileView { id: tempFile;   blockAllReads: true; printErrors: false }
    FileView { id: rxFile;     blockAllReads: true; printErrors: false }
    FileView { id: txFile;     blockAllReads: true; printErrors: false }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.sample()
    }
    // quick second sample so CPU / NET rates show right after startup instead
    // of waiting a full poll interval for the first delta
    Timer { interval: 300; running: true; onTriggered: root.sample() }

    function sample() {
        const nowMs = Date.now();
        const dtSec = _prevMs > 0 ? (nowMs - _prevMs) / 1000 : 0;
        _prevMs = nowMs;

        // ── CPU: aggregate line of /proc/stat ──
        statFile.reload();
        const st = statFile.text();
        const c = st.slice(3, st.indexOf("\n")).trim().split(/\s+/).map(Number);
        const idle = c[3] + c[4];                       // idle + iowait
        let total = 0;
        for (let i = 0; i < 8; i++) total += c[i];
        if (_prevTotal > 0 && total > _prevTotal) {
            const dt = total - _prevTotal;
            cpu = (100 * (dt - (idle - _prevIdle))) / dt;
        }
        _prevIdle = idle;
        _prevTotal = total;

        // ── RAM ──
        memFile.reload();
        const mem = memFile.text();
        const mt = +(mem.match(/MemTotal:\s+(\d+)/)?.[1] ?? 0);
        const ma = +(mem.match(/MemAvailable:\s+(\d+)/)?.[1] ?? 0);
        if (mt > 0) {
            const mu = mt - ma;
            ram = (100 * mu) / mt;
            const ug = (mu / 1048576).toFixed(1);
            const tg = Math.round(mt / 1048576);
            ramtxt = ug + " GiB / " + tg + " GB";
            ramshort = ug + "/" + tg + "G";
        }

        // ── TEMP (°C) ──
        if (tempFile.path) {
            tempFile.reload();
            const tv = parseInt(tempFile.text());
            if (!isNaN(tv)) temp = tv / 1000;
        }

        // ── NET: default-route interface, rate over the real elapsed time ──
        let iface = "";
        routeFile.reload();
        const lines = routeFile.text().split("\n");
        for (let i = 1; i < lines.length; i++) {
            const w = lines[i].trim().split(/\s+/);
            if (w.length > 1 && w[1] === "00000000") { iface = w[0]; break; }
        }
        if (iface !== _iface) {
            _iface = iface;
            _prevRx = -1;
            _prevTx = -1;
            if (iface) {
                rxFile.path = "/sys/class/net/" + iface + "/statistics/rx_bytes";
                txFile.path = "/sys/class/net/" + iface + "/statistics/tx_bytes";
            }
        }
        if (iface) {
            rxFile.reload();
            txFile.reload();
            const rx = parseInt(rxFile.text()) || 0;
            const tx = parseInt(txFile.text()) || 0;
            if (_prevRx >= 0 && dtSec > 0) {
                const rxr = Math.max(0, (rx - _prevRx) / dtSec);
                const txr = Math.max(0, (tx - _prevTx) / dtSec);
                netdown = hr(rxr);
                netup = hr(txr);
                netpct = activity(rxr + txr);
            }
            _prevRx = rx;
            _prevTx = tx;
        } else {
            netdown = "—";
            netup = "—";
            netpct = 0;
        }

        // ── uptime ──
        uptimeFile.reload();
        const us = parseFloat(uptimeFile.text());
        if (!isNaN(us)) uptime = fmtUptime(us);
    }

    function hr(b) {
        if (b >= 1048576) return (b / 1048576).toFixed(1) + "M";
        if (b >= 1024) return Math.round(b / 1024) + "K";
        return Math.round(b) + "B";
    }

    // combined throughput as a 0..100 activity meter. Network speed spans
    // orders of magnitude, so use a log scale: a few KB/s already shows,
    // full near 12.5 MB/s.
    function activity(bps) {
        const kb = bps / 1024;
        if (kb <= 0) return 0;
        return Math.min(100, (Math.log(kb + 1) / Math.log(12501)) * 100);
    }

    function fmtUptime(s) {
        const d = Math.floor(s / 86400);
        const h = Math.floor((s % 86400) / 3600);
        const m = Math.floor((s % 3600) / 60);
        const parts = [];
        if (d) parts.push(d + (d === 1 ? " day" : " days"));
        if (h) parts.push(h + (h === 1 ? " hour" : " hours"));
        if (m || !parts.length) parts.push(m + (m === 1 ? " minute" : " minutes"));
        return parts.join(", ");
    }
}
