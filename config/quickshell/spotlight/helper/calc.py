"""The calculator beyond arithmetic: time zones, date math and qalc."""

import re
import subprocess
from datetime import date, datetime
from functools import cache
from pathlib import Path
from zoneinfo import TZPATH, ZoneInfo, available_timezones

ZONE_ALIASES = {
    "cdmx": "America/Mexico_City",
    "nyc": "America/New_York",
    "ny": "America/New_York",
    "la": "America/Los_Angeles",
    "sf": "America/Los_Angeles",
    "utc": "UTC",
    "gmt": "GMT",
}


CLOCK = re.compile(
    r"(?P<time>now|time|\d{1,2}(?::\d{2})?\s*(?:am|pm)?)\s+(?:(?P<source>.+?)\s+)?(?:in|to)\s+(?P<target>.+)",
    re.IGNORECASE,
)


COUNTDOWN = re.compile(
    r"(?P<unit>days|weeks)\s+(?P<direction>until|till|to|since)\s+(?P<date>.+)",
    re.IGNORECASE,
)


SPAN = re.compile(
    r"in\s+(?P<ahead>\d+\s+(?:day|week|month|year)s?)|(?P<span>\d+\s+(?:day|week|month|year)s?)\s+(?P<direction>from now|ago)",
    re.IGNORECASE,
)


CONVERSION = re.compile(r"(.*\d.*?)\s+(?:to|in|as)\s+([^\d\s]\S*)", re.IGNORECASE)


# qalc is case-sensitive: "100 f to c" means temperatures, "1 gb" gigabytes
UNIT_CASE = {"f": "°F", "c": "°C", "kb": "kB", "mb": "MB", "gb": "GB", "tb": "TB"}


BASES = {
    "hex",
    "hexadecimal",
    "bin",
    "binary",
    "oct",
    "octal",
    "dec",
    "decimal",
    "bases",
    "roman",
}


# every zone (Z) and link (L) name, from tzdata.zi in one read:
# available_timezones() opens each of the ~600 zone files (4 ms against 75)
def timezones() -> list[str]:
    for root in TZPATH:
        listing = Path(root) / "tzdata.zi"
        if listing.exists():
            return [
                fields[1] if fields[0] == "Z" else fields[2]
                for fields in map(str.split, listing.read_text().splitlines())
                if fields and fields[0] in ("Z", "L")
            ]
    return list(available_timezones())


# a zone's full name and its city, lowercase, to the first such zone in
# alphabetical order, built once
@cache
def zone_names() -> dict[str, str]:
    names: dict[str, str] = {}
    for tz in sorted(timezones()):
        names.setdefault(tz.lower(), tz)
        names.setdefault(tz.lower().rsplit("/", 1)[-1], tz)
    return names


def zone(name: str) -> ZoneInfo | None:
    key = name.lower().replace(" ", "_")
    if key in ZONE_ALIASES:
        return ZoneInfo(ZONE_ALIASES[key])
    found = zone_names().get(key)
    return ZoneInfo(found) if found else None


def zone_label(moment: datetime) -> str:
    key = getattr(moment.tzinfo, "key", None)
    return key.rsplit("/", 1)[-1].replace("_", " ") if key else "local"


# "5pm cdmx in tokyo", "17:30 in london", "time in tokyo"; the source defaults
# to the local zone
def zone_time(text: str) -> dict | None:
    match = CLOCK.fullmatch(text)
    if not match:
        return None
    target = zone(match["target"])
    source = (
        zone(match["source"]) if match["source"] else datetime.now().astimezone().tzinfo
    )
    if target is None or source is None:
        return None
    moment = datetime.now(source)
    spoken = match["time"].lower()
    if spoken not in ("now", "time"):
        clock = re.fullmatch(r"(\d{1,2})(?::(\d{2}))?\s*(am|pm)?", spoken)
        hour, minute = int(clock[1]), int(clock[2] or 0)
        if clock[3]:
            hour = hour % 12 + (12 if clock[3] == "pm" else 0)
        if hour > 23 or minute > 59:
            return None
        moment = moment.replace(hour=hour, minute=minute, second=0, microsecond=0)
    there = moment.astimezone(target)
    return {
        "value": f"{there:%H:%M}",
        "detail": f"{moment:%H:%M} {zone_label(moment)} is {there:%A %-d %B} in {zone_label(there)}",
    }


def gnu_date(expression: str) -> date | None:
    run = subprocess.run(
        ["date", "-d", expression, "+%F"], capture_output=True, text=True, check=False
    )
    return date.fromisoformat(run.stdout.strip()) if run.returncode == 0 else None


# "days until dec 25", "weeks since 2026-01-01", "in 3 weeks", "10 days ago"
def date_math(text: str) -> dict | None:
    if match := COUNTDOWN.fullmatch(text):
        when = gnu_date(match["date"])
        if when is None:
            return None
        today = datetime.now().astimezone().date()
        since = match["direction"].lower() == "since"
        if not re.search(r"\d{4}", match["date"]):
            if since and when > today:
                when = gnu_date(match["date"] + " -1 year")
            elif not since and when < today:
                when = gnu_date(match["date"] + " +1 year")
        days = abs((when - today).days)
        unit = match["unit"].lower()
        amount = days if unit == "days" else round(days / 7, 1)
        return {
            "value": f"{amount:g} {unit.rstrip('s') if amount == 1 else unit}",
            "detail": f"{'Since' if since else 'Until'} {when:%A, %-d %B %Y}",
        }
    if match := SPAN.fullmatch(text):
        ago = (match["direction"] or "").lower() == "ago"
        when = gnu_date((match["ahead"] or match["span"]) + (" ago" if ago else ""))
        return {"value": f"{when:%A, %-d %B %Y}", "detail": text} if when else None
    return None


# units, currencies, percentages and number bases; None when qalc did not
# understand the text, which it then reports as an error or a warning
def qalculate(text: str) -> dict | None:
    if not re.search(r"\d", text):
        return None
    expression = re.sub(r"(\d)\s*%\s*of\s+", r"\1% * ", text, flags=re.IGNORECASE)
    if conversion := CONVERSION.fullmatch(expression):
        amount = re.sub(
            r"0x[0-9a-f]+|[a-z]+",
            lambda word: UNIT_CASE.get(word[0].lower(), word[0]),
            conversion[1],
            flags=re.IGNORECASE,
        )
        target = UNIT_CASE.get(conversion[2].lower(), conversion[2])
        # a leading "-" keeps "5 km to mi" from answering in miles, yards and inches
        expression = (
            f"{amount} to {target if target.lower() in BASES else '-' + target}"
        )
    run = subprocess.run(
        [
            "qalc",
            "-s",
            "save config 0",
            "-s",
            "upxrates 1",
            "-s",
            "percent 1",
            expression,
        ],
        capture_output=True,
        text=True,
        stdin=subprocess.DEVNULL,
        timeout=5,
        check=False,
    )
    lines = run.stdout.strip().splitlines()
    if (
        run.returncode
        or not lines
        or re.search(r"^(error|warning):", run.stdout, re.MULTILINE)
    ):
        return None
    parts = re.split(r" ([=≈]) ", lines[-1])
    if len(parts) < 3 or parts[-1].lower() == text.lower():
        return None
    return {"value": parts[-1], "detail": f"{parts[0]} {parts[-2]}"}


def calc(query: str) -> dict | None:
    text = " ".join(query.removeprefix("=").split())
    return zone_time(text) or date_math(text) or qalculate(text)
