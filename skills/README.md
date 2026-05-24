# Skills

A curated collection of Claude Code skills for scientific computing, machine learning, data analysis, and academic writing. Each skill provides domain-specific expertise that Claude activates automatically when a task matches its triggers.

## How skills work

Each subdirectory contains a `SKILL.md` with frontmatter describing when the skill should activate and a body with detailed guidance, references, and examples. Claude reads the `description` field to decide whether to load a skill for the current task.

---

## Scientific & Academic Writing

### [scientific-writing-en](./scientific-writing-en)
Drafts, revises, and polishes English academic prose for Q1 journals — articles, theses, abstracts, methods, results, discussions, and any IMRaD section. Provides 5000+ idiomatic native-academic phrases and structural guidance to replace generic LLM-style prose with construction patterns reviewers expect at top-tier journals.

### [redaccion-cientifica-es](./redaccion-cientifica-es)
Equivalent skill for **Spanish** scientific writing. Supplies idiomatic, formal academic phrasing for every standard section of a research document, enforcing the impersonal voice, epistemic caution, and rhetorical conventions of the Hispanic academic tradition.

### [literature-review](./literature-review)
Conducts systematic, comprehensive literature reviews across multiple databases (PubMed, arXiv, bioRxiv, Semantic Scholar, etc.). Generates professionally formatted Markdown/PDF documents with verified citations in APA, Nature, Vancouver, and other styles.

### [citation-management](./citation-management)
Searches Google Scholar and PubMed, extracts accurate metadata from CrossRef/PubMed/arXiv, validates references, and produces properly formatted BibTeX entries. Pairs naturally with `literature-review` for end-to-end research workflows.

### [latex-posters](./latex-posters)
Creates professional research posters in LaTeX using `beamerposter`, `tikzposter`, or `baposter`. Covers layout, color schemes, multi-column formats, figure integration, and visual hierarchy best practices for conference presentations.

---

## Machine Learning

### [scikit-learn](./scikit-learn)
Reference guidance for classical ML with scikit-learn: classification, regression, clustering, dimensionality reduction, preprocessing, pipelines, model evaluation, and hyperparameter tuning.

### [scikit-survival](./scikit-survival)
Survival analysis and time-to-event modeling — Cox models, Random Survival Forests, Gradient Boosting, Survival SVMs, concordance index, Brier score, and competing risks. For censored data workflows.

### [aeon](./aeon)
Time series machine learning with a scikit-learn-compatible API: classification, regression, clustering, forecasting, anomaly detection, segmentation, and similarity search for univariate and multivariate temporal data.

### [shap](./shap)
Model interpretability and explainable AI using SHAP (Shapley values). Computes feature importance and generates waterfall, beeswarm, bar, scatter, force, and heatmap plots for tree models, deep learning, linear models, and any black-box predictor.

### [ml-science-discipline](./ml-science-discipline)
Enforces rigorous scientific methodology for publication-grade ML experiments. Covers dataset splitting, evaluation, feature selection, hyperparameter tuning, uncertainty quantification, external validation, and reporting standards (TRIPOD+AI, CLAIM, STARD-AI, CONSORT-AI).

### [statistical-analysis](./statistical-analysis)
Guided test selection, assumption checking, power analysis, and APA-formatted reporting for hypothesis tests (t-test, ANOVA, chi-square), regression, correlation, and Bayesian analyses.

---

## Data Manipulation & Domain Libraries

### [polars](./polars)
Lightning-fast in-memory DataFrame library built on Apache Arrow. Covers lazy evaluation, expression-based API, and parallel execution — ideal for 1–100 GB ETL workloads where pandas becomes a bottleneck.

### [polars-bio](./polars-bio)
High-performance genomic interval operations (overlap, nearest, merge, coverage, complement, subtract) and bioinformatics file I/O (BED, VCF, BAM, GFF, FASTA, FASTQ) on Polars DataFrames. 6–38× faster than bioframe with cloud-native streaming.

### [scikit-bio](./scikit-bio)
Bioinformatics toolkit: sequence analysis, alignments, phylogenetic trees, diversity metrics (alpha/beta, UniFrac), ordination (PCoA), PERMANOVA, and FASTA/Newick I/O — particularly suited to microbiome analysis.

### [neurokit2](./neurokit2)
Biosignal processing for ECG, EEG, EDA, RSP, PPG, EMG, and EOG. Heart rate variability, event-related potentials, complexity measures, autonomic assessment, and multi-modal physiological integration.

### [networkx](./networkx)
Graph and network analysis: creation, manipulation, centrality, shortest paths, community detection, and visualization. Applies to social networks, biological networks, transportation, citation graphs, and any pairwise-relationship domain.

---

## Visualization

### [matplotlib](./matplotlib)
Foundational Python plotting with fine-grained control over every element. Covers both the pyplot interface and the object-oriented Figure/Axes API for publication-quality static, animated, and interactive plots.

---

## Performance & Engineering

### [optimize-for-gpu](./optimize-for-gpu)
GPU-accelerates Python with CuPy, Numba CUDA, Warp, cuDF, cuML, cuGraph, KvikIO, cuCIM, cuxfilter, cuVS, cuSpatial, and RAFT. Targets NumPy, pandas, scikit-learn, NetworkX, GeoPandas, and Faiss workloads — typically 10×–1000× speedups for suitable cases.

### [python-native](./python-native)
Pushes stdlib idioms over hand-rolled code: `Counter`, `defaultdict`, `singledispatch`, `functools.cache`, `pathlib`, `heapq.nlargest`, `dataclass(slots=True, frozen=True)`, `itertools.pairwise`, and more. Per-version reference files for Python 3.9–3.14.

### [senior-dev-principles](./senior-dev-principles)
Senior-level engineering judgment for non-trivial work: system design, refactoring, algorithm implementation, and structural decisions in Python, TypeScript, C, C++, and SQL. Layers quality criteria on top of "match request scope" defaults.

---

## License

Skills are sourced from multiple authors (notably K-Dense Inc. and personal additions). Individual licenses are declared in each skill's frontmatter — see the `license` field in the corresponding `SKILL.md`.
