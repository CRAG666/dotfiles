---
name: ml-science-discipline
description: 'Enforces rigorous scientific methodology for machine learning experiments intended to support publication-grade claims (Q1 journals, conference papers, regulated decisions). Use this skill when designing an ML pipeline, splitting datasets, evaluating performance, selecting features, tuning hyperparameters, comparing models, quantifying uncertainty, validating externally, or preparing results for a paper. Consult it for any task where experimental validity, reproducibility, or publication standards (TRIPOD+AI, CLAIM, STARD-AI, CONSORT-AI) are in scope. Routine "train a model" or "compute accuracy" requests do NOT automatically trigger this skill unless results will be reported, compared, or acted on.'
---

# ML Good Science: Rigorous Experimentation in Machine Learning

Machine learning experiments must meet the same standards as any empirical science: **reproducibility,
falsifiability, controlled conditions, and unbiased evaluation**. Violating these principles produces
models that fail silently in production and results that cannot be trusted.

> **Core Principle**: Every design decision in an ML pipeline is a potential source of bias.
> Treat the test set as a sealed envelope you cannot open until the very last step — ever.

---

## 1. The Scientific Experimental Framework for ML

### Hypothesis-First Design
Before writing any code, define:
- **Hypothesis**: "Model X will achieve better performance on task Y than baseline Z, measured by metric M."
- **Null hypothesis**: The baseline is sufficient; any gain is due to chance.
- **Significance criterion**: What result would convince you the hypothesis is false?

This forces upfront commitment and prevents post-hoc rationalization of results.

### The Three Inviolable Splits

| Split | Purpose | Rule |
|-------|---------|------|
| **Training set** | Fit model parameters | Anything goes — explore freely |
| **Validation set** | Tune hyperparameters & select models | Use repeatedly, but track iteration count |
| **Test set** | Final unbiased evaluation | **Touch exactly once. Never loop back.** |

```
Full dataset
    │
    ├── 60–80% → Training set       (model learns here)
    ├── 10–20% → Validation set     (you decide here)
    └── 10–20% → Test set           ← SEALED ENVELOPE
```

**Stratified splits** are mandatory for imbalanced targets. Use `sklearn.model_selection.StratifiedKFold`
or equivalent. Time-series data requires **temporal splits** — never shuffle time data.

---

## 2. Data Leakage — The Silent Experiment Killer

Data leakage occurs when information from outside the legitimate training boundary contaminates the model,
producing optimistic but invalid results.

### Taxonomy of Leakage

**Type 1 — Target Leakage (most common)**
A feature contains direct or indirect information about the target that would not be available at inference time.
```
BAD:  Using "days_in_hospital" to predict "will_be_admitted"
BAD:  Using a column computed from the target variable
BAD:  Including post-event features for event prediction
```

**Type 2 — Temporal Leakage**
Future data is used to predict the past.
```
BAD:  Fitting a scaler on the full dataset before splitting
BAD:  Computing rolling statistics across the train/test boundary
BAD:  Using features derived from data that wouldn't exist yet at prediction time
```

**Type 3 — Preprocessing Leakage**
Transformations are fit on data that includes the test set.
```python
# WRONG — scaler sees test data
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)                # leaks test distribution
X_train, X_test = train_test_split(X_scaled)

# CORRECT — scaler fit only on training data
X_train, X_test = train_test_split(X)
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)           # fit on train only
X_test  = scaler.transform(X_test)                # apply to test
```

**Type 4 — Pipeline Leakage**
Any step in the pipeline (imputation, encoding, feature selection) that uses global statistics must be
wrapped in a `Pipeline` or `ColumnTransformer` so it respects the train/test boundary.

```python
# CORRECT — everything inside a Pipeline
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression

pipe = Pipeline([
    ("scaler", StandardScaler()),       # fit_transform on train, transform on test
    ("model", LogisticRegression())
])
pipe.fit(X_train, y_train)
pipe.score(X_test, y_test)
```

