# Splitting Strategies Reference

## Time-Series Splits

Never shuffle time-ordered data. The past cannot know the future.

### Expanding Window (Walk-Forward)
```
Fold 1: Train [t0–t3]        → Val [t4]
Fold 2: Train [t0–t4]        → Val [t5]
Fold 3: Train [t0–t5]        → Val [t6]
```
Use when more data consistently improves the model.

### Sliding Window
```
Fold 1: Train [t0–t3]        → Val [t4]
Fold 2: Train [t1–t4]        → Val [t5]
Fold 3: Train [t2–t5]        → Val [t6]
```
Use when older data becomes irrelevant (e.g., trend changes, concept drift).

```python
from sklearn.model_selection import TimeSeriesSplit

tscv = TimeSeriesSplit(n_splits=5, gap=0)
for train_idx, val_idx in tscv.split(X):
    X_train, X_val = X[train_idx], X[val_idx]
```

The `gap` parameter removes rows between train and val to prevent leakage
when features use lagged values.

---

## Stratified Splits

### Binary and Multiclass Classification
```python
from sklearn.model_selection import StratifiedKFold, train_test_split

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, stratify=y, random_state=42
)
```

### Multi-label Classification
Stratification over multiple labels requires special handling:
```python
from iterstrat.ml_stratifiers import MultilabelStratifiedKFold
```

### Regression (Binned Stratification)
```python
from sklearn.preprocessing import KBinsDiscretizer

binner = KBinsDiscretizer(n_bins=10, encode="ordinal", strategy="quantile")
y_binned = binner.fit_transform(y.reshape(-1, 1)).ravel()

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, stratify=y_binned, random_state=42
)
```

---

## Group Splits

When multiple rows belong to the same entity (patient, user, document, session),
mixing groups across splits leaks entity-level information.

```python
from sklearn.model_selection import GroupKFold, GroupShuffleSplit

gkf = GroupKFold(n_splits=5)
for train_idx, val_idx in gkf.split(X, y, groups=patient_ids):
    pass

# For a single holdout split:
gss = GroupShuffleSplit(test_size=0.2, random_state=42)
train_idx, test_idx = next(gss.split(X, y, groups=patient_ids))
```

---

## Hierarchical / Nested Splits

When data has multiple levels (e.g., patients → hospital sites → studies),
ensure no leakage at any level. Split at the highest level first.

```
Sites: A, B, C, D, E
  Train sites: A, B, C  →  all patients from A, B, C go to training
  Test sites:  D, E     →  all patients from D, E go to test
```

This tests generalization to unseen sites, not just unseen patients.
