"""Spotlight's bench: whether a change keeps the results, how fast it answers
and how well it ranks, against a commit (HEAD by default), each side in a
hidden sandbox that shares nothing writable with the running Spotlight.

    python3 config/quickshell/spotlight/bench matcher|stores|keystrokes|precision [--against REV]
"""

import argparse
import sys

from equivalence import matcher, narrowing, stores
from keystrokes import keystrokes
from precision import precision
from profiling import profile


def main() -> None:
    parser = argparse.ArgumentParser(prog="bench")
    parser.add_argument(
        "--against",
        default="HEAD",
        help="the commit to compare the working tree with; worktree compares two starts of it",
    )
    commands = parser.add_subparsers(required=True)
    command = commands.add_parser(
        "matcher", help="search.js scores on real texts and generated queries"
    )
    command.add_argument("--texts", type=int, default=1500)
    command.add_argument("--queries", type=int, default=600)
    command.set_defaults(
        run=lambda args: matcher(args.against, args.texts, args.queries)
    )
    command = commands.add_parser(
        "narrowing",
        help="the query cache against filtering afresh, keystroke by keystroke",
    )
    command.add_argument("--texts", type=int, default=6000)
    command.add_argument("--queries", type=int, default=200)
    command.set_defaults(run=lambda args: narrowing(args.texts, args.queries))
    command = commands.add_parser(
        "stores", help="every store's answers to the same queries"
    )
    command.set_defaults(run=lambda args: stores(args.against))
    command = commands.add_parser(
        "keystrokes", help="time and garbage collection per keystroke"
    )
    command.add_argument("--queries", type=int, default=40)
    command.add_argument(
        "--warm", type=int, default=0, help="queries run first, as in a long session"
    )
    command.add_argument("--mode", default="", help="a view to type in, e.g. history")
    command.set_defaults(
        run=lambda args: keystrokes(args.against, args.queries, args.warm, args.mode)
    )
    command = commands.add_parser(
        "profile", help="QML self time per function while typing"
    )
    command.add_argument("--queries", type=int, default=40)
    command.add_argument("--mode", default="")
    command.add_argument("--top", type=int, default=30)
    command.set_defaults(
        run=lambda args: profile(
            None if args.against == "worktree" else args.against,
            args.queries,
            args.mode,
            args.top,
        )
    )
    command = commands.add_parser(
        "precision", help="ranking quality: Top-1, Top-3, MRR@10, noise"
    )
    command.add_argument(
        "--misses",
        type=int,
        default=0,
        help="queries per kind shown where the item was not first",
    )
    command.add_argument(
        "--alone", action="store_true", help="measure the working tree only"
    )
    command.set_defaults(
        run=lambda args: precision(args.against, args.misses, args.alone)
    )
    args = parser.parse_args()
    if args.run(args) is False:
        sys.exit(1)


if __name__ == "__main__":
    main()