**Type 5 — Group Leakage**
Multiple samples from the same entity (patient, user, device) appear in both train and test sets.
Use `GroupKFold` or `GroupShuffleSplit` to keep groups intact.

### Leakage Detection Checklist
- [ ] Does any feature have suspiciously high correlation with the target? (investigate immediately)
- [ ] Were any transformations fit before splitting?
- [ ] Are there time-ordered features where future values could appear in past rows?
- [ ] Do related samples (same ID, session, entity) span both splits?
- [ ] Is validation accuracy suspiciously higher than expected for the domain?

---

## 3. Evaluation Bias and Metric Selection

### Choosing the Right Metric
The metric must align with the real-world cost function, not default convenience.

| Problem | Avoid | Use instead |
|---------|-------|-------------|
| Class imbalance | Accuracy | F1, PR-AUC, MCC |
| Asymmetric costs | Accuracy | Cost-weighted metrics, recall@precision |
| Ranking | Accuracy | NDCG, MAP, AUC-ROC |
| Regression with outliers | RMSE | MAE, Huber loss, quantile loss |
| Calibration matters | AUC-ROC | Brier score, ECE |

### Multiple Comparisons Problem
Testing 20 models on the same test set means you should expect ~1 to appear significant by chance
on average (p=0.05 threshold), and the probability that at least one does is ~64%.
- Pre-register the primary metric and primary model before running experiments.
- Apply **Bonferroni correction** or **Benjamini-Hochberg** when comparing multiple models.
- Report effect sizes, not just p-values.

### Statistical Significance of Results
A model that scores 0.82 vs 0.81 on a single test set may not be meaningfully better.
Use **McNemar's test** (classification) or **Wilcoxon signed-rank test** (regression) to compare models
on the same examples. Report **confidence intervals**, not point estimates.

```python
from scipy.stats import wilcoxon
# Compare per-sample errors, not aggregate metrics
stat, p = wilcoxon(errors_model_a, errors_model_b)
```

---

## 4. Cross-Validation — When and How

### When to Use CV
- Small datasets where a single split wastes data.
- Estimating generalization variance.
- Comparing algorithms on a fixed dataset.

### CV Variants

```
Standard K-Fold        ─ random shuffle, equal folds (not for time-series)
Stratified K-Fold      ─ preserves class proportions (classification default)
Group K-Fold           ─ keeps entity groups together
Time-Series Split      ─ expanding or sliding window; never shuffle
Nested CV              ─ outer CV evaluates, inner CV tunes (gold standard)
```

### Nested Cross-Validation (Gold Standard for Model Selection)
Avoids selection bias when tuning hyperparameters:
```
Outer loop  → unbiased performance estimate  (5 folds)
  Inner loop  → hyperparameter search        (3 folds)
```

```python
from sklearn.model_selection import GridSearchCV, cross_val_score, StratifiedKFold

inner_cv = StratifiedKFold(n_splits=3, shuffle=True, random_state=42)
outer_cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)

# Inner: model selection
search = GridSearchCV(estimator, param_grid, cv=inner_cv)

# Outer: performance estimation
scores = cross_val_score(search, X, y, cv=outer_cv, scoring="f1_macro")
```

---

## 5. Overfitting — Diagnosis and Prevention

### The Bias–Variance Tradeoff
| Symptom | Diagnosis | Intervention |
|---------|-----------|--------------|
| High train error, high val error | Underfitting (bias) | More capacity, better features |
| Low train error, high val error | Overfitting (variance) | Regularize, more data, simplify |
| Low train error, low val error, high test error | Leakage or distribution shift | Audit pipeline |

