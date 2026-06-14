#!/usr/bin/env python3
"""
Literature Database Search Script
Searches multiple literature databases and aggregates results.
"""

import json
import sys
from typing import Dict, List
from datetime import datetime

def format_search_results(results: List[Dict], output_format: str = 'json') -> str:
    """
    Format search results for output.

    Args:
        results: List of search results
        output_format: Format (json, markdown, or bibtex)

    Returns:
        Formatted string
    """
    if output_format == 'json':
        return json.dumps(results, indent=2)

    elif output_format == 'markdown':
        md = f"# Literature Search Results\n\n"
        md += f"**Search Date**: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n"
        md += f"**Total Results**: {len(results)}\n\n"

        for i, result in enumerate(results, 1):
            md += f"## {i}. {result.get('title', 'Untitled')}\n\n"
            md += f"**Authors**: {result.get('authors', 'Unknown')}\n\n"
            md += f"**Year**: {result.get('year', 'N/A')}\n\n"
            md += f"**Source**: {result.get('source', 'Unknown')}\n\n"

            if result.get('abstract'):
                md += f"**Abstract**: {result['abstract']}\n\n"

            if result.get('doi'):
                md += f"**DOI**: [{result['doi']}](https://doi.org/{result['doi']})\n\n"

            if result.get('url'):
                md += f"**URL**: {result['url']}\n\n"

            if result.get('citations'):
                md += f"**Citations**: {result['citations']}\n\n"

            md += "---\n\n"

        return md

    elif output_format == 'bibtex':
        bibtex = ""
        for i, result in enumerate(results, 1):
            entry_type = result.get('type', 'article')
            cite_key = f"{result.get('first_author', 'unknown')}{result.get('year', '0000')}"

            bibtex += f"@{entry_type}{{{cite_key},\n"
            bibtex += f"  title = {{{result.get('title', '')}}},\n"
            bibtex += f"  author = {{{result.get('authors', '')}}},\n"
            bibtex += f"  year = {{{result.get('year', '')}}},\n"

            if result.get('journal'):
                bibtex += f"  journal = {{{result['journal']}}},\n"

            if result.get('volume'):
                bibtex += f"  volume = {{{result['volume']}}},\n"

            if result.get('pages'):
                bibtex += f"  pages = {{{result['pages']}}},\n"

            if result.get('doi'):
                bibtex += f"  doi = {{{result['doi']}}},\n"

            bibtex += "}\n\n"

        return bibtex

    else:
        raise ValueError(f"Unknown format: {output_format}")

def deduplicate_results(results: List[Dict]) -> List[Dict]:
    """
    Remove duplicate results based on DOI or title.

    Args:
        results: List of search results

    Returns:
        Deduplicated list
    """
    seen_dois = set()
    seen_title_sigs = set()
    unique_results = []

    for result in results:
        # Guard against None values (a record may carry doi=None or title=None)
        doi = (result.get('doi') or '').lower().strip()
        # Normalize title (collapse whitespace) so minor formatting differences
        # across databases still collapse a genuine duplicate.
        title = ' '.join((result.get('title') or '').lower().split())
        year = str(result.get('year') or '').strip()
        # Guard the title match by year: the same title in the same year is
        # almost certainly the same work (e.g. a preprint and the published
        # article under different DOIs), whereas an identical title in a
        # different year is likely a distinct work and must NOT be merged.
        title_sig = (title, year) if title else None

        # DOI is authoritative: a previously seen DOI is always a duplicate.
        if doi and doi in seen_dois:
            continue
        # Fall back to the year-guarded title signature ONLY when this record has
        # no usable DOI of its own, so a shared title alone never overrides
        # DOI-distinct records. Two records with different DOIs are distinct works
        # (e.g. an erratum or a same-title paper in two venues) and must be kept,
        # even if their title+year happens to match.
        if not doi and title_sig and title_sig in seen_title_sigs:
            continue

        if doi:
            seen_dois.add(doi)
        if title_sig:
            seen_title_sigs.add(title_sig)

        unique_results.append(result)

    return unique_results

def rank_results(results: List[Dict], criteria: str = 'citations') -> List[Dict]:
    """
    Rank results by specified criteria.

    Args:
        results: List of search results
        criteria: Ranking criteria (citations, year, relevance)

    Returns:
        Ranked list
    """
    def _as_int(value, default: int = 0) -> int:
        """Coerce a possibly-string value to int, falling back on default.

        Citation counts often arrive as strings; sorting them lexicographically
        would rank '2' above '10'. Coerce to numeric first.
        """
        try:
            return int(value)
        except (ValueError, TypeError):
            return default

    if criteria == 'citations':
        return sorted(results, key=lambda x: _as_int(x.get('citations', 0)), reverse=True)
    elif criteria == 'year':
        # Years may arrive as ints (e.g. PubMed) or strings (e.g. JSON exports)
        # across aggregated sources; coerce so mixed types sort numerically
        # instead of raising TypeError when comparing int to str.
        return sorted(results, key=lambda x: _as_int(x.get('year', 0)), reverse=True)
    elif criteria == 'relevance':
        return sorted(results, key=lambda x: x.get('relevance_score', 0), reverse=True)
    else:
        return results

