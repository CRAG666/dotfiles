"""cliphist's history, as the clipboard view shows it."""

import subprocess

PEEK_BYTES = 4000


# the first bytes of an entry, for its preview; cliphist is stopped there, as
# an entry can be a whole file
def clip_peek(entry: str) -> str:
    with subprocess.Popen(
        ["cliphist", "decode", entry], stdout=subprocess.PIPE
    ) as decode:
        head = decode.stdout.read(PEEK_BYTES)
        decode.kill()
    return head.decode(errors="replace")
