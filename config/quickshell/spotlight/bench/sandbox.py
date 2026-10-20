"""A hidden Spotlight built from any commit (or the working tree) in a scratch
directory, with its own state copy, a cache holding only a copy of the
wallpaper previews, and its own fifo, so it shares nothing writable with the
running one. Probes are QML text evaluated inside Spotlight's
window, where every store id is in scope; each writes its JSON answer to a file.
"""

import io
import json
import os
import shutil
import subprocess
import tarfile
import tempfile
import time
from collections.abc import Callable, Iterator
from contextlib import contextmanager
from dataclasses import dataclass
from pathlib import Path

QUICKSHELL = Path(__file__).resolve().parents[2]
REPO = Path(
    subprocess.run(
        ["git", "-C", str(QUICKSHELL), "rev-parse", "--show-toplevel"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout.strip()
)
STATE = (
    Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "spotlight"
)
# the wallpaper previews Spotlight makes once (about a minute on every core):
# an empty cache would make them again in each sandbox, while it is measured
PREVIEWS = (
    Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache"))
    / "spotlight/wallpapers"
)
ANCHOR = '        IpcHandler {\n            target: "spotlight"'
ENTRY = """        IpcHandler {
            target: "bench"
            function probe(path: string): void {
                benchProbe.path = path;
                Qt.createQmlObject(benchProbe.text(), win, "file://" + path);
            }
        }
        FileView {
            id: benchProbe
            // each probe is a new path, and only this blocks on a changed path
            blockAllReads: true
            // the sandbox's cache is empty: no index of documents is built in it
            Component.onCompleted: files.indexedAt = Date.now()
        }
"""
PROBE = """import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.spotlight
import "file://{search}" as Search

Item {{
    id: probe
    property var onTick: () => {{}}

    function tokens(text) {{
        return Search.tokens(text);
    }}

    function done(value) {{
        answer.setText(JSON.stringify(value));
    }}

    // calls `then` once `fingerprint` stops changing (at least 3 s, at most 60 s)
    function settle(fingerprint, then) {{
        let last = "", same = 0, waited = 0;
        onTick = () => {{
            const now = JSON.stringify(fingerprint());
            same = now === last ? same + 1 : 0;
            last = now;
            waited += tick.interval;
            if (same >= 6 && waited >= 3000 || waited >= 60000) {{
                tick.stop();
                then();
            }}
        }};
        tick.start();
    }}

    function loadAll() {{
        for (const load of [() => windows.load(), () => herdr.load(), () => agenda.load(), () => browser.loadTabs(), () => browser.loadHistory(), () => run.load(), () => snippets.load(), () => wallpapers.load(), () => library.load(), () => files.load(), () => ssh.load(), () => passwords.load(), () => web.load(), () => system.load(), () => scripts.load(), () => processes.refresh(), () => clipboard.load()])
            load();
        Apps.indexed.length;
    }}

    FileView {{
        id: answer
        path: "{answer}"
        blockWrites: true
        printErrors: false
    }}
    Timer {{
        id: tick
        interval: 250
        repeat: true
        onTriggered: probe.onTick()
    }}

    Component.onCompleted: {{
        try {{
{body}
        }} catch (error) {{
            done({{ error: String(error) + "\n" + error.stack }});
        }}
    }}
}}
"""


def tree(rev: str | None, into: Path) -> Path:
    """config/quickshell at `rev`, or the working tree for None or "worktree",
    copied to `into`."""
    if rev in (None, "worktree"):
        shutil.copytree(
            QUICKSHELL, into, ignore=shutil.ignore_patterns("__pycache__", "bench")
        )
        return into
    archive = subprocess.run(
        ["git", "-C", str(REPO), "archive", rev, "config/quickshell"],
        capture_output=True,
        check=True,
    ).stdout
    with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
        members = [m for m in tar.getmembers() if m.name.count("/") >= 2]
        for member in members:
            member.name = member.name.split("/", 2)[2]
        tar.extractall(into, members=members, filter="data")
    return into


@dataclass
class Instance:
    config: Path
    scratch: Path
    log: Path
    process: subprocess.Popen
    probes: int = 0

    def probe(self, body: str, timeout: float = 120) -> object:
        """Runs `body` (JavaScript, which ends by calling done(value)) and returns value."""
        self.probes += 1
        source = self.scratch / f"probe{self.probes}.qml"
        answer = self.scratch / f"answer{self.probes}.json"
        source.write_text(
            PROBE.format(
                search=self.config / "spotlight/js/search.js",
                answer=answer,
                body=body,
            )
        )
        ipc(self.config, "probe", str(source))
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            if answer.exists():
                try:
                    value = json.loads(answer.read_text())
                except json.JSONDecodeError:
                    pass  # still being written
                else:
                    if isinstance(value, dict) and "error" in value:
                        raise RuntimeError(
                            f"probe {self.probes} failed: {value['error']}"
                        )
                    return value
            time.sleep(0.1)
        tail = "\n".join(self.lines()[-15:])
        raise TimeoutError(
            f"probe {self.probes} gave no answer; quickshell's log ends:\n{tail}"
        )

    def lines(self) -> list[str]:
        return self.log.read_text(errors="replace").splitlines()

    def rss(self) -> int:
        """Resident memory in MB."""
        status = Path(f"/proc/{self.process.pid}/status").read_text()
        return (
            int(
                next(
                    line for line in status.splitlines() if line.startswith("VmRSS:")
                ).split()[1]
            )
            // 1024
        )


def standalone(shell: str, files: dict[str, str], timeout: float = 600) -> object:
    """Runs `shell`, a ShellRoot that writes its JSON answer to the path ANSWER,
    in a scratch directory (SCRATCH in `shell`) holding `files`; returns it."""
    with tempfile.TemporaryDirectory(prefix="spotlight-bench-") as scratch:
        root = Path(scratch)
        for name, content in files.items():
            (root / name).write_text(content)
        answer = root / "answer.json"
        (root / "shell.qml").write_text(
            shell.replace("ANSWER", str(answer)).replace("SCRATCH", scratch)
        )
        run = subprocess.run(
            ["quickshell", "-n", "-p", str(root / "shell.qml")],
            check=False,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        if not answer.exists():
            raise RuntimeError(f"no answer; quickshell said:\n{run.stdout[-3000:]}")
        value = json.loads(answer.read_text())
        if isinstance(value, dict) and "error" in value:
            raise RuntimeError(value["error"])
        return value


def show(rev: str | None, path: str) -> str:
    """A file of config/quickshell at `rev`, or in the working tree for None or "worktree"."""
    if rev in (None, "worktree"):
        return (QUICKSHELL / path).read_text()
    return subprocess.run(
        ["git", "-C", str(REPO), "show", f"{rev}:config/quickshell/{path}"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout


def ipc(config: Path, function: str, *args: str) -> None:
    subprocess.run(
        [
            "qs",
            "ipc",
            "-p",
            str(config / "spotlight.qml"),
            "call",
            "bench",
            function,
            *args,
        ],
        capture_output=True,
        text=True,
        check=True,
    )


@contextmanager
def sandbox(
    rev: str | None,
    logging_rules: str = "",
    debug_port: int = 0,
    prepare: Callable[[Path], None] | None = None,
) -> Iterator[Instance]:
    """`prepare` edits the copied config before it starts, for experiments."""
    with tempfile.TemporaryDirectory(prefix="spotlight-bench-") as scratch:
        root = Path(scratch)
        config = tree(rev, root / "quickshell")
        # before the fifo is renamed: a prepare that rewrites Spotlight.qml would
        # otherwise point the sandbox at the running Spotlight's fifo
        if prepare:
            prepare(config)
        spotlight = config / "spotlight/Spotlight.qml"
        source = spotlight.read_text()
        if ANCHOR not in source or '"/spotlight.fifo"' not in source:
            raise RuntimeError(
                f"{rev or 'working tree'}: Spotlight.qml lacks the bench anchors"
            )
        spotlight.write_text(
            source.replace(ANCHOR, ENTRY + ANCHOR, 1).replace(
                '"/spotlight.fifo"', '"/spotlight-bench.fifo"'
            )
        )
        if STATE.is_dir():
            shutil.copytree(STATE, root / "state/spotlight")
        if PREVIEWS.is_dir():
            shutil.copytree(PREVIEWS, root / "cache/spotlight/wallpapers")
        env = os.environ | {
            "XDG_STATE_HOME": str(root / "state"),
            "XDG_CACHE_HOME": str(root / "cache"),
            "QT_LOGGING_RULES": logging_rules,
        }
        log = root / "quickshell.log"
        with log.open("w") as output:
            process = subprocess.Popen(
                [
                    "quickshell",
                    *(["--debug", str(debug_port)] if debug_port else []),
                    "-n",
                    "-p",
                    str(config / "spotlight.qml"),
                ],
                env=env,
                stdout=output,
                stderr=subprocess.STDOUT,
            )
            try:
                instance = Instance(config, root, log, process)
                wait_for_ipc(config, process, log)
                yield instance
            finally:
                process.terminate()
                process.wait(timeout=10)


def wait_for_ipc(config: Path, process: subprocess.Popen, log: Path) -> None:
    deadline = time.monotonic() + 20
    while time.monotonic() < deadline:
        if process.poll() is not None:
            raise RuntimeError(f"quickshell exited:\n{log.read_text()[-2000:]}")
        shown = subprocess.run(
            ["qs", "ipc", "-p", str(config / "spotlight.qml"), "show"],
            check=False,
            capture_output=True,
            text=True,
        )
        if "target bench" in shown.stdout:
            return
        time.sleep(0.2)
    raise TimeoutError(f"the sandbox never answered IPC; see {log}")
