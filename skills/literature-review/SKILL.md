---
name: literature-review
description: 'Conduct comprehensive, systematic literature reviews across multiple academic databases (PubMed, arXiv, bioRxiv, Semantic Scholar, etc.). Use for systematic reviews, meta-analyses, scoping reviews, research synthesis, and broad literature searches, including topic overviews, surveys, and state-of-the-art summaries that gather and organize the major work on a subject by theme or method. Produces professionally formatted markdown and PDF documents with verified citations in multiple styles (APA, Nature, Vancouver, etc.).'
allowed-tools: Read, Write, Edit, Bash
license: MIT license
metadata:
    skill-author: K-Dense Inc.
---

# Literature Review

## Overview

Conduct systematic, comprehensive literature reviews following rigorous academic methodology. Search multiple literature databases, synthesize findings thematically, verify all citations for accuracy, and generate professional output documents in markdown and PDF formats.

This skill is **runnable standalone** using the built-in `WebSearch` and `WebFetch` tools plus direct calls to free academic database APIs (NCBI E-utilities, the bioRxiv/medRxiv API, arXiv, Semantic Scholar, CrossRef, OpenAlex). It provides bundled tools for citation verification, result aggregation, and document generation that depend only on Python `requests` and pandoc.

Several **optional external skills/tools** can enhance the workflow if you have them installed, but none are bundled with this skill and none are required:
- **parallel-cli** (`parallel-web-tools` on PyPI), an optional external CLI for broad web search and URL extraction with academic domain filtering.
- **scientific-schematics**, an optional external skill for AI-generated diagrams (see the bundled `scripts/generate_schematic*.py` for a self-contained alternative that uses a paid OpenRouter key).
- Domain-specific data skills/libraries (e.g. `gget`, `bioservices`, `datacommons-client`, `scanpy`, `anndata`, `biopython`), optional external tools for specialized biomedical/structural databases. Where they are mentioned below, a direct-API fallback is given so the core workflow never depends on them.

## When to Use This Skill

Use this skill when:
- Conducting a systematic literature review for research or publication
- Synthesizing current knowledge on a specific topic across multiple sources
- Performing meta-analysis or scoping reviews
- Writing the literature review section of a research paper or thesis
- Investigating the state of the art in a research domain
- Identifying research gaps and future directions
- Requiring verified citations and professional formatting

## Visual Enhancement with Scientific Schematics

**Recommended (optional): Include 1-2 figures so the review communicates visually.** Figures strengthen a review but are not required for it to be valid; a text-only review with a well-described PRISMA flow is still complete. When you do add figures:
1. Generate at minimum ONE schematic or diagram (e.g., PRISMA flow diagram for systematic reviews)
2. Prefer 2-3 figures for comprehensive reviews (search strategy flowchart, thematic synthesis diagram, conceptual framework)

**How to generate figures:**
- **scientific-schematics** is an optional external skill (not bundled with this skill); use it if you have it installed for AI-powered publication-quality diagrams.
- Alternatively, use the bundled scripts below, which are self-contained but call a paid third-party API.
- For a no-cost, no-dependency option, hand-author a PRISMA box diagram directly in markdown/ASCII (see the PRISMA section under Phase 3) or with any local drawing tool.

**How to generate schematics (bundled scripts, optional, paid API):**
```bash
python scripts/generate_schematic.py "your diagram description" -o figures/output.png
```

> **Paid-API disclosure:** `scripts/generate_schematic.py` and `scripts/generate_schematic_ai.py` call the **OpenRouter** API and require a paid `OPENROUTER_API_KEY` (set as an environment variable or in a `.env` file). They send your prompt to OpenRouter and incur per-image charges; they make outbound network requests on every run. The image model is `google/gemini-3.1-flash-image-preview` (marketed as "Nano Banana 2"); review uses `google/gemini-3.5-flash`. These scripts are entirely optional and are not needed for any other phase of the workflow.

The script will automatically:
- Create publication-quality images with proper formatting
- Review and refine through multiple iterations
- Ensure accessibility (colorblind-friendly, high contrast)
- Save outputs in the figures/ directory