def filter_by_year(results: List[Dict], start_year: int = None, end_year: int = None) -> List[Dict]:
    """
    Filter results by publication year range.

    Args:
        results: List of search results
        start_year: Minimum year (inclusive)
        end_year: Maximum year (inclusive)

    Returns:
        Filtered list
    """
    filtered = []

    for result in results:
        raw_year = result.get('year')
        # Treat an absent, null, or empty year the same way as an unparseable
        # one: include the record. Without this, a missing 'year' key would
        # default to 0 and be silently dropped by any start_year bound, while a
        # present 'year': null would parse-fail and be kept (inconsistent), and
        # preprints / incomplete metadata that legitimately lack a year would be
        # removed whenever a bound is set.
        if raw_year is None or (isinstance(raw_year, str) and not raw_year.strip()):
            filtered.append(result)
            continue
        try:
            year = int(raw_year)
            if start_year and year < start_year:
                continue
            if end_year and year > end_year:
                continue
            filtered.append(result)
        except (ValueError, TypeError):
            # Include if year parsing fails
            filtered.append(result)

    return filtered

def generate_search_summary(results: List[Dict]) -> Dict:
    """
    Generate summary statistics for search results.

    Args:
        results: List of search results

    Returns:
        Summary dictionary
    """
    summary = {
        'total_results': len(results),
        'sources': {},
        'year_distribution': {},
        'avg_citations': 0,
        'total_citations': 0
    }

    citations = []

    for result in results:
        # Count by source
        source = result.get('source', 'Unknown')
        summary['sources'][source] = summary['sources'].get(source, 0) + 1

        # Count by year
        year = result.get('year', 'Unknown')
        summary['year_distribution'][year] = summary['year_distribution'].get(year, 0) + 1

        # Collect citations
        if result.get('citations'):
            try:
                citations.append(int(result['citations']))
            except (ValueError, TypeError):
                pass

    if citations:
        summary['avg_citations'] = sum(citations) / len(citations)
        summary['total_citations'] = sum(citations)

    return summary

def main():
    """Command-line interface for search result processing."""
    if len(sys.argv) < 2:
        print("Usage: python search_databases.py <results.json> [options]")
        print("\nOptions:")
        print("  --format FORMAT          Output format (json, markdown, bibtex)")
        print("  --output FILE            Output file (default: stdout)")
        print("  --rank CRITERIA          Rank by (citations, year, relevance)")
        print("  --year-start YEAR        Filter by start year")
        print("  --year-end YEAR          Filter by end year")
        print("  --deduplicate            Remove duplicates")
        print("  --summary                Show summary statistics")
        sys.exit(1)

    # Load results
    results_file = sys.argv[1]
    try:
        with open(results_file, 'r', encoding='utf-8') as f:
            results = json.load(f)
    except Exception as e:
        print(f"Error loading results: {e}")
        sys.exit(1)

    # Parse options
    output_format = 'markdown'
    output_file = None
    rank_criteria = None
    year_start = None
    year_end = None
    do_dedup = False
    show_summary = False

    i = 2
    while i < len(sys.argv):
        arg = sys.argv[i]

        if arg == '--format' and i + 1 < len(sys.argv):
            output_format = sys.argv[i + 1]
            i += 2
        elif arg == '--output' and i + 1 < len(sys.argv):
            output_file = sys.argv[i + 1]
            i += 2
        elif arg == '--rank' and i + 1 < len(sys.argv):
            rank_criteria = sys.argv[i + 1]
            i += 2
        elif arg == '--year-start' and i + 1 < len(sys.argv):
            year_start = int(sys.argv[i + 1])
            i += 2
        elif arg == '--year-end' and i + 1 < len(sys.argv):
            year_end = int(sys.argv[i + 1])
            i += 2
        elif arg == '--deduplicate':
            do_dedup = True
            i += 1
        elif arg == '--summary':
            show_summary = True
            i += 1
        else:
            i += 1

    # Process results
    if do_dedup:
        results = deduplicate_results(results)
        print(f"After deduplication: {len(results)} results")

    if year_start or year_end:
        results = filter_by_year(results, year_start, year_end)
        print(f"After year filter: {len(results)} results")

    if rank_criteria:
        results = rank_results(results, rank_criteria)
        print(f"Ranked by: {rank_criteria}")

    # Show summary
    if show_summary:
        summary = generate_search_summary(results)
        print("\n" + "="*60)
        print("SEARCH SUMMARY")
        print("="*60)
        print(json.dumps(summary, indent=2))
        print()

    # Format output
    output = format_search_results(results, output_format)

    # Write output
    if output_file:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(output)
        print(f"✓ Results saved to: {output_file}")
    else:
        print(output)

if __name__ == "__main__":
    main()
