"""A DOI to its BibTeX (doi.org) and open access PDF (OpenAlex)."""

import html
import json
import re
import sys
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from urllib.error import URLError
from urllib.parse import quote


def fetch(url: str, accept: str = "*/*") -> str:
    request = urllib.request.Request(
        url, headers={"Accept": accept, "User-Agent": "spotlight (quickshell)"}
    )
    with urllib.request.urlopen(request, timeout=15) as response:
        return response.read().decode()


# Crossref sends an entry on one line: split it at the commas outside braces
def bibtex_entry(text: str) -> tuple[str, str, list[tuple[str, str]]]:
    kind, body = html.unescape(text).strip().split("{", 1)
    body = body.rstrip().removesuffix("}")
    parts, depth, start = [], 0, 0
    for index, char in enumerate(body):
        depth += {"{": 1, "}": -1}.get(char, 0)
        if char == "," and depth == 0:
            parts.append(body[start:index])
            start = index + 1
    parts.append(body[start:])
    key, *fields = [part.strip() for part in parts if part.strip()]
    pairs = [
        (name.strip(), value.strip())
        for name, value in (field.split("=", 1) for field in fields)
    ]
    # Crossref writes `month = July`, which BibTeX reads as an undefined macro
    return (
        kind,
        key,
        [
            (
                name,
                value[:3].lower()
                if name.lower() == "month" and value.isalpha()
                else value,
            )
            for name, value in pairs
        ],
    )


def open_access_pdf(doi: str) -> str | None:
    try:
        work = json.loads(
            fetch(
                f"https://api.openalex.org/works/doi:{quote(doi)}?select=best_oa_location"
            )
        )
    except URLError:
        # the PDF is optional: without OpenAlex the paper still has its BibTeX
        return None
    return (work["best_oa_location"] or {}).get("pdf_url")


# BibTeX from doi.org, the open access PDF from OpenAlex
def paper(doi: str) -> dict:
    page = f"https://doi.org/{doi}"
    with ThreadPoolExecutor() as pool:
        pending_pdf = pool.submit(open_access_pdf, doi)
        try:
            text = fetch(page, "application/x-bibtex")
        except URLError as error:
            sys.exit(f"doi.org: {doi} {str(error.reason).lower()}")
        pdf = pending_pdf.result()
    if not text.lstrip().startswith("@"):
        sys.exit(f"no BibTeX for {doi}")
    kind, key, fields = bibtex_entry(text)
    values = {name.lower(): value.strip("{}") for name, value in fields}
    return {
        "id": doi,
        "key": key,
        "title": values.get("title", doi),
        "authors": values.get("author", "").split(" and "),
        "year": values.get("year", ""),
        "venue": values.get("journal")
        or values.get("booktitle")
        or values.get("publisher", ""),
        "page": page,
        "pdf": pdf,
        "bibtex": f"{kind}{{{key},\n"
        + ",\n".join(
            f"  {name} = {re.sub(r'(?<!\\)&', r'\\&', value)}" for name, value in fields
        )
        + "\n}",
    }