**When to add schematics:**
- PRISMA flow diagrams for systematic reviews
- Literature search strategy flowcharts
- Thematic synthesis diagrams
- Research gap visualization maps
- Citation network diagrams
- Conceptual framework illustrations
- Any complex concept that benefits from visualization

For detailed guidance on creating schematics, refer to the scientific-schematics skill documentation if that optional skill is installed; otherwise use the bundled scripts (paid API) or hand-author the diagram.

---

## Core Workflow

Literature reviews follow a structured, multi-phase workflow:

### Phase 1: Planning and Scoping

1. **Define Research Question**: Use PICO framework (Population, Intervention, Comparison, Outcome) for clinical/biomedical reviews
   - Example: "What is the efficacy of CRISPR-Cas9 (I) for treating sickle cell disease (P) compared to standard care (C)?"

2. **Establish Scope and Objectives**:
   - Define clear, specific research questions
   - Determine review type (narrative, systematic, scoping, meta-analysis)
   - Set boundaries (time period, geographic scope, study types)

3. **Develop Search Strategy**:
   - Identify 2-4 main concepts from research question
   - List synonyms, abbreviations, and related terms for each concept
   - Plan Boolean operators (AND, OR, NOT) to combine terms
   - Select minimum 3 complementary databases
   - **For initial scoping**, use the built-in `WebSearch` tool to quickly gauge the landscape before formal database searches (or the optional external `parallel-cli search` if installed)

4. **Set Inclusion/Exclusion Criteria**:
   - Date range (e.g., last 10 years: 2015-2024)
   - Language (typically English, or specify multilingual)
   - Publication types (peer-reviewed, preprints, reviews)
   - Study designs (RCTs, observational, in vitro, etc.)
   - Document all criteria clearly

### Phase 2: Systematic Literature Search

1. **Multi-Database Search**:

   Select databases appropriate for the domain. **The default, no-dependency path is the built-in `WebSearch` tool for broad scholarly coverage plus direct calls to free database APIs.** If you have the optional external `parallel-cli` installed, you can use it instead for the broad-coverage step; it is not required.

   **Web-Based Academic Search (default, built-in `WebSearch`):**
   - Run two `WebSearch` queries to catch all relevant sources: one academic-focused (append scholarly domains/terms such as `arxiv.org`, `pubmed`, `nature.com`, `semanticscholar.org`, `biorxiv.org` to the query) and one general.
   - Use the built-in `WebFetch` tool to pull full content from specific paper URLs or PDFs found in the results (e.g. `WebFetch "https://arxiv.org/abs/XXXX.XXXXX"`).
   - Save the distilled results into `sources/` so the search stays reproducible.

   **Optional external alternative (`parallel-cli`, not bundled):** if installed, `parallel-cli search ... --include-domains "..."` and `parallel-cli extract "<url>" --json` provide the same broad-search and extraction steps with academic domain filtering. Install with `uv tool install "parallel-web-tools[cli]"`.

   **Biomedical & Life Sciences (direct APIs, no extra skill required):**
   - **PubMed/PMC:** use NCBI E-utilities directly via `WebFetch`. Search with ESearch (`https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=<query>&retmax=100`) to get PMIDs, then fetch records with ESummary/EFetch (`.../esummary.fcgi?db=pubmed&id=<pmids>`). `gget search` does NOT query PubMed (it searches Ensembl genes and requires `-s/--species`), so do not use it here.
   - **bioRxiv/medRxiv preprints:** use the bioRxiv API directly, e.g. `WebFetch "https://api.biorxiv.org/details/biorxiv/<YYYY-MM-DD>/<YYYY-MM-DD>"` (swap `biorxiv` for `medrxiv`), or search via the web UI / `WebSearch` restricted to `biorxiv.org`/`medrxiv.org`. `gget` has no PubMed or bioRxiv module.
   - **ChEMBL, KEGG, UniProt, etc.:** query their public REST APIs via `WebFetch`. The optional external `bioservices` library wraps these if you have it installed.

   **General Scientific Literature:**
   - Search arXiv via its direct API (`http://export.arxiv.org/api/query?search_query=...`), preprints in physics, math, CS, q-bio
   - Search Semantic Scholar via its public API (200M+ papers, cross-disciplinary; see rate limits in `references/database_strategies.md`)
   - Search OpenAlex via its free API (`https://api.openalex.org/works?search=...`, no key required) for broad cross-disciplinary coverage and citation metadata
   - Use Google Scholar for comprehensive coverage (manual search; no official API)

   **Specialized Databases:**
   - AlphaFold protein structures: AlphaFold DB API (`https://alphafold.ebi.ac.uk/api/...`); the optional external `gget alphafold` wraps it
   - Cancer genomics (COSMIC): the COSMIC website/downloads; the optional external `gget cosmic` wraps it
   - Demographic/statistical data: the Data Commons REST API; the optional external `datacommons-client` wraps it
   - Use other specialized databases via their public APIs as appropriate for the domain