### Learning Curves as Diagnostic Tools
Always plot learning curves before drawing conclusions:
```python
import numpy as np
from sklearn.model_selection import learning_curve
train_sizes, train_scores, val_scores = learning_curve(
    estimator, X_train, y_train, cv=5,
    train_sizes=np.linspace(0.1, 1.0, 10)
)
```
- **Converging curves with small gap** → good generalization.
- **Large persistent gap** → overfitting.
- **Both curves plateau low** → underfitting.

---

## 6. Reproducibility Requirements

Every experiment must be reproducible. This is non-negotiable in scientific work. The seeding
below is necessary but not sufficient on its own: bit-for-bit reproducibility also requires the
same hardware, drivers, and pinned library versions (see Environment Pinning), and
`PYTHONHASHSEED` set in the launcher rather than in-process.

```python
import random, os, numpy as np, torch

SEED = 42

random.seed(SEED)
np.random.seed(SEED)
torch.manual_seed(SEED)
torch.cuda.manual_seed_all(SEED)
# PYTHONHASHSEED must be set BEFORE the interpreter starts; setting os.environ
# here does NOT affect the already-running process. Launch with:
#   PYTHONHASHSEED=42 python train.py
assert os.environ.get("PYTHONHASHSEED") == str(SEED), \
    "Set PYTHONHASHSEED in the launcher: PYTHONHASHSEED=42 python train.py"

# Full GPU determinism (slower, but required for reproducible claims)
torch.use_deterministic_algorithms(True, warn_only=False)
torch.backends.cudnn.deterministic = True
torch.backends.cudnn.benchmark = False
os.environ["CUBLAS_WORKSPACE_CONFIG"] = ":4096:8"

# DataLoader workers need their own seeded RNG
def seed_worker(worker_id):
    worker_seed = torch.initial_seed() % 2**32
    np.random.seed(worker_seed)
    random.seed(worker_seed)

g = torch.Generator(); g.manual_seed(SEED)
# DataLoader(..., worker_init_fn=seed_worker, generator=g)
```

### Multiple Seeds (Mandatory for Reporting)
A single seed reports luck, not signal. Run **at least 5 seeds** (preferably 10) and report
`mean ± std` (or 95% CI). Use a fixed, pre-registered seed list — never select seeds post-hoc.

### Environment Pinning
Lock the full stack, not just Python packages:
- Python + library versions (`pyproject.toml` + lock file, or `environment.yml`)
- CUDA, cuDNN, GPU driver versions
- Hardware (GPU model — kernel implementations differ across architectures)
- OS / container image (Docker or Apptainer recommended)

### Experiment Tracking (Mandatory for Non-Trivial Work)
Use MLflow, Weights & Biases, or DVC to log:
- All hyperparameters AND the search budget (configs tried, total compute)
- Dataset version + hash, preprocessing version
- Full environment (see above)
- All metrics on all splits, all seeds
- Model artifacts + training curves
- Wall-clock time, GPU-hours, energy/CO₂ if reported

Without a log, you cannot reproduce, audit, or publish your findings.

---

## 7. External Validation and Distribution Shift

Internal validation (CV + held-out test) is **necessary but not sufficient** for Q1 claims.
Reviewers expect evidence that the model generalizes beyond the development distribution.

### Levels of Validation
| Level | What it tests | Example |
|---|---|---|
| **Internal** (random split / CV) | Generalization within the same distribution | k-fold on a single cohort |
| **Temporal** | Generalization to future data | Train on 2018–2022, test on 2023–2024 |
| **Geographic / multi-site** | Generalization across sites/labs/devices | Train at hospitals A–C, test at D–E |
| **External cohort** | Generalization to an independent dataset | Train on UK Biobank, test on All of Us |

For TRIPOD+AI / CLAIM / STARD-AI compliance, **at least one form of non-random validation is
expected**. State explicitly which level your results support.

