# Data Leakage Audit — Step-by-Step Procedure

Run this audit before trusting any ML experiment results.

---

## Step 1: Feature Audit

For every feature in the dataset, answer:

1. **Availability at inference time**: Would this value be known when making a prediction?
   - Audit by walking through the real-world use case step by step.
   - Ask: "At the moment of prediction, has this event already happened?"

2. **Derivation from the target**: Is this feature computed from or correlated with the label?
   - Compute Pearson / Spearman correlation with target. Flag |r| > 0.8 for investigation.
   - Check whether the feature name suggests post-event data (e.g., `days_until_outcome`).

3. **Temporal order**: If the data is ordered in time, do any features contain future information?
   - Sort data by timestamp. Check whether feature values at row t depend on rows t+k.

```python
import pandas as pd

def feature_target_correlations(df, target_col):
    corrs = df.drop(columns=[target_col]).corrwith(df[target_col]).abs()
    suspicious = corrs[corrs > 0.8].sort_values(ascending=False)
    print("Suspicious high correlations:")
    print(suspicious)
    return suspicious
```

---

## Step 2: Pipeline Order Audit

Trace every data transformation and verify it respects the train/test boundary.

**Checklist:**

```
[ ] Split occurs BEFORE any of the following transformations:
    [ ] Standardization / normalization (StandardScaler, MinMaxScaler)
    [ ] Imputation of missing values (mean, median, KNN imputation)
    [ ] Target encoding / mean encoding
    [ ] PCA / dimensionality reduction
    [ ] Feature selection (SelectKBest, RFE, mutual information)
    [ ] SMOTE or any oversampling technique
    [ ] Outlier removal based on statistics

[ ] All transformers are fit ONLY on training data.
[ ] All transformers are applied (not fit) to validation and test data.
[ ] Everything is wrapped in an sklearn Pipeline or equivalent.
```

SMOTE note: **Only oversample inside cross-validation folds**, never before splitting.
```python
from imblearn.pipeline import Pipeline as ImbPipeline
from imblearn.over_sampling import SMOTE
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_score, StratifiedKFold

pipe = ImbPipeline([
    ("smote", SMOTE(random_state=42)),
    ("scaler", StandardScaler()),
    ("model", RandomForestClassifier())
])
# SMOTE runs inside CV folds, not before splitting
cross_val_score(pipe, X_train, y_train, cv=StratifiedKFold(5))
```

---

## Step 3: Group Membership Audit

Identify all natural groupings in the data:

```python
# Check for entity-level ID columns
id_columns = [c for c in df.columns if any(kw in c.lower()
              for kw in ["id", "user", "patient", "device", "session", "subject"])]
print("Potential group columns:", id_columns)

# Check for group leakage: count groups that appear in both train and test
train_groups = set(df_train["patient_id"])
test_groups  = set(df_test["patient_id"])
leaked = train_groups & test_groups
print(f"Groups appearing in both splits: {len(leaked)} / {len(test_groups)}")
```

If groups overlap, resplit using `GroupShuffleSplit` or `GroupKFold`.

---

## Step 4: Sanity Check — Permutation Test

If any doubt remains about leakage, run a permutation test.
Shuffle the target labels randomly and train the model. If performance stays high,
you have leakage — a valid model cannot learn from random labels.

```python
from sklearn.model_selection import permutation_test_score

score, perm_scores, p_value = permutation_test_score(
    estimator, X_train, y_train,
    scoring="f1_macro", cv=5, n_permutations=100, random_state=42
)
print(f"Real score: {score:.3f}")
print(f"Permutation mean: {perm_scores.mean():.3f}")
print(f"p-value: {p_value:.4f}")
```

`score` is the true score on the real labels; `perm_scores` are the scores obtained after
shuffling the labels, and `p_value` is the fraction of permutations that match or beat `score`.
If `score` is close to `perm_scores.mean()` (large `p_value`), the model is not learning signal.
A `score` far above `perm_scores.mean()` with a small `p_value` confirms the model learns real
signal, but if that gap is implausibly large for the domain, suspect **leakage** (the model is
exploiting information it should not have).

---

## Step 5: Retrospective Check — Model Complexity vs. Dataset Size

A classical, low-capacity model with more parameters than training samples can memorize the
training set.

Rule of thumb (classical / low-capacity models only): `n_samples_train / n_parameters >> 10`.
This does NOT hold for modern over-parameterized deep networks, which routinely have far more
parameters than samples yet still generalize (the double-descent regime). For those, judge
overfitting from the train-vs-validation gap and learning curves, not this ratio.

For neural networks, use:
```python
n_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
ratio = len(X_train) / n_params
print(f"Samples-to-parameters ratio: {ratio:.2f}")
if ratio < 10:
    print("WARNING: High overfitting risk. Consider regularization or more data.")
```

---

## Step 6: Document Findings

After the audit, fill in:

```markdown
## Leakage Audit Report

**Date**: YYYY-MM-DD
**Dataset**: [name + version hash]
**Auditor**: [name]

### Feature Audit
- [ ] All features verified as available at inference time
- [ ] No features derived from target (or documented exceptions)
- [ ] Temporal order verified

### Pipeline Audit
- [ ] All transformers fit on training data only
- [ ] Pipeline wraps all preprocessing steps

### Group Audit
- [ ] Group columns identified: [list]
- [ ] Group leakage: None / Resolved by [method]

### Permutation Test
- Real score: X.XX
- Permutation mean: X.XX
- p-value: X.XX

### Conclusion
[Leakage-free / Leakage detected — [description] — [resolved/unresolved]]
```