2. **Document Search Parameters**:
   ```markdown
   ## Search Strategy

   ### Database: PubMed
   - **Date searched**: 2024-10-25
   - **Date range**: 2015-01-01 to 2024-10-25
   - **Search string**:
     ```
     ("CRISPR"[Title] OR "Cas9"[Title])
     AND ("sickle cell"[MeSH] OR "SCD"[Title/Abstract])
     AND 2015:2024[Publication Date]
     ```
   - **Results**: 247 articles
   ```

   Repeat for each database searched.

3. **Export and Aggregate Results**:
   - Export results in JSON format from each database
   - Combine all results into a single file
   - Use `scripts/search_databases.py` for post-processing:
     ```bash
     python scripts/search_databases.py combined_results.json \
       --deduplicate \
       --format markdown \
       --output aggregated_results.md
     ```

### Phase 3: Screening and Selection

1. **Deduplication**:
   ```bash
   python scripts/search_databases.py results.json --deduplicate --output unique_results.json
   ```
   - Removes duplicates by DOI (primary) or title (fallback)
   - Document number of duplicates removed

2. **Title Screening**:
   - Review all titles against inclusion/exclusion criteria
   - Exclude obviously irrelevant studies
   - Document number excluded at this stage

3. **Abstract Screening**:
   - Read abstracts of remaining studies
   - Apply inclusion/exclusion criteria rigorously
   - Document reasons for exclusion

4. **Full-Text Screening**:
   - Obtain full texts of remaining studies
   - Conduct detailed review against all criteria
   - Document specific reasons for exclusion
   - Record final number of included studies

5. **Create PRISMA 2020 Flow Diagram**:

   Follow the PRISMA 2020 flow-diagram box sequence. Track *records* (database hits/citations) and *reports* (retrievable full-text documents) separately, account for everything removed *before* screening, and give explicit exclusion reason counts at full-text assessment. (The bundled `assets/review_template.md` follows this same structure.)
   ```
   Identification
     Records identified from databases/registers: n = X
       (per source, e.g. PubMed n=…, bioRxiv n=…)
     Records removed before screening:
       - Duplicate records removed:                n = …
       - Records marked ineligible by automation:  n = …
       - Records removed for other reasons:         n = …

   Screening
     Records screened (title/abstract):            n = …
       Records excluded:                           n = …
     Reports sought for retrieval:                 n = …
       Reports not retrieved:                      n = …
     Reports assessed for eligibility:             n = …
       Reports excluded (with reason + count):
         - Wrong population:                        n = …
         - Wrong intervention/outcome:              n = …
         - Wrong study design:                      n = …
         - Other (specify):                         n = …

   Included
     Studies included in review:                   n = …
     Reports of included studies:                  n = …
   ```
   Every full-text exclusion MUST be recorded with a specific reason and its count (list excluded reports in Appendix C of the template).

### Phase 4: Data Extraction and Quality Assessment

1. **Extract Key Data** from each included study:
   - Study metadata (authors, year, journal, DOI)
   - Study design and methods
   - Sample size and population characteristics
   - Key findings and results
   - Limitations noted by authors
   - Funding sources and conflicts of interest

2. **Assess Risk of Bias (per study)** using the tool-specific labels of each instrument, do NOT relabel these as GRADE certainty levels:
   - **For RCTs**: Cochrane RoB 2 → rate each study **Low risk / Some concerns / High risk**
   - **For non-randomized/observational studies**: ROBINS-I (**Low / Moderate / Serious / Critical**) or the Newcastle-Ottawa Scale (star score)
   - **For systematic reviews**: AMSTAR 2 (**High / Moderate / Low / Critically low** confidence in the review)
   - Consider excluding studies at high/critical risk of bias, or analyze them separately in a sensitivity analysis

   **Rate certainty of evidence (per outcome), separately, with GRADE**: each outcome (not each study) is rated **High / Moderate / Low / Very Low** certainty, downgraded for risk of bias, inconsistency, indirectness, imprecision, and publication bias. Risk of bias is one *input* to GRADE; it is not the same scale.

