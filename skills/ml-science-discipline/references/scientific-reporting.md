# Scientific Reporting for Q1 ML Publications

This reference covers what reviewers and editors of Q1 journals expect beyond technical
correctness: standardized reporting frameworks, external validation, calibration, fairness,
transparency, and reproducibility artifacts.

---

## 1. Reporting Standards — Which One Applies

Q1 journals increasingly require compliance with a domain-specific reporting framework.
Identify the right one **before writing** — it determines what you must measure and report.

| Standard | Scope | When to use |
|---|---|---|
| **TRIPOD+AI** (Collins et al., 2024) | Prediction model development & validation | Diagnostic / prognostic models, clinical risk scores, biology prediction |
| **TRIPOD-LLM** (2024) | LLM-based prediction studies | Any clinical/scientific use of LLMs for prediction or generation |
| **CLAIM** (Mongan et al., 2020) | AI in medical imaging | Radiology, pathology, ophthalmology, dermatology |
| **STARD-AI** | Diagnostic accuracy of AI systems | Sensitivity/specificity studies for AI diagnostics |
| **CONSORT-AI** (Liu et al., 2020) | RCTs evaluating AI interventions | Prospective trials with AI in the intervention arm |
| **SPIRIT-AI** | Trial protocols involving AI | Pre-registration of clinical trials with AI |
| **MI-CLAIM** (Norgeot et al., 2020) | Minimal info for clinical AI modeling | Broader/lighter than TRIPOD+AI for clinical ML |
| **DOME** (Walsh et al., 2021) | Supervised ML in biology | Bioinformatics, omics, structural biology |
| **CONSORT / STROBE** | Non-AI baselines | Pair with one of the above when comparing to non-AI methods |
| **Model Cards** (Mitchell et al., 2019) | Any ML model release | All papers releasing a model |
| **Datasheets for Datasets** (Gebru et al., 2021) | Any dataset release | All papers releasing or curating a dataset |

State the standard in the Methods section: *"We followed the TRIPOD+AI reporting guideline
(checklist in Supplementary Material S1)."* Include the filled checklist as a supplement.

---

## 2. Validation Levels Required for Q1

Most Q1 journals will not accept internal validation alone for prediction-model papers.
Plan from the start to include at least one of:

- **Temporal validation**: train on data up to year T, test on T+1 onward.
- **Geographic / multi-site validation**: hold out entire sites, scanners, labs, or countries.
- **External cohort validation**: an independent dataset with different collection protocols.
- **Prospective validation**: collect new data after model freezing (gold standard for clinical AI).

Report performance separately for each validation level. **Do not pool external and internal
results** into a single number — the distinction is the point.

