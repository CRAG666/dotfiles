---
name: ml-science-discipline
description: >
  Enforces rigorous scientific methodology for machine learning experiments to prevent data leakage,
  overfitting, evaluation bias, and other forms of bad ML science. Use this skill whenever the user is:
  designing an ML pipeline, splitting datasets, evaluating model performance, selecting features,
  tuning hyperparameters, comparing models, reporting results, or doing any task where experimental
  validity could be compromised. Trigger this skill even for seemingly simple tasks like "train a model"
  or "evaluate accuracy" — poor scientific practices often hide in routine steps. If ML, data science,
  model training, or predictive modeling is mentioned in any form, consult this skill first.
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
Testing 20 models on the same test set means ~1 will appear significant by chance (p=0.05 threshold).
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
from sklearn.model_selection import GridSearchCV, cross_val_score

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

Every experiment must be fully reproducible. This is non-negotiable in scientific work.

```python
import random, numpy as np, torch, os

SEED = 42

random.seed(SEED)
np.random.seed(SEED)
torch.manual_seed(SEED)
torch.cuda.manual_seed_all(SEED)
os.environ["PYTHONHASHSEED"] = str(SEED)

# Log all non-deterministic factors explicitly
```

### Experiment Tracking (Mandatory for Non-Trivial Work)
Use MLflow, Weights & Biases, or DVC to log:
- All hyperparameters
- Dataset version and hash
- Environment (library versions, hardware)
- All metrics on all splits
- Model artifacts

Without a log, you cannot reproduce, audit, or publish your findings.

---

## 7. Distribution Shift and Generalization

### Types of Shift
| Type | Description | Detection |
|------|-------------|-----------|
| **Covariate shift** | P(X) changes, P(Y\|X) stable | Compare feature histograms |
| **Label shift** | P(Y) changes, P(X\|Y) stable | Compare target distributions |
| **Concept drift** | P(Y\|X) changes over time | Monitor model performance over time |

### Train-Serving Skew
Validate that the features used in training are computed identically at inference time.
Any discrepancy between offline and online feature computation is a form of leakage/shift.

---

## 8. Pre-Registration Checklist

Before running any experiment, commit to writing:

```markdown
## Experiment Pre-Registration

**Date**: YYYY-MM-DD
**Hypothesis**: [specific, falsifiable claim]
**Primary metric**: [one metric, defined precisely]
**Dataset**: [hash or version identifier]
**Model architecture / algorithm**: [locked before test set access]
**Baseline**: [what you're comparing against]
**Minimum effect size to claim improvement**: [e.g., +1.5% F1]
**Statistical test to be used**: [McNemar / t-test / Wilcoxon]
**Sample size / power analysis**: [if applicable]
**Conditions for rejecting hypothesis**: [stated upfront]
```

---

## 9. Common Anti-Patterns (Bad Science Catalog)

| Anti-Pattern | Why It's Bad | Fix |
|---|---|---|
| HARKing (Hypothesizing After Results are Known) | Inflates false discovery rate | Pre-register before running |
| Multiple test set evaluations | Optimistic bias compounds | Evaluate test set once, at the end |
| Cherry-picking metrics post-hoc | Always find something that looks good | Commit to primary metric upfront |
| Reporting best run of many | Ignores variance and luck | Report mean ± std over seeds |
| Ignoring compute/inference cost | Not a scientific error, but a practical one | Report latency and FLOPS alongside accuracy |
| Comparing to weak baselines | Makes results look better than they are | Always include a strong, published baseline |
| No ablation studies | Can't attribute what drives improvement | Remove one component at a time |

---

## 10. Reference Files

For deep dives, read the reference files:

- `references/splitting-strategies.md` — Time-series splits, stratification, group splits
- `references/statistical-testing.md` — Tests for comparing models, confidence intervals, effect sizes
- `references/leakage-audit.md` — Step-by-step pipeline audit procedure

---

## Quick Reference Card

```
BEFORE you split:     Define hypothesis, metric, baseline.
WHEN you split:       Stratify, group, or time-order as appropriate.
AFTER you split:      Fit ALL preprocessing ONLY on training data.
DURING training:      Tune on validation set only.
AT THE END:           Touch the test set exactly once.
WHEN reporting:       State seeds, library versions, CI, and statistical tests.
```