3. **Organize by Themes**:
   - Identify 3-5 major themes across studies
   - Group studies by theme (studies may appear in multiple themes)
   - Note patterns, consensus, and controversies

### Phase 5: Synthesis and Analysis

1. **Create Review Document** from template:
   ```bash
   cp assets/review_template.md my_literature_review.md
   ```

2. **Write Thematic Synthesis** (NOT study-by-study summaries):
   - Organize Results section by themes or research questions
   - Synthesize findings across multiple studies within each theme
   - Compare and contrast different approaches and results
   - Identify consensus areas and points of controversy
   - Highlight the strongest evidence

   Example structure:
   ```markdown
   #### 3.3.1 Theme: CRISPR Delivery Methods

   Multiple delivery approaches have been investigated for therapeutic
   gene editing. Viral vectors (AAV) were used in 15 studies^1-15^ and
   showed high transduction efficiency (65-85%) but raised immunogenicity
   concerns^3,7,12^. In contrast, lipid nanoparticles demonstrated lower
   efficiency (40-60%) but improved safety profiles^16-23^.
   ```

3. **Critical Analysis**:
   - Evaluate methodological strengths and limitations across studies
   - Assess quality and consistency of evidence
   - Identify knowledge gaps and methodological gaps
   - Note areas requiring future research

4. **Write Discussion**:
   - Interpret findings in broader context
   - Discuss clinical, practical, or research implications
   - Acknowledge limitations of the review itself
   - Compare with previous reviews if applicable
   - Propose specific future research directions

### Phase 6: Citation Verification

**CRITICAL**: All citations must be verified for accuracy before final submission.

1. **Verify All DOIs**:
   ```bash
   python scripts/verify_citations.py my_literature_review.md
   ```

   This script:
   - Extracts all DOIs from the document
   - Verifies each DOI resolves correctly
   - Retrieves metadata from CrossRef
   - Generates verification report
   - Outputs properly formatted citations

2. **Review Verification Report**:
   - Check for any failed DOIs
   - Verify author names, titles, and publication details match
   - Correct any errors in the original document
   - Re-run verification until all citations pass

3. **Format Citations Consistently**:
   - Choose one citation style and use throughout (see `references/citation_styles.md`)
   - Common styles: APA, Nature, Vancouver, Chicago, IEEE
   - Use verification script output to format citations correctly
   - Ensure in-text citations match reference list format

### Phase 7: Document Generation

1. **Generate PDF**:
   ```bash
   python scripts/generate_pdf.py my_literature_review.md \
     --citation-style apa \
     --output my_review.pdf
   ```

   Options:
   - `--citation-style`: apa, nature, chicago, vancouver, ieee
   - `--no-toc`: Disable table of contents
   - `--no-numbers`: Disable section numbering
   - `--check-deps`: Check if pandoc/xelatex are installed

2. **Review Final Output**:
   - Check PDF formatting and layout
   - Verify all sections are present
   - Ensure citations render correctly
   - Check that figures/tables appear properly
   - Verify table of contents is accurate

3. **Quality Checklist**:
   - [ ] All DOIs verified with verify_citations.py
   - [ ] Citations formatted consistently
   - [ ] PRISMA flow diagram included (for systematic reviews)
   - [ ] Search methodology fully documented
   - [ ] Inclusion/exclusion criteria clearly stated
   - [ ] Results organized thematically (not study-by-study)
   - [ ] Quality assessment completed
   - [ ] Limitations acknowledged
   - [ ] References complete and accurate
   - [ ] PDF generates without errors

## Database-Specific Search Guidance

### PubMed / PubMed Central

