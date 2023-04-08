# This is a sample commands.py.  You can add your own commands here.
#
# Please refer to commands_full.py for all the default commands and a complete
# documentation.  Do NOT add them all here, or you may end up with defunct
# commands when upgrading ranger.

# A simple command for demonstration purposes follows.
# -----------------------------------------------------------------------------

from __future__ import absolute_import, division, print_function

# You can import any python module as needed.
import os
from collections import deque
# You can import any python module as needed.
# import os
from threading import Thread

from plugins.ranger_udisk_menu.mounter import mount
# You always need to import ranger.api.commands here to get the Command class:
# You always need to import ranger.api.commands here to get the Command class:
from ranger.api.commands import Command


class mmv(Command):
    def execute(self):
        th = Thread(target=self.mmvdaemon, daemon=True)
        th.start()
        th.join()

    def mmvdaemon(self):
        arguments = f'kitty -e mmv {" ".join(self.args[1:])}'
        self.fm.execute_command(arguments)


class empty(Command):
    """:empty

    Empties the trash directory ~/.Trash
    """

    def execute(self):
        self.fm.run("gio trash --empty")


class fd_search(Command):
    """
    :fd_search [-d<depth>] <query>
    Executes "fd -d<depth> <query>" in the current directory and focuses the
    first match. <depth> defaults to 1, i.e. only the contents of the current
    directory.

    See https://github.com/sharkdp/fd
    """

    SEARCH_RESULTS = deque()

    def execute(self):
        import re
        import subprocess

        from ranger.ext.get_executables import get_executables

        self.SEARCH_RESULTS.clear()

        if "fdfind" in get_executables():
            fd = "fdfind"
        elif "fd" in get_executables():
            fd = "fd"
        else:
            self.fm.notify("Couldn't find fd in the PATH.", bad=True)
            return

        if self.arg(1):
            if self.arg(1)[:2] == "-d":
                depth = self.arg(1)
                target = self.rest(2)
            else:
                depth = "-d1"
                target = self.rest(1)
        else:
            self.fm.notify(":fd_search needs a query.", bad=True)
            return

        hidden = "--hidden" if self.fm.settings.show_hidden else ""
        exclude = "--no-ignore-vcs --exclude '.git' --exclude '*.py[co]' --exclude '__pycache__'"
        command = "{} --follow {} {} {} --print0 {}".format(
            fd, depth, hidden, exclude, target
        )
        fd = self.fm.execute_command(
            command, universal_newlines=True, stdout=subprocess.PIPE
        )
        stdout, _ = fd.communicate()

        if fd.returncode == 0:
            results = filter(None, stdout.split("\0"))
            if not self.fm.settings.show_hidden and self.fm.settings.hidden_filter:
                hidden_filter = re.compile(self.fm.settings.hidden_filter)
                results = filter(
                    lambda res: not hidden_filter.search(os.path.basename(res)), results
                )
            results = map(
                lambda res: os.path.abspath(os.path.join(self.fm.thisdir.path, res)),
                results,
            )
            self.SEARCH_RESULTS.extend(sorted(results, key=str.lower))
            if len(self.SEARCH_RESULTS) > 0:
                self.fm.notify(
                    "Found {} result{}.".format(
                        len(self.SEARCH_RESULTS),
                        ("s" if len(self.SEARCH_RESULTS) > 1 else ""),
                    )
                )
                self.fm.select_file(self.SEARCH_RESULTS[0])
            else:
                self.fm.notify("No results found.")


class fd_next(Command):
    """
    :fd_next
    Selects the next match from the last :fd_search.
    """

    def execute(self):
        if len(fd_search.SEARCH_RESULTS) > 1:
            fd_search.SEARCH_RESULTS.rotate(-1)  # rotate left
            self.fm.select_file(fd_search.SEARCH_RESULTS[0])
        elif len(fd_search.SEARCH_RESULTS) == 1:
            self.fm.select_file(fd_search.SEARCH_RESULTS[0])


class fd_prev(Command):
    """
    :fd_prev
    Selects the next match from the last :fd_search.
    """

    def execute(self):
        if len(fd_search.SEARCH_RESULTS) > 1:
            fd_search.SEARCH_RESULTS.rotate(1)  # rotate right
            self.fm.select_file(fd_search.SEARCH_RESULTS[0])
        elif len(fd_search.SEARCH_RESULTS) == 1:
            self.fm.select_file(fd_search.SEARCH_RESULTS[0])
