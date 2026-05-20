# Statistical Testing for ML Model Comparison

## Choosing the Right Test

| Comparison | Data type | Recommended test |
|---|---|---|
| Two classifiers, same test set | Per-sample binary errors | McNemar's test |
| Two regressors, same test set | Per-sample residuals | Wilcoxon signed-rank test |
| Multiple models | Per-fold scores from CV | Friedman test + Nemenyi post-hoc |
| One model vs chance | Classification | Binomial test |
| Two proportions | Large samples | Z-test for proportions |

---

## McNemar's Test (Classification)

Tests whether two classifiers make different types of errors, not just different rates.

```python
from statsmodels.stats.contingency_tables import mcnemar
import numpy as np

# Per-sample correctness (1=correct, 0=wrong)
correct_a = (y_pred_a == y_test).astype(int)
correct_b = (y_pred_b == y_test).astype(int)

# Contingency table: [both_wrong, a_wrong_b_right, a_right_b_wrong, both_right]
n00 = ((correct_a == 0) & (correct_b == 0)).sum()
n01 = ((correct_a == 0) & (correct_b == 1)).sum()
n10 = ((correct_a == 1) & (correct_b == 0)).sum()
n11 = ((correct_a == 1) & (correct_b == 1)).sum()

table = np.array([[n00, n01], [n10, n11]])
result = mcnemar(table, exact=True)  # exact=True for small n01+n10
print(f"p-value: {result.pvalue:.4f}")
```

Interpretation: p < 0.05 means the classifiers are significantly different.
It does not tell you which is better — combine with the actual accuracy difference.

---

## Wilcoxon Signed-Rank Test (Regression / Any Paired Scores)

Non-parametric. Does not assume normally distributed errors.

```python
from scipy.stats import wilcoxon

# Per-sample absolute errors
errors_a = np.abs(y_pred_a - y_test)
errors_b = np.abs(y_pred_b - y_test)

stat, p = wilcoxon(errors_a, errors_b, alternative="less")  # "less": a < b
print(f"p-value: {p:.4f}")
```

---

## Confidence Intervals on Metrics

### Bootstrap CI (model-free, works for any metric)
```python
import numpy as np
from sklearn.metrics import f1_score

def bootstrap_ci(y_true, y_pred, metric_fn, n_bootstrap=1000, alpha=0.05, seed=42):
    rng = np.random.default_rng(seed)
    n = len(y_true)
    scores = []
    for _ in range(n_bootstrap):
        idx = rng.integers(0, n, size=n)
        scores.append(metric_fn(y_true[idx], y_pred[idx]))
    lower = np.percentile(scores, 100 * alpha / 2)
    upper = np.percentile(scores, 100 * (1 - alpha / 2))
    return np.mean(scores), lower, upper

mean, lo, hi = bootstrap_ci(y_test, y_pred, f1_score)
print(f"F1: {mean:.3f} (95% CI: [{lo:.3f}, {hi:.3f}])")
```

---

## Multiple Comparisons Correction

### Bonferroni (conservative)
Divide the target alpha by the number of comparisons:
```
If testing 10 models, use α = 0.05 / 10 = 0.005 per test.
```

### Benjamini-Hochberg (FDR control, recommended)
Controls the false discovery rate rather than the family-wise error rate.
Less conservative than Bonferroni for many tests.

```python
from statsmodels.stats.multitest import multipletests

p_values = [0.01, 0.04, 0.03, 0.20, 0.005]  # one per comparison
reject, p_corrected, _, _ = multipletests(p_values, alpha=0.05, method="fdr_bh")
```

---

## Effect Size

A statistically significant result can be practically meaningless. Always report effect size.

| Domain | Metric | Formula |
|--------|--------|---------|
| Classification | Cohen's h | `2*arcsin(sqrt(p1)) - 2*arcsin(sqrt(p2))` |
| Regression | Cohen's d | `(mean_a - mean_b) / pooled_std` |
| Rankings | Rank correlation | Spearman rho |

Cohen's d interpretation: small=0.2, medium=0.5, large=0.8.

---

## Power Analysis

Before running an experiment, determine the sample size needed to detect a meaningful effect.

```python
from statsmodels.stats.power import TTestIndPower

analysis = TTestIndPower()
n = analysis.solve_power(
    effect_size=0.5,    # medium effect (Cohen's d)
    alpha=0.05,
    power=0.80,         # 80% chance of detecting real effect
    ratio=1.0
)
print(f"Required samples per group: {int(np.ceil(n))}")
```

If your test set is too small to reach this N, your comparison results are unreliable.