Access via NCBI E-utilities (Entrez), using the built-in `WebFetch` tool. Do NOT use `gget search` here: it queries Ensembl genes (and requires `-s/--species`); it has no PubMed module.
```bash
# 1. ESearch -> list of PMIDs for a query
#   https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=CRISPR+gene+editing&retmax=100
# 2. ESummary/EFetch -> records for those PMIDs
#   https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=<pmid1,pmid2,...>
# Build complex queries with the PubMed Advanced Search Builder, then run the
# resulting term string through ESearch.
```

**Search tips**:
- Use MeSH terms: `"sickle cell disease"[MeSH]`
- Field tags: `[Title]`, `[Title/Abstract]`, `[Author]`
- Date filters: `2020:2024[Publication Date]`
- Boolean operators: AND, OR, NOT
- See MeSH browser: https://meshb.nlm.nih.gov/search

### bioRxiv / medRxiv

Access via the bioRxiv/medRxiv API (using `WebFetch`) or `WebSearch` restricted to the preprint domains. `gget` has no bioRxiv module.
```bash
# bioRxiv content API (swap "biorxiv" for "medrxiv"); filter the returned
# records by your search terms client-side:
#   https://api.biorxiv.org/details/biorxiv/2015-01-01/2024-12-31
# Or: WebSearch "CRISPR sickle cell site:biorxiv.org"
```

**Important considerations**:
- Preprints are not peer-reviewed
- Verify findings with caution
- Check if preprint has been published (CrossRef)
- Note preprint version and date

### arXiv

Access via direct API or WebFetch:
```python
# Example search categories:
# q-bio.QM (Quantitative Methods)
# q-bio.GN (Genomics)
# q-bio.MN (Molecular Networks)
# cs.LG (Machine Learning)
# stat.ML (Machine Learning Statistics)

# Search format: category AND terms
search_query = "cat:q-bio.QM AND ti:\"single cell sequencing\""
```

### Semantic Scholar

Access via the public API (an API key is optional, not required; see rate limits in `references/database_strategies.md`):
- 200M+ papers across all fields
- Excellent for cross-disciplinary searches
- Provides citation graphs and paper recommendations
- Use for finding highly influential papers

### Specialized Biomedical Databases

Query the free public REST API of each database directly with `WebFetch`. The named libraries are **optional external wrappers** (not bundled, not required):
- **ChEMBL**: ChEMBL REST API (optional wrapper: `bioservices`) for chemical bioactivity
- **UniProt**: UniProt REST API (optional wrappers: `gget`, `bioservices`) for protein information
- **KEGG**: KEGG REST API (optional wrapper: `bioservices`) for pathways and genes
- **COSMIC**: COSMIC website/downloads (optional wrapper: `gget`) for cancer mutations
- **AlphaFold**: AlphaFold DB API (optional wrapper: `gget alphafold`) for protein structures
- **PDB**: RCSB PDB REST API (optional wrapper: `gget`) for experimental structures

### Citation Chaining

Expand search via citation networks:

1. **Forward citations** (papers citing key papers):
   - Use the **Semantic Scholar or OpenAlex APIs** (via `WebFetch`) to list papers that cite a given DOI, both expose a citations endpoint and require no key (OpenAlex: `https://api.openalex.org/works?filter=cites:<openalex-id>`)
   - Use the built-in `WebSearch` tool (e.g. `WebSearch "papers citing [Author et al. Year] [title]" site:semanticscholar.org`), or the optional external `parallel-cli search --include-domains "..."` if installed
   - Use Google Scholar "Cited by"
   - Identifies newer research building on seminal work

2. **Backward citations** (references from key papers):
   - Use the built-in `WebFetch` tool to pull the full text of key papers and extract their reference lists (or the optional external `parallel-cli extract "<url>" --json` if installed)
   - Better yet, read references straight from the CrossRef/OpenAlex record for the DOI (both list cited works)
   - Identify highly cited foundational work
   - Find papers cited by multiple included studies

## Citation Style Guide

Detailed formatting guidelines are in `references/citation_styles.md`. Quick reference:

### APA (7th Edition)
- In-text: (Smith et al., 2023)
- Reference: Smith, J. D., Johnson, M. L., & Williams, K. R. (2023). Title. *Journal*, *22*(4), 301-318. https://doi.org/10.xxx/yyy