### Threshold and Operating-Point Selection
- Pre-specify how the operating threshold is chosen (Youden's J, fixed sensitivity, target PPV).
- Choose the threshold on the **validation** set, then evaluate at that fixed threshold on
  test/external. Never re-tune on the test set.

---

## 3. Uncertainty & Calibration — Required Artifacts

### Calibration
For any probabilistic output, report at minimum:
- **Reliability diagram** with predicted-vs-observed frequencies (10 bins typical).
- **Expected Calibration Error (ECE)** with bootstrap CI.
- **Brier score** (binary/multiclass) or **Brier skill score** relative to climatology.
- **Hosmer-Lemeshow** test or **calibration-in-the-large + slope** for clinical models.

If miscalibrated, apply **Platt scaling** or **isotonic regression** fit on a held-out
calibration subset (carved out of the training data, never the test set). Re-report all
calibration metrics post-calibration.

```python
from sklearn.calibration import calibration_curve
prob_true, prob_pred = calibration_curve(y_true, y_prob, n_bins=10, strategy="quantile")

# ECE
import numpy as np
def expected_calibration_error(y_true, y_prob, n_bins=10):
    bins = np.linspace(0, 1, n_bins + 1)
    ece = 0.0
    for lo, hi in zip(bins[:-1], bins[1:]):
        mask = (y_prob >= lo) & (y_prob < hi)
        if mask.sum() == 0:
            continue
        ece += (mask.sum() / len(y_true)) * abs(y_true[mask].mean() - y_prob[mask].mean())
    return ece
```

### Conformal Prediction (Distribution-Free Intervals)
For regression and risk scoring, conformal prediction provides marginal coverage guarantees
without distributional assumptions — well-aligned with Q1 standards.

```python
from mapie.classification import MapieClassifier
mapie = MapieClassifier(estimator, method="aps", cv=5)
mapie.fit(X_train, y_train)
y_pred, y_ps = mapie.predict(X_test, alpha=0.1)  # 90% coverage prediction sets
```

Report empirical coverage on the test set and conditional coverage across subgroups —
marginal coverage can hide subgroup failures.

### Decision Curve Analysis (Clinical Utility)
For medical / risk-screening applications, report **net benefit** vs threshold probability
(Vickers & Elkin, 2006). Compares the model against "treat all" and "treat none" defaults
across the clinically plausible threshold range.

---

## 4. Subgroup, Fairness & Robustness Analysis

Required by TRIPOD+AI, MI-CLAIM, and increasingly by Nature, Science, and Lancet family journals.

- **Subgroup performance**: report primary metric + CI separately for relevant strata
  (sex, age band, race/ethnicity, site, device, disease severity, sample type).
- **Disparity metrics**: subgroup AUC gap, equal opportunity difference, calibration-in-the-large
  per subgroup. Report effect sizes, not just whether they differ.
- **Robustness probes**: perturbations relevant to the deployment setting (image noise,
  rotation, missing features, sensor dropout, label noise).
- **Out-of-distribution / negative tests**: known OOD inputs should yield high uncertainty
  or be flagged.

---

## 5. Interpretability & Ablation Reporting

- **Global importance**: SHAP summary plots, permutation importance with CI.
- **Local explanations**: SHAP / LIME / counterfactuals for representative or failure cases.
- **Feature ablation**: drop each feature group; report ΔMetric with CI.
- **Component ablation**: drop architecture blocks, training objectives, augmentations.
- **Sensitivity analysis**: vary key hyperparameters ±50% and report metric stability.
- **Mechanistic plausibility**: do the discovered features / saliencies align with domain knowledge?
  Discuss disagreements explicitly.

Beware of biased importance signals (impurity-based tree importances inflate high-cardinality
features; raw attention is not explanation; saliency maps can be unreliable). State the
limitations of the interpretability method you use.

---

## 6. Multi-Seed & Hyperparameter-Budget Reporting

### Multi-Seed Protocol
- **Pre-commit a list of ≥5 seeds** (10 is preferable for Q1).
- Report `mean ± std` AND a 95% CI (bootstrap or Student-t).
- Do not report the best seed. If you do for any reason, also report the worst and median.

### Hyperparameter Search Budget
Underspecified HP search is a major reproducibility gap. Report:
- Search method (grid / random / Bayesian / Hyperband / PBT).
- Search space (full table in supplementary).
- Total configurations tried.
- Total compute used (GPU-hours + GPU type).
- Selection criterion (validation metric on which fold(s)).
- Did the baseline get the same search budget? (If not, you are not making a fair comparison.)

---

## 7. Compute, Energy & Carbon Reporting

Required or recommended by ICML, NeurIPS, ACL, Nature ML papers, and many Q1 venues.

- **Training compute**: GPU/TPU model, count, wall-clock hours, total GPU-hours.
- **Total experimental compute** including failed runs and HP search.
- **Inference cost**: latency, FLOPs, memory footprint, energy per inference.
- **CO₂ estimate** via tools like `codecarbon`, `eco2AI`, or ML CO₂ Impact calculator.

```python
from codecarbon import EmissionsTracker
with EmissionsTracker(project_name="experiment_42") as tracker:
    model.fit(X_train, y_train)
# Logs kgCO2eq based on regional grid mix
```

---

## 8. FAIR Data & Code Release

**F**indable, **A**ccessible, **I**nteroperable, **R**eusable. Most Q1 journals (Nature
family, PLOS, eLife) now require this.

### Code
- Public repository (GitHub/GitLab/Codeberg) with permanent DOI via **Zenodo** integration.
- License (MIT, Apache-2.0, BSD-3 typical; GPL if dependencies require).
- `README.md` with reproduction instructions, expected hardware, expected runtime.
- Environment lock file (`environment.yml`, `pyproject.toml` + lockfile, or Docker image).
- Tag a release matching the manuscript revision.

### Data
- Public deposition where ethically possible (Zenodo, Figshare, Dryad, domain-specific:
  GEO/SRA for genomics, PDB for structural, OpenNeuro for neuroimaging, TCIA for imaging).
- **Datasheet** (Gebru et al.): provenance, collection process, preprocessing, known biases,
  intended use, licenses, ethical review.
- If data cannot be shared (HIPAA/GDPR/IRB constraints): provide synthetic data or detailed
  data access procedures with realistic timelines.

### Models
- **Model card** (Mitchell et al.): intended use, out-of-scope uses, training data,
  evaluation data, metrics with disaggregated results, ethical considerations, caveats.
- Release weights when possible (Hugging Face Hub, Zenodo).

---

## 9. Negative Controls & Sanity Checks

Q1 reviewers look for evidence the result is real, not artifactual:
- **Permutation test**: shuffle labels — performance should collapse to chance.
- **Negative control target**: predict a label that should not be predictable from legitimate
  features (e.g., site/scanner/batch from clinical features). High accuracy here = shortcut.
- **Random feature baseline**: replace features with noise — performance should collapse.
- **Single-feature baselines**: ensure the model materially beats trivial heuristics.
- **Worst-case slice**: report performance on the worst-performing subgroup / hardest examples.

---

## 10. Statistical Reporting Norms

- Report **effect size with 95% CI** for every comparison; p-values are secondary.
- For headline comparisons, use **paired tests on the same examples** (McNemar / Wilcoxon /
  paired bootstrap), not unpaired tests on summary metrics.
- Apply **multiple-comparisons correction** (Benjamini-Hochberg for many comparisons,
  Bonferroni for few primary tests). State the correction.
- Pre-register the **primary** hypothesis and metric. Secondary/exploratory analyses must be
  labeled as such.
- Power analysis: report the minimum detectable effect at the actual sample size.

---

## 11. Pre-Registration Platforms

Time-stamped pre-registration is the strongest defense against HARKing accusations.

- **OSF Registries** (osf.io/registries) — general-purpose, free, DOI-bearing.
- **AsPredicted** (aspredicted.org) — short-form, lighter weight.
- **ClinicalTrials.gov / ISRCTN** — required for clinical AI trials.
- **arXiv/bioRxiv timestamp** of a methods preprint — secondary option.

Reference the registration DOI / ID in the manuscript Methods section.

---

## 12. Q1 Publication-Ready Checklist

Map every item to a section of the manuscript. Tick when the artifact exists, is in the
manuscript, AND is reproducible from the released materials.

### Methods
- [ ] Reporting standard declared (TRIPOD+AI / CLAIM / STARD-AI / CONSORT-AI / DOME / ...)
- [ ] Pre-registration DOI / link cited
- [ ] Data sources, sizes, inclusion/exclusion criteria, ethics approval, consent
- [ ] Splitting strategy justified for the data structure (random / stratified / group /
      temporal / spatial / scaffold)
- [ ] Preprocessing pipeline (with leakage controls explicit — fit on train only)
- [ ] Model architecture, training procedure, loss, optimizer, schedule
- [ ] Hyperparameter search space, method, total configs, total compute
- [ ] Random seeds (pre-committed list)
- [ ] Baselines: strong, published, fairly tuned with matched search budget
- [ ] Statistical tests pre-specified; multiple-comparisons correction stated
- [ ] Validation levels (internal / temporal / multi-site / external) declared

### Results
- [ ] Primary metric: mean ± 95% CI across ≥5 seeds, with paired statistical test vs baseline
- [ ] Secondary metrics including calibration (ECE, Brier, reliability diagram)
- [ ] Uncertainty: prediction intervals or conformal coverage; conditional coverage by subgroup
- [ ] Subgroup analysis on pre-specified strata (sex, age, site, severity, ...)
- [ ] External validation results, reported separately
- [ ] Ablation studies (components, features, data sources)
- [ ] Sensitivity analyses (hyperparameters, random seeds, data perturbations)
- [ ] Negative controls (permutation, shortcut, batch-prediction)
- [ ] Interpretability artifacts (SHAP / permutation importance / counterfactuals)
- [ ] Decision-curve analysis or domain-appropriate utility metric (when relevant)

### Discussion
- [ ] Failure modes and worst-performing subgroups discussed
- [ ] Distribution shift / deployment risks named
- [ ] Confounders and shortcut-learning risks named
- [ ] Mechanistic plausibility of features / explanations discussed
- [ ] Comparison to prior published baselines fair and contextualized
- [ ] Limitations explicit (sample size, geography, demographics, time period)

### Reproducibility & Transparency
- [ ] Code: public repo + Zenodo DOI, license, env lock, Docker/Apptainer image
- [ ] Data: deposited (or controlled-access procedure described); datasheet included
- [ ] Model: weights released (or rationale for not releasing); model card included
- [ ] Full HP search space and best configs in supplementary
- [ ] All seed-level results in supplementary (not only aggregates)
- [ ] Compute & CO₂ reported
- [ ] Reporting-standard checklist (TRIPOD+AI/CLAIM/...) filled and included in supplement

### Author / Process
- [ ] Author contributions (CRediT taxonomy)
- [ ] Conflicts of interest declared
- [ ] Funding and data-access agreements declared
- [ ] AI-assistance usage in writing/analysis disclosed per journal policy

---

## 13. Common Reviewer Concerns (Pre-empt Them)

Anticipate and address these in the manuscript itself, not in rebuttal:

1. **"Did you tune on the test set?"** → Cite the pre-registration; show the threshold-selection
   procedure happens on the validation fold.
2. **"How do we know this isn't a shortcut?"** → Show the negative-control / batch-prediction
   experiment.
3. **"Will this generalize beyond your cohort?"** → External validation results + distribution-
   shift analysis.
4. **"Is the improvement clinically/practically meaningful?"** → Effect size with CI + decision-
   curve analysis + minimum-detectable-effect discussion.
5. **"How sensitive is this to hyperparameters?"** → Sensitivity table; report median, not best.
6. **"How was the baseline tuned?"** → Same search budget; cite the original paper's settings;
   show learning curves indicating convergence.
7. **"Where is the data/code?"** → DOI, repo URL, license, env spec — all in the manuscript.
8. **"Why these subgroups?"** → Pre-specified strata cited from the pre-registration.