### Types of Distribution Shift
| Type | Description | Detection |
|------|-------------|-----------|
| **Covariate shift** | P(X) changes, P(Y\|X) stable | Compare feature histograms, MMD, classifier two-sample test |
| **Label shift** | P(Y) changes, P(X\|Y) stable | Compare target distributions |
| **Concept drift** | P(Y\|X) changes over time | Monitor performance over time |
| **Batch / site effects** | Technical artifacts (scanner, sequencer, lab) | Per-site performance, harmonization (ComBat) |

### Confounders, Shortcut Learning & Negative Controls
Scientific ML claims require ruling out spurious correlations:
- **Confounder audit**: list every variable that could correlate with both the target and the features.
  Stratify or adjust for them; report per-stratum performance.
- **Shortcut detection**: if the model can solve the task using a non-causal proxy (image acquisition
  parameters, metadata, hospital-specific tokens), flag it.
- **Negative controls**: predict a target the model should *not* be able to predict from the
  legitimate features (e.g., acquisition site from "clinical" features). Strong signal here = leakage.
- **Train-serving skew**: features used in training must be computable identically at inference time.

---

## 8. Uncertainty, Calibration & Interpretability

Point predictions without uncertainty are rarely acceptable in Q1 scientific work.

### Calibration (Probabilistic Predictions)
A model that outputs 0.9 should be right 90% of the time. Required reporting:
- **Reliability diagram** (predicted vs observed frequency, per bin)
- **Expected Calibration Error (ECE)** or Maximum Calibration Error
- **Brier score** for binary/multiclass probabilistic forecasts
- If miscalibrated, apply **Platt scaling** or **isotonic regression** fit on a held-out
  calibration set (not the test set)

### Predictive Intervals & Conformal Prediction
For regression and risk prediction, report **prediction intervals**, not just point estimates.
**Conformal prediction** (split-conformal or CV+) gives distribution-free coverage guarantees
under exchangeability — strong fit for Q1 scientific reporting.

```python
from mapie.regression import CrossConformalRegressor
mapie = CrossConformalRegressor(estimator, confidence_level=0.95, method="plus", cv=5)
mapie.fit_conformalize(X_train, y_train)
y_pred, y_pis = mapie.predict_interval(X_test)  # 95% intervals
```

### Epistemic vs Aleatoric Uncertainty
- **Aleatoric** (data noise): irreducible — quantify with the predictive distribution.
- **Epistemic** (model ignorance): reducible — quantify with ensembles, MC dropout, or Bayesian NNs.

Distinguishing the two matters for active learning, out-of-distribution detection, and
clinical decision support.

### Interpretability & Ablations
Q1 scientific journals expect mechanistic understanding, not just performance:
- **Feature importance**: SHAP values, permutation importance (not raw tree importances —
  they are biased toward high-cardinality features)
- **Ablation studies**: remove one component at a time (architecture block, feature group,
  data source) and report the marginal contribution
- **Sensitivity analysis**: vary hyperparameters and inputs, report stability of conclusions
- **Subgroup analysis**: report performance across demographic / clinical / experimental
  subgroups (mandatory for medical AI under MI-CLAIM, TRIPOD+AI)

See `references/scientific-reporting.md` for full publication-grade reporting protocols.

---

## 9. Pre-Registration Checklist

Before running any experiment, commit to writing:

```markdown
## Experiment Pre-Registration

**Date**: YYYY-MM-DD
**Platform / DOI**: [OSF, AsPredicted, or internal lab notebook with hash]
**Hypothesis**: [specific, falsifiable claim]
**Primary metric**: [one metric, defined precisely]
**Secondary metrics**: [calibration (ECE/Brier), uncertainty coverage, fairness across subgroups]
**Dataset**: [hash or version identifier, source, license, IRB if applicable]
**Splitting strategy**: [random / stratified / group / temporal / spatial / scaffold]
**Validation scope**: [internal only / temporal / multi-site / external cohort]
**Model architecture / algorithm**: [locked before test set access]
**Baseline(s)**: [strong, published baselines — cite them]
**Hyperparameter search budget**: [max configs, max compute, search method]
**Seeds**: [pre-committed list of N≥5 seeds]
**Minimum effect size to claim improvement**: [e.g., +1.5% F1, Cohen's d ≥ 0.2]
**Statistical test**: [McNemar / Wilcoxon / Friedman+Nemenyi / paired bootstrap]
**Multiple comparisons correction**: [Bonferroni / Benjamini-Hochberg]
**Sample size / power analysis**: [target N for desired power]
**Conditions for rejecting hypothesis**: [stated upfront]
**Reporting standard**: [TRIPOD+AI / CLAIM / STARD-AI / CONSORT-AI / none]
**Data & code availability plan**: [Zenodo DOI, GitHub, license]
```