### Nature
- In-text: Superscript numbers^1,2^
- Reference: Smith, J. D., Johnson, M. L. & Williams, K. R. Title. *Nat. Rev. Drug Discov.* **22**, 301-318 (2023).

### Vancouver
- In-text: Superscript numbers^1,2^
- Reference: Smith JD, Johnson ML, Williams KR. Title. Nat Rev Drug Discov. 2023;22(4):301-18.

**Always verify citations** with verify_citations.py before finalizing.

### Prioritizing High-Impact Papers (CRITICAL)

**Always prioritize influential, highly-cited papers from reputable authors and top venues.** Quality matters more than quantity in literature reviews.

#### Citation Count Thresholds

Use citation counts to identify the most impactful papers:

| Paper Age | Citation Threshold | Classification |
|-----------|-------------------|----------------|
| 0-3 years | 20+ citations | Noteworthy |
| 0-3 years | 100+ citations | Highly Influential |
| 3-7 years | 100+ citations | Significant |
| 3-7 years | 500+ citations | Landmark Paper |
| 7+ years | 500+ citations | Seminal Work |
| 7+ years | 1000+ citations | Foundational |

#### Journal and Venue Tiers

Prioritize papers from higher-tier venues:

- **Tier 1 (Always Prefer):** Nature, Science, Cell, NEJM, Lancet, JAMA, PNAS, Nature Medicine, Nature Biotechnology
- **Tier 2 (Strong Preference):** High-impact specialized journals (IF>10), top conferences (NeurIPS, ICML for ML/AI)
- **Tier 3 (Include When Relevant):** Respected specialized journals (IF 5-10)
- **Tier 4 (Use Sparingly):** Lower-impact peer-reviewed venues

#### Author Reputation Assessment

Prefer papers from:
- **Senior researchers** with high h-index (>40 in established fields)
- **Leading research groups** at recognized institutions (Harvard, Stanford, MIT, Oxford, etc.)
- **Authors with multiple Tier-1 publications** in the relevant field
- **Researchers with recognized expertise** (awards, editorial positions, society fellows)

#### Identifying Seminal Papers

For any topic, identify foundational work by:
1. **High citation count** (typically 500+ for papers 5+ years old)
2. **Frequently cited by other included studies** (appears in many reference lists)
3. **Published in Tier-1 venues** (Nature, Science, Cell family)
4. **Written by field pioneers** (often cited as establishing concepts)

## Best Practices

### Search Strategy
1. **Start broad with `WebSearch`**: Use the built-in `WebSearch` tool (or the optional external `parallel-cli search`) with academic domains for initial broad coverage before querying specialized databases
2. **Use multiple databases** (minimum 3): Ensures comprehensive coverage, the broad web search counts as one source
3. **Include preprint servers**: Captures latest unpublished findings
4. **Document everything**: Search strings, dates, result counts for reproducibility, save all search output to `sources/`
5. **Test and refine**: Run pilot searches, review results, adjust search terms
6. **Sort by citations**: When available, sort search results by citation count to surface influential work first
7. **Fetch full content with `WebFetch`**: Pull full text from promising URLs found during search (or the optional external `parallel-cli extract`) to verify relevance before full-text screening

### Screening and Selection
1. **Use clear criteria**: Document inclusion/exclusion criteria before screening
2. **Screen systematically**: Title → Abstract → Full text
3. **Document exclusions**: Record reasons for excluding studies
4. **Consider dual screening**: For systematic reviews, have two reviewers screen independently

### Synthesis
1. **Organize thematically**: Group by themes, NOT by individual studies
2. **Synthesize across studies**: Compare, contrast, identify patterns
3. **Be critical**: Evaluate quality and consistency of evidence
4. **Identify gaps**: Note what's missing or understudied

### Quality and Reproducibility
1. **Assess study quality**: Use appropriate quality assessment tools
2. **Verify all citations**: Run verify_citations.py script
3. **Document methodology**: Provide enough detail for others to reproduce
4. **Follow guidelines**: Use PRISMA for systematic reviews

### Writing
1. **Be objective**: Present evidence fairly, acknowledge limitations
2. **Be systematic**: Follow structured template
3. **Be specific**: Include numbers, statistics, effect sizes where available
4. **Be clear**: Use clear headings, logical flow, thematic organization

## Common Pitfalls to Avoid

