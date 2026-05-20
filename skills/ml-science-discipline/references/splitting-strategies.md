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

---

## Domain-Specific Splits

Random splits silently overestimate performance in many scientific domains because of
structural correlations the random split does not respect. Use the domain-appropriate
strategy below.

### Chemistry & Drug Discovery — Scaffold Splits
Molecules sharing a Bemis–Murcko scaffold are near-duplicates from a learning standpoint.
Random splits on molecular datasets typically overestimate generalization by 20–50%.

```python
from rdkit.Chem.Scaffolds.MurckoScaffold import MurckoScaffoldSmiles
from collections import defaultdict

scaffolds = defaultdict(list)
for i, smi in enumerate(smiles):
    s = MurckoScaffoldSmiles(smi=smi, includeChirality=False)
    scaffolds[s].append(i)

# Sort scaffolds by size and assign whole scaffolds to splits
groups_sorted = sorted(scaffolds.values(), key=len, reverse=True)
# Distribute groups to train/val/test respecting target proportions (80/10/10)
```

For temporal evaluation in drug discovery, use **time splits** based on assay date — closer
to the real-world deployment scenario than scaffold splits alone.

### Geospatial & Earth Sciences — Spatial Block CV
Nearby points are spatially autocorrelated; a random split lets the model memorize the
neighborhood. Use **spatial block cross-validation** (Roberts et al., 2017).

```python
# Conceptual outline (use blockCV in R or sklearn-compatible spacv in Python)
# 1. Tile the study area into blocks larger than the spatial autocorrelation range
# 2. Assign entire blocks to folds (random or systematic)
# 3. Optionally enforce a buffer between train and test blocks
```

Estimate the autocorrelation range from a variogram of the residuals of a naive model.

### Genomics — Chromosome Holdout & Batch-Aware Splits
- **Chromosome holdout**: hold out entire chromosomes for sequence-level tasks to avoid
  learning genomic neighborhood patterns instead of the biological signal.
- **Batch-aware splits**: keep all samples from a sequencing batch / plate / center together
  to test generalization across batch effects (use `GroupKFold` with batch IDs).
- For single-cell or bulk transcriptomics, consider **donor-level holdout** in addition to
  technical batch splits.

### Medical Imaging — Patient + Site + Scanner Splits
Leakage in medical imaging is famously easy to introduce:
- Multiple slices/series per patient → split at patient level (`GroupKFold`).
- Multiple visits over time → temporal holdout per patient.
- Multi-site studies → hold out entire sites/scanners to test acquisition generalization.

### Network / Graph Data — Edge vs Node vs Graph Splits
- **Transductive (edge split)**: leaks node features; only valid for the same graph.
- **Inductive (node holdout)**: hold out nodes and all their incident edges.
- **Graph-level**: hold out entire graphs (e.g., for molecular property prediction across
  molecules, or social network prediction across communities).

### Time-Series with Hierarchy — Combined Temporal + Group
Forecasting multiple related series (sensors, stores, patients): use **temporal split within
each group**, then aggregate. Never let any group's future leak into another group's past
via global preprocessing.

---

## Choosing the Right Split — Decision Aid

```
Is the data ordered in time and will predictions be made forward in time?
  └─ YES → TimeSeriesSplit (+ gap), or rolling-origin per group

Do multiple samples come from the same entity (patient, user, molecule scaffold, site)?
  └─ YES → GroupKFold / GroupShuffleSplit at the entity level

Are the samples spatially located and likely autocorrelated?
  └─ YES → Spatial block CV with buffer

Is the target imbalanced (classification or skewed regression)?
  └─ YES → StratifiedKFold (use binned stratification for regression)

None of the above?
  └─ Random KFold with a fixed seed
```