---

## 10. Common Anti-Patterns (Bad Science Catalog)

| Anti-Pattern | Why It's Bad | Fix |
|---|---|---|
| HARKing (Hypothesizing After Results are Known) | Inflates false discovery rate | Pre-register before running |
| Multiple test set evaluations | Optimistic bias compounds | Evaluate test set once, at the end |
| Cherry-picking metrics post-hoc | Always find something that looks good | Commit to primary metric upfront |
| Reporting best run of many | Ignores variance and luck | Report mean ± std over ≥5 pre-committed seeds |
| Single-seed results | Confounds signal with luck | Always report multiple seeds + CI |
| No external validation | Internal CV overestimates generalization | Validate on independent cohort, site, or time period |
| No calibration reporting | Probabilistic outputs may be useless | Report ECE / Brier + reliability diagram |
| Point predictions only | Hides model uncertainty | Report CIs / prediction intervals / conformal coverage |
| Random splits on grouped or temporal data | Trivial group/time leakage | Use Group/Time/Spatial/Scaffold splits |
| Ignoring compute/inference cost | Not a scientific error, but a practical one | Report latency, FLOPS, GPU-hours, CO₂ |
| Comparing to weak baselines | Makes results look better than they are | Include strong, published, properly tuned baselines |
| No ablation studies | Can't attribute what drives improvement | Remove one component at a time |
| No subgroup analysis | Hides disparate performance | Report metrics per demographic / clinical stratum |
| No confounder / shortcut audit | Spurious correlations masquerade as signal | Run negative controls; adjust for confounders |
| Undisclosed HP search budget | "Best of 500 trials" hides selection bias | Report total configs tried + selection criterion |
| No data/code release plan | Unreproducible by definition | Pre-commit to Zenodo DOI + GitHub + license |

---

## 11. Reference Files

For deep dives, read the reference files:

- `references/splitting-strategies.md` — Time-series, stratified, group, spatial, scaffold, genomic splits
- `references/statistical-testing.md` — Model-comparison tests, confidence intervals, effect sizes, power
- `references/leakage-audit.md` — Step-by-step pipeline audit procedure
- `references/scientific-reporting.md` — TRIPOD+AI / CLAIM / STARD-AI compliance, calibration, conformal,
  model & dataset cards, FAIR data/code, publication-ready checklist for Q1 submission

---

## Quick Reference Card

```
BEFORE you split:     Pre-register hypothesis, primary metric, baselines, seeds, HP budget.
WHEN you split:       Stratify, group, time-order, spatially-block, or scaffold as appropriate.
AFTER you split:      Fit ALL preprocessing ONLY on training data (inside a Pipeline).
DURING training:      Tune on validation set only; log every run + full environment.
AT THE END:           Touch the test set exactly once.
BEYOND THE TEST SET:  Validate externally (temporal / multi-site / independent cohort).
WHEN REPORTING:       Multi-seed mean ± CI, calibration (ECE/Brier), prediction intervals,
                      subgroup analysis, ablations, statistical tests with MC correction,
                      strong baselines, FAIR code/data DOI, reporting-standard compliance
                      (TRIPOD+AI / CLAIM / STARD-AI / CONSORT-AI as applicable).
```