1. **Single database search**: Misses relevant papers; always search multiple databases
2. **No search documentation**: Makes review irreproducible; document all searches
3. **Study-by-study summary**: Lacks synthesis; organize thematically instead
4. **Unverified citations**: Leads to errors; always run verify_citations.py
5. **Too broad search**: Yields thousands of irrelevant results; refine with specific terms
6. **Too narrow search**: Misses relevant papers; include synonyms and related terms
7. **Ignoring preprints**: Misses latest findings; include bioRxiv, medRxiv, arXiv
8. **No quality assessment**: Treats all evidence equally; assess and report quality
9. **Publication bias**: Only positive results published; note potential bias
10. **Outdated search**: Field evolves rapidly; clearly state search date

## Example Workflow

Complete workflow for a biomedical literature review:

```bash
# 1. Create review document from template
cp assets/review_template.md crispr_sickle_cell_review.md

# 2. Start with a broad academic search using the built-in WebSearch tool
#    Run one academic-focused query and one general query, e.g.:
#      WebSearch "CRISPR Cas9 sickle cell disease gene therapy efficacy
#                 (arxiv.org OR pubmed OR semanticscholar.org OR biorxiv.org OR nature.com)"
#      WebSearch "CRISPR sickle cell disease clinical trials treatment"
#    Save the distilled hits to sources/ for reproducibility.
#
#    Optional external alternative (parallel-cli, if installed):
#      parallel-cli search "CRISPR Cas9 sickle cell disease gene therapy efficacy" \
#        -q "CRISPR" -q "sickle cell" -q "gene therapy" \
#        --json --max-results 10 --excerpt-max-chars-total 27000 \
#        --include-domains "arxiv.org,pubmed.ncbi.nlm.nih.gov,semanticscholar.org,biorxiv.org,nature.com,cell.com,pnas.org" \
#        -o sources/litreview_crispr_scd-academic.json

# 3. Search specialized databases via their public APIs (WebFetch)
# - PubMed: NCBI E-utilities (esearch.fcgi / efetch.fcgi) -- NOT gget
# - bioRxiv/medRxiv: api.biorxiv.org -- NOT gget
# - arXiv: export.arxiv.org/api/query ; Semantic Scholar / OpenAlex: public APIs
# - Export results in JSON format into sources/

# 4. Aggregate and process results (combine web-search + database results)
python scripts/search_databases.py combined_results.json \
  --deduplicate \
  --rank citations \
  --year-start 2015 \
  --year-end 2024 \
  --format markdown \
  --output search_results.md \
  --summary

# 5. Screen results and extract data
# - Use the WebFetch tool (or optional parallel-cli extract) to fetch full content from promising URLs
# - Manually screen titles, abstracts, full texts
# - Extract key data into the review document
# - Organize by themes

# 6. Write the review following template structure
# - Introduction with clear objectives
# - Detailed methodology section
# - Results organized thematically
# - Critical discussion
# - Clear conclusions

# 7. Verify all citations
python scripts/verify_citations.py crispr_sickle_cell_review.md

# Review the citation report
cat crispr_sickle_cell_review_citation_report.json

# Fix any failed citations and re-verify
python scripts/verify_citations.py crispr_sickle_cell_review.md

# 8. Generate professional PDF
python scripts/generate_pdf.py crispr_sickle_cell_review.md \
  --citation-style nature \
  --output crispr_sickle_cell_review.pdf

# 9. Review final PDF and markdown outputs
```

## Integration with Other Skills

This skill works seamlessly with other scientific skills:

All of the tools listed below are **optional external dependencies**: none ship with this skill, and the core workflow runs without them using the built-in `WebSearch`/`WebFetch` tools and direct database APIs.

### Web Search & Extraction (optional external `parallel-cli`)
`parallel-cli` is a real, separately installed CLI (`parallel-web-tools` on PyPI), not a bundled skill. If installed, it can replace the built-in `WebSearch`/`WebFetch` steps:
- **parallel-cli search**: Broad academic and general web search with domain filtering, initial scoping, finding papers, citation chaining, supplementary searches
- **parallel-cli extract**: Fetch full content from paper URLs, journal websites, and preprint servers, reading abstracts, extracting reference lists, verifying paper details
- **parallel-cli search --include-domains**: Academic-focused search across scholarly domains (arxiv.org, pubmed, nature.com, etc.)

### Database Access (optional external wrappers; use the public APIs directly otherwise)
- **gget**: COSMIC, AlphaFold, Ensembl, UniProt (NOTE: `gget` does NOT cover PubMed or bioRxiv, use NCBI E-utilities and the bioRxiv API directly for those)
- **bioservices**: ChEMBL, KEGG, Reactome, UniProt, PubChem
- **datacommons-client**: Demographics, economics, health statistics

### Analysis Libraries (optional external; for methods/background sections only)
- **pydeseq2**: RNA-seq differential expression
- **scanpy**: Single-cell analysis
- **anndata**: Single-cell data
- **biopython**: Sequence analysis

### Visualization Skills
- **matplotlib**: Generate figures and plots for review
- **seaborn**: Statistical visualizations

### Writing Skills
- **brand-guidelines**: Apply institutional branding to PDF
- **internal-comms**: Adapt review for different audiences

## Resources

### Bundled Resources

**Scripts:**
- `scripts/verify_citations.py`: Verify DOIs and generate formatted citations
- `scripts/generate_pdf.py`: Convert markdown to professional PDF
- `scripts/search_databases.py`: Process, deduplicate, and format search results

**References:**
- `references/citation_styles.md`: Detailed citation formatting guide (APA, Nature, Vancouver, Chicago, IEEE)
- `references/database_strategies.md`: Comprehensive database search strategies

**Assets:**
- `assets/review_template.md`: Complete literature review template with all sections

### External Resources

**Guidelines:**
- PRISMA (Systematic Reviews): http://www.prisma-statement.org/
- Cochrane Handbook: https://training.cochrane.org/handbook
- AMSTAR 2 (Review Quality): https://amstar.ca/

**Tools:**
- MeSH Browser: https://meshb.nlm.nih.gov/search
- PubMed Advanced Search: https://pubmed.ncbi.nlm.nih.gov/advanced/
- Boolean Search Guide: https://www.ncbi.nlm.nih.gov/books/NBK3827/

**Citation Styles:**
- APA Style: https://apastyle.apa.org/
- Nature Portfolio: https://www.nature.com/nature-portfolio/editorial-policies/reporting-standards
- NLM/Vancouver: https://www.nlm.nih.gov/bsd/uniform_requirements.html

## Dependencies

### Optional External CLI Tools
```bash
# parallel-cli (OPTIONAL, external; the workflow runs without it using the
# built-in WebSearch/WebFetch tools). Real package: parallel-web-tools on PyPI.
curl -fsSL https://parallel.ai/install.sh | bash
# Or: uv tool install "parallel-web-tools[cli]"
# Authenticate: parallel-cli auth
```

### Required Python Packages
```bash
pip install requests  # For citation verification (the only required dependency for the bundled scripts)
```

> Image-generation scripts (`scripts/generate_schematic*.py`) are optional and additionally require a paid `OPENROUTER_API_KEY`; see the Visual Enhancement section.

### Required System Tools
```bash
# For PDF generation
brew install pandoc  # macOS
apt-get install pandoc  # Linux

# For LaTeX (PDF generation)
brew install --cask mactex  # macOS
apt-get install texlive-xetex  # Linux
```

Check dependencies:
```bash
python scripts/generate_pdf.py --check-deps
```

## Summary

This literature-review skill provides:

1. **Systematic methodology** following academic best practices
2. **Built-in web search** using the `WebSearch`/`WebFetch` tools for fast, broad academic literature discovery (optionally the external `parallel-cli`)
3. **Multi-database integration** via direct public APIs (NCBI E-utilities, bioRxiv, arXiv, Semantic Scholar, OpenAlex, CrossRef), with optional external wrappers (gget, bioservices, datacommons-client)
4. **Citation verification** ensuring accuracy and credibility
5. **Professional output** in markdown and PDF formats
6. **Comprehensive guidance** covering the entire review process
7. **Quality assurance** with verification and validation tools
8. **Reproducibility** through detailed documentation requirements

Conduct thorough, rigorous literature reviews that meet academic standards and provide comprehensive synthesis of current knowledge in any domain.

