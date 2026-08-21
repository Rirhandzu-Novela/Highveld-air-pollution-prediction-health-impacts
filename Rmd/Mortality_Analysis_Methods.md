# Mortality and Air Pollution: Statistical and Machine Learning Analysis

## 1. Introduction

This document describes the analytical framework used to assess the short-term associations between ambient air pollutant concentrations and daily mortality counts in the Gert Sibande and Nkangala districts of Mpumalanga, South Africa. The study area is characterised by dense coal-fired power generation, petrochemical production, and mining activity, resulting in complex multi-pollutant exposures.

Daily time-series data comprising air pollutant concentrations (PM2.5, PM10, SO2, NO2), meteorological variables (temperature, relative humidity), and all-cause cardiovascular and pulmonary mortality counts were analysed using two complementary approaches:

1. **Constrained Distributed Lag Models (DLM)** within a quasipoisson time-series regression framework — the standard epidemiological approach for air pollution mortality studies.
2. **Long Short-Term Memory (LSTM) neural networks** — a machine learning approach used to derive perturbation-based effect estimates for comparison with the DLM results.

Model specifications for the DLM were selected through a systematic QAIC-based model selection procedure (`Test.R`), with selected parameters carried forward into the main analysis (`Associations.R`) and sensitivity analysis (`Sensitivity.R`).

---

## 2. Methodology

### 2.1 Data and Outcome

The outcome variable was daily mortality count ($Y_t$), modelled as a count process. Exposure variables included PM2.5, PM10, SO2, and NO2 at lags 0–14 days. Meteorological confounders included temperature (as decile strata) and relative humidity.

---

### 2.2 Quasipoisson Time-Series Regression

Daily mortality was modelled using a **generalised linear model with quasipoisson family**:

$$\log(\mu_t) = \alpha + \beta \cdot \text{CB}_{x,t} + \gamma \cdot \text{CB}_{\text{temp},t} + \delta \cdot \text{spl}(t)$$

where:
- $\mu_t = E[Y_t]$ is the expected daily death count
- $\text{CB}_{x,t}$ is the cross-basis matrix for pollutant $x$ at time $t$
- $\text{CB}_{\text{temp},t}$ is the cross-basis for temperature (lag 0–14, strata by decile)
- $\text{spl}(t)$ is a cubic B-spline in time controlling for seasonality and long-term trend
- The quasipoisson family accounts for **overdispersion** in daily death counts by scaling standard errors via the dispersion parameter $\hat\phi$

---

### 2.3 Constrained Distributed Lag Model (DLM)

The cross-basis for each pollutant was constructed using the `dlnm` package (Gasparrini, 2011):

$$\text{CB}_{x,t} = \text{crossbasis}(x_t, \text{lag}=[0,14], \text{argvar}=\text{lin}, \text{arglag}=\text{ns}(df=2))$$

- **Exposure dimension** (`argvar`): linear — appropriate for air pollutants where a linear concentration-response relationship is assumed at the population level.
- **Lag dimension** (`arglag`): natural spline with **df=2** — constrains the lag-response curve to be smooth, reducing the 15 per-lag parameters to 2, which improves stability and reduces overfitting.
- **Lag window**: 0–14 days — captures both immediate and delayed effects of air pollution on mortality.

Effect estimates are reported as **Relative Risk (RR)** per 10 µg/m³ increase in pollutant concentration, along with cumulative RR summed over the full lag 0–14 window:

$$\text{RR}_{\text{lag}=l} = \exp(\hat\beta_l \cdot 10)$$

$$\text{cumRR} = \exp\left(\sum_{l=0}^{14} \hat\beta_l \cdot 10\right)$$

95% confidence intervals are derived from the quasipoisson model, with standard errors scaled by $\sqrt{\hat\phi}$.

---

### 2.4 Model Selection: `Test.R`

Model hyperparameters — the seasonal spline degrees of freedom (`seas_df`) and lag spline degrees of freedom (`lag_df`) — were selected using the **Quasi-Akaike Information Criterion (QAIC)** (Burnham & Anderson, 2002), defined as:

$$\text{QAIC} = \frac{-2\ell_{\text{Poisson}}}{\hat\phi} + 2k$$

where:
- $\ell_{\text{Poisson}}$ is the log-likelihood from an equivalent Poisson model
- $\hat\phi$ is the estimated dispersion from the quasipoisson model
- $k$ is the number of estimated parameters

The Poisson log-likelihood is used because quasipoisson models do not have a proper likelihood, and dividing by $\hat\phi$ adjusts for overdispersion. This formulation follows Burnham & Anderson (2002) and is implemented by fitting parallel Poisson and quasipoisson models on the same predictors.

#### Stage 1: Seasonal spline df selection

Three seasonal spline specifications were compared with lag_df fixed at 3:

| Seasonal df | QAIC |
|---|---|
| 50 | 14,341 |
| 70 | 14,433 |
| 90 | 14,551 |

**Selected: `seas_df = 50`** — lowest QAIC, most parsimonious seasonal control while remaining flexible enough to capture irregular industrial-season patterns. The cumulative RR was stable across all three specifications (RR ≈ 1.01–1.03), confirming the choice is not influential on the main result.

#### Stage 2: Lag spline df selection

Four lag spline specifications were compared with `seas_df` fixed at 50:

| Lag df | QAIC |
|---|---|
| 2 | 14,341.0 |
| 3 | 14,340.7 |
| 4 | 14,339.5 |
| 5 | 14,339.1 |

The QAIC range across lag df = 2–5 was **< 2 units**, which by convention indicates no meaningful difference in fit (Burnham & Anderson, 2002). **`lag_df = 2`** was selected on **parsimony grounds** — it uses fewer parameters while producing identical cumulative RR estimates across all specifications (RR ≈ 1.011 for all lag df).

#### Selected specification (carried into `Associations.R`):

```r
crossbasis(pollutant, lag = c(0,14),
           argvar = list(fun = "lin"),
           arglag = list(fun = "ns", df = 2))

spl <- bs(data$time, degree = 3, df = 50)
```

#### Residual diagnostics (final model)

- **ACF**: All lags within significance bands
- **PACF**: All partial autocorrelations < ±0.03
- **Box-Ljung test**: X² = 36.01, df = 30, **p = 0.208** — no evidence of residual serial autocorrelation

---

### 2.5 Main Analysis: `Associations.R`

The selected model specification (`lag_df=2`, `seas_df=50`, spline seasonal control) was applied systematically across all pollutant combinations:

- **Single-pollutant models**: PM2.5, PM10, SO2, NO2
- **Two-pollutant models**: all pairwise combinations
- **Three-pollutant models**: PM2.5+SO2+NO2, PM10+SO2+NO2, and permutations

For each pollutant in each model configuration, per-lag RR and cumulative RR (with 95% CI) were extracted via `crosspred(..., at=10, cumul=TRUE)` and exported to CSV files for further analysis.

#### 2.5.1 Attributable Burden Estimation

Following the constrained DLM for each single-pollutant model, the **attributable number (AN)** and **attributable fraction (AF)** of deaths were computed using `attrdl()` from the `dlnm` package. The following code was applied to the PM2.5 single-pollutant model (`model8`) at line 523 of `Associations.R`:

```r
an_pm2  <- attrdl(data$pm2.5, cbpm2constr, model8,
                  type="an", dir="forw", lag=c(0,14), tot=TRUE, cen=0)

af_pm2  <- attrdl(data$pm2.5, cbpm2constr, model8,
                  type="af", dir="forw", lag=c(0,14), tot=TRUE, cen=0)

af_sim  <- attrdl(data$pm2.5, cbpm2constr, model8,
                  type="af", dir="forw", lag=c(0,14),
                  tot=TRUE, cen=0, sim=TRUE, nsim=1000)

cat("Attributable deaths (PM2.5):", round(an_pm2), "\n")
cat("Attributable fraction (PM2.5):", round(af_pm2*100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim, 0.025)*100, 2), "% –",
             round(quantile(af_sim, 0.975)*100, 2), "%\n")
```

**Argument definitions:**

| Argument | Value | Meaning |
|---|---|---|
| `type="an"` | attributable number | total deaths attributable to PM2.5 above counterfactual |
| `type="af"` | attributable fraction | proportion of total deaths attributable to PM2.5 |
| `dir="forw"` | forward | uses observed exposure history at each time point |
| `lag=c(0,14)` | lag window | cumulates effects over the full 14-day lag window |
| `tot=TRUE` | total | sums attributable burden across all days in the dataset |
| `cen=0` | counterfactual | reference level (zero exposure); alternatively `min(data$pm2.5)` |
| `sim=TRUE, nsim=1000` | simulation | Monte Carlo CIs drawn from model covariance matrix |

**Interpretation of `lag=c(0,14)` with `tot=TRUE`:**

On any given day $t$, the observed death count is partly attributable to PM2.5 on day $t$ (lag 0), day $t-1$ (lag 1), through to day $t-14$ (lag 14). The `attrdl()` function uses the cross-basis structure to attribute each lagged contribution to its **exposure day**, summing across the entire study period without double-counting:

$$AN = \sum_{t} \sum_{l=0}^{14} \left(\hat\mu_t - \hat\mu_t^{(0)}\right)_l$$

$$AF = \frac{AN}{\sum_t Y_t}$$

where $\hat\mu_t^{(0)}$ is the predicted count under counterfactual exposure (`cen=0`).

The 95% CI is obtained by Monte Carlo simulation from the multivariate normal distribution of the model coefficients, yielding `nsim=1000` replicate AF estimates, with the 2.5th and 97.5th percentiles as the interval bounds.

The result is interpreted as: *"X deaths (Y%; 95% CI: A%–B%) were attributable to short-term PM2.5 exposure, considering effects within a 14-day lag window, over the study period."*

---

### 2.6 Sensitivity Analysis: `Sensitivity.R`

The sensitivity analysis examines the robustness of the cumulative PM2.5 RR estimate to alternative model specifications, independently validating the model selection results from `Test.R`.

#### Sensitivity 1: Varying seasonal spline df and lag spline df simultaneously

A grid search over `lag_df` ∈ {2, 3, 4, 5} × `seas_df` ∈ {50, 70, 90} (12 models total) was conducted. QAIC was computed as:

$$\text{QAIC} = \frac{D(m)}{\hat\phi} + 2k$$

where $D(m)$ is the residual deviance of the quasipoisson model. For Poisson-family GLMs, $D = -2\ell$, making this equivalent to the formulation in `Test.R`.

**Finding**: Across all 12 specifications, the cumulative RR clustered tightly around 1.01–1.02, confirming robustness of the main result.

#### Sensitivity 2: Fourier seasonal control

Fourier harmonic terms (4 sine-cosine pairs, period = 365.25 days) were used as an alternative seasonal control with `lag_df` ∈ {2, 3, 4, 5}. QAIC was again minimised at `lag_df=2`.

**Note**: The sensitivity table (from `Test.R`) revealed that the Fourier-based model yielded a substantially higher and statistically significant cumulative RR (≈ 1.17) compared to all spline-based specifications (≈ 1.01–1.03). This is attributable to **residual seasonal confounding** — Fourier terms with 4 harmonics can only capture smooth symmetric annual cycles, and are insufficient for the irregular seasonal pollution patterns characteristic of an industrial study area. This finding reinforces the use of the B-spline as the primary seasonal control.

---

### 2.7 LSTM Perturbation Analysis: `RR-CI-Prediction-LSTM.py`

To complement the epidemiological analysis, a **Long Short-Term Memory (LSTM) neural network** was trained to predict daily mortality counts and used to derive perturbation-based effect estimates across all four pollutants for comparison with the DLM results.

#### Architecture

A two-layer stacked LSTM:

| Layer | Units | Dropout |
|---|---|---|
| LSTM (return sequences) | 64 | 0.2 |
| LSTM | 32 | 0.2 |
| Dense (ReLU) | 16 | — |
| Dense (output) | 1 | — |

Trained with Adam optimiser (learning rate = 0.001), MSE loss, **50 epochs**, batch size = 32. Training and validation loss curves are inspected to confirm convergence before proceeding to PMR estimation.

#### Features

Lagged versions (lag 0–14) of: PM2.5, PM10, SO2, NO2, temperature, relative humidity — producing 90 input features (6 variables × 15 lags). Pollutant ranges were captured from raw data **before** Min-Max scaling, so that perturbations can be expressed in the original µg/m³ units. Data were split 80/20 (train/test) preserving temporal order.

#### Prediction performance gate

Before computing any PMR, the model's predictive accuracy on the held-out test set is reported:

$$\text{MAE} = \frac{1}{n}\sum_t |y_t - \hat{y}_t|, \quad \text{RMSE} = \sqrt{\frac{1}{n}\sum_t (y_t - \hat{y}_t)^2}, \quad R^2 = 1 - \frac{\sum_t(y_t-\hat{y}_t)^2}{\sum_t(y_t-\bar{y})^2}$$

PMR estimates are only interpreted if the model achieves adequate predictive performance ($R^2 \geq 0.3$). A low $R^2$ indicates the LSTM has not learned a meaningful mapping from exposures to mortality, rendering perturbation ratios uninformative.

#### Perturbation-based Predicted Mortality Ratio (PMR) estimation

PMR is estimated for **all four pollutants** (PM2.5, PM10, SO2, NO2) at each lag $l \in \{0, 1, \ldots, 14\}$. For each pollutant $p$ and lag $l$, the concentration at that lag was **decreased by 10 µg/m³** — representing a policy-relevant pollution reduction scenario. The reduction is converted to scaled units as:

$$\delta_p = \frac{10}{\max(x_p) - \min(x_p)}$$

where $\max$ and $\min$ are computed on the raw (unscaled) data before normalisation. The LSTM predicts mortality under baseline ($\hat{y}_{\text{base}}$) and reduced-pollution ($\hat{y}_{\text{dec}}$) conditions, and the **Predicted Mortality Ratio (PMR)** is:

$$\widehat{\text{PMR}}_{p,l} = \frac{\bar{\hat{y}}_{\text{dec},p,l}}{\bar{\hat{y}}_{\text{base}}}$$

A PMR < 1 indicates that reducing pollution by 10 µg/m³ at lag $l$ is associated with fewer predicted deaths — directly analogous to the policy question of what mortality reduction could be achieved through emission controls. This framing is more justifiable in an epidemiological and public health context than an increase scenario, as it aligns with the direction of feasible intervention.

#### Bootstrapped confidence intervals

Uncertainty was quantified using **1000 bootstrap resamples** with replacement drawn from the **full dataset** (train + test combined). Bootstrapping over the test set alone (~200–400 days with small daily death counts) produces wide and unstable CIs; using the full time series provides approximately 5× more observations while preserving the ratio direction. For each resample $b$:

$$\text{PMR}^{(b)}_{p,l} = \frac{\bar{\hat{y}}^{(b)}_{\text{dec},p,l}}{\bar{\hat{y}}^{(b)}_{\text{base}}}$$

$$\text{CI}_{95\%} = \left[\text{percentile}_{2.5}\left(\text{PMR}^{(b)}_{p,l}\right),\ \text{percentile}_{97.5}\left(\text{PMR}^{(b)}_{p,l}\right)\right]$$

Results for all pollutants and lags are exported to `lstm_pmr_all_pollutants.csv` and visualised as a 2×2 panel plot with 95% CI ribbons.

#### Interpretation note

The LSTM-derived PMR represents the **predicted relative change in mortality** associated with a 10 µg/m³ reduction in pollutant concentration at a given lag — rather than an epidemiological relative risk in the classical sense. A PMR < 1 is consistent with a protective effect of pollution reduction. Unlike the DLM RR, the PMR does not arise from a probabilistic model with explicit distributional assumptions or formal confounder adjustment; it reflects what the LSTM has learned from the training data. These estimates are presented as a **complementary machine learning analysis** alongside the DLM results, not as an alternative causal estimate.

---

### 2.8 Mortality Prediction Models: `Morta-Prediction-LSTM.ipynb` and `Morta-Prediction-CNN.ipynb`

Two separate deep-learning models were trained to **directly predict daily mortality counts** from lagged pollution and meteorological exposures. These notebooks constitute the *mortality prediction* chapter of the thesis, distinct from the perturbation-based PMR analysis in Section 2.7.

#### Lookback window

Both models use a **14-day lookback window** (`n_steps = 14`), matching the lag window of the DLM. Each input sample is a matrix of shape (14 time steps × number of features), constructed via a rolling `create_sequences()` function. The target is the mortality count on the day immediately following the window.

#### Feature scaling

Features and the target variable are scaled **separately** using `MinMaxScaler(feature_range=(0,1))`. The target scaler (`scaler_target`) is retained for inverse-transforming predictions back to the original death-count scale for evaluation and plotting.

#### LSTM architecture (`Morta-Prediction-LSTM.ipynb`)

| Layer | Units / Config |
|---|---|
| LSTM | 50 units, `return_sequences=False` |
| Dense | 50 units, ReLU |
| Dense | 50 units, ReLU |
| Dense (output) | 1 unit |

#### CNN architecture (`Morta-Prediction-CNN.ipynb`)

| Layer | Config |
|---|---|
| Conv1D | 32 filters, kernel size 3, ReLU |
| MaxPooling1D | pool size 2 |
| Flatten | — |
| Dense | 50 units, ReLU |
| Dense (output) | 1 unit |

Both models are compiled with the Adam optimiser and MSE loss, trained for 30 epochs (batch size 32) with a held-out validation set (20% of data, temporal split).

#### Training convergence

After `model.fit()`, training and validation loss curves are plotted by epoch to confirm that the model has converged and that overfitting is not severe.

#### Evaluation metrics

Prediction performance is reported at the **daily** resolution as the primary metric:

$$\text{MAE} = \frac{1}{n}\sum_t |y_t - \hat{y}_t|, \quad \text{RMSE} = \sqrt{\frac{1}{n}\sum_t (y_t-\hat{y}_t)^2}, \quad R^2 = 1 - \frac{\sum_t(y_t-\hat{y}_t)^2}{\sum_t(y_t-\bar{y})^2}$$

All three metrics operate on inverse-transformed (original-scale) daily death counts. Monthly aggregated predictions are also plotted as a supplementary visual, computed by resampling daily predictions to calendar-month sums.

#### SHAP feature importance

Post-hoc explainability is provided using **`shap.DeepExplainer`**, which is native to Keras/TensorFlow deep models and substantially faster than the `KernelExplainer` approximation. SHAP values are computed on a random 100-sample subset of the test set. The 3-D SHAP array (samples × time steps × features) is flattened to 2-D for the summary plot, with features labelled `{feature}_t-{lag}` where `t-0` is the most recent day and `t-13` is the oldest in the lookback window.

#### Attention mechanism

Both notebooks include an **attention-augmented** variant of their respective architectures. An additive (Bahdanau-style) attention layer is applied over the time axis of the recurrent/convolutional output:

1. A `Dense(1, activation='tanh')` layer produces a scalar score per time step.
2. Scores are passed through `tf.nn.softmax` to yield normalised attention weights $\alpha_t$.
3. The context vector is computed as the weighted sum: $\mathbf{c} = \sum_t \alpha_t \mathbf{h}_t$.

A separate attention-extraction model (sharing all trained weights) maps the input directly to the attention weight vector, enabling visualisation of which time steps the model focused on for a given prediction.

---

### 2.9 Supplementary Multi-Pollutant Analysis: AQHI-ER Composite DLM (`Associations.R`)

To complement the primary single-pollutant DLMs, a supplementary distributed lag analysis was conducted using a continuous **Air Quality Health Index — Excess Risk (AQHI-ER)** composite as the exposure variable. This approach summarises the joint short-term mortality effect of the industrial pollution mixture in Gert Sibande District.

#### Composite construction

The AQHI-ER is computed directly from the daily-average pollutant concentrations already present in the mortality dataset, using the beta coefficients reported by Adebayo-Ojo et al. (2023) for South African conditions:

$$\text{AQHI-ER} = \sum_{p \in \mathcal{P}} 100 \cdot \left(e^{\beta_p \, C_p} - 1\right)$$

where $C_p$ is the daily concentration of pollutant $p$ and $\beta_p$ is its corresponding mortality beta coefficient:

| Pollutant | $\beta_p$ | Source |
|---|---|---|
| PM2.5 | 0.00065 | Adebayo-Ojo et al. (2023) |
| PM10  | 0.00041 | Adebayo-Ojo et al. (2023) |
| NO₂   | 0.00072 | Adebayo-Ojo et al. (2023) |
| SO₂   | 0.00059 | Adebayo-Ojo et al. (2023) |

The unit of AQHI-ER is **percentage points of total excess mortality risk**. A 1-unit increase corresponds to a 1 percentage-point increase in the combined excess risk from all four pollutants. Ozone (O₃) was excluded because ozone measurements are not reliably available for the Gert Sibande monitoring network. PM2.5 is explicitly included in the composite (unlike the original 1–10 categorical AQHI), ensuring the dominant coal-combustion fine-particle pathway is represented.

The beta coefficients are externally fixed from a published epidemiological study, preventing circularity between the composite weights and the present study's outcome data.

#### Crossbasis and model

A linear dose-response crossbasis was constructed over a 0–14 day lag window with a natural spline lag structure (df = 2), consistent with the single-pollutant crossbases:

```r
cbaqhierconstr <- crossbasis(data$aqhi_er, lag = c(0,14),
                             argvar = list(fun = "lin"),
                             arglag = list(fun = "ns", df = 2))
```

The model uses the same confounder set as the primary single-pollutant DLMs:

```r
model_aqhier <- glm(death_count ~ cbaqhierconstr + cbtempunc + spl + dow + holiday,
                    data, family = quasipoisson)
```

Effect estimates are obtained via `crosspred(..., at = 1, cumul = TRUE)`, expressing the lag-specific and cumulative RR per 1 percentage-point increase in AQHI-ER.

#### Attributable burden

Attributable deaths (AN) and attributable fraction (AF) are computed using `attrdl()` with the full 0–14 lag window, Monte Carlo CIs from 1000 simulations, and a zero-exposure counterfactual. Results are saved to `Data/GertPollPulMortAQHIERdeath_count.csv`.

---

### 2.10 Pollutant Mixture Analysis: `Pollutant_Mixture_Options.R`

To complement the primary single-pollutant and multi-pollutant DLMs, a dedicated mixture analysis was conducted using two approaches: (1) Principal Component Analysis (PCA) with source-style pollutant indices and quasi-Poisson GAM, and (2) Bayesian Kernel Machine Regression (BKMR) as an exploratory nonlinear mixture analysis. Each approach is applied under two exposure definitions, mirroring the lag structures used in `Associations.R`.

Weighted Quantile Sum (WQS) regression was considered but excluded: the `gWQS` package does not support the quasipoisson family, and Poisson-based standard errors systematically underestimate variance for overdispersed daily mortality counts, making inference unreliable for comparative purposes.

#### 2.10.1 Exposure Definitions

Two exposure windows are computed:

| Exposure | Definition | Comparable to |
|---|---|---|
| Same-day (lag 0) | Observed daily concentration | GLM models 3–7x in `Associations.R` |
| 14-day rolling mean | Right-aligned 14-day mean via `zoo::rollmean(k=14)` | Cumulative DLM window (lags 0–13) |

The rolling mean overwrites the first 13 rows with `NA`; these are dropped before analysis. For $n$ study days, the 14-day dataset has $n - 13$ observations.

#### 2.10.2 Confounders and Seasonal Control

All GAM models use the same confounders as the primary DLMs:

```r
base_covariates <- "s(time, k = 50) + dow + public_holiday + s(tapp, k = 6)"
```

- `s(time, k=50)`: penalised thin-plate regression spline for seasonality and long-term trend. The maximum basis dimension `k=50` matches the cubic B-spline `df=50` selected in `Test.R`; the effective df is determined automatically by REML penalisation and will typically be lower.
- `s(tapp, k=6)`: apparent temperature (TAPP), replacing separate raw temperature and relative humidity terms. TAPP is computed as in `Associations.R`: $\text{TAPP} = -2.653 + 0.994 \cdot T + 0.0153 \cdot T_{\text{dew}}$.
- `dow`: day-of-week factor (7 levels).
- `public_holiday`: binary public holiday indicator.

#### 2.10.3 Option 1: PCA and Source-Style Indices with Quasi-Poisson GAM

**Rationale**: Correlated industrial pollutants (PM2.5, PM10, SO2, NO2) share emission sources. PCA compresses these into orthogonal components capturing dominant variance directions, reducing collinearity and enabling joint-exposure inference.

**Standardisation**: All pollutants are standardised (zero mean, unit variance) via `prcomp(..., center=TRUE, scale.=TRUE)` before PCA. The centering and scaling parameters are stored internally in the `prcomp` object to enable consistent score computation on any subset via `predict(pca_fit, newdata=...)`.

**PC retention**: The eigenvalue > 1 rule (Kaiser criterion) is applied, capped at a maximum of 3 components:

$$n_{\text{PC}} = \max\left(2,\, \min\left(\sum_{j} \mathbb{1}[\lambda_j > 1],\, 3\right)\right)$$

Retaining 4 PCs from 4 pollutants would be a pure rotation with no dimensionality reduction; capping at 3 ensures at least one dimension is reduced. In practice, with correlated industrial pollutants, the eigenvalue rule typically yields 1–2 components. Separate PCA fits and PC counts are computed for the same-day and 14-day exposure series, as temporal smoothing concentrates variance differently.

PCA loadings and variance-explained tables are saved to `RDA/pca_loadings.csv`, `RDA/pca_loadings_14d.csv`, `RDA/pca_variance_explained.csv`, and `RDA/pca_variance_explained_14d.csv`.

**GAM model**: PC scores are used as linear predictors in a quasi-Poisson GAM:

$$\log(\mu_t) = \alpha + \sum_{j=1}^{n_{\text{PC}}} \gamma_j \cdot \text{PC}_{j,t} + f(\text{time}_t) + \text{DOW}_t + \text{Holiday}_t + g(\text{TAPP}_t)$$

fitted with REML via `mgcv::gam(..., family = quasipoisson(link="log"), method="REML")`.

Effect estimates are reported as percent change in mortality per 1 SD increase in PC score:

$$\% \Delta = (e^{\hat{\gamma}_j} - 1) \times 100$$

with 95% confidence intervals from the quasipoisson model.

**Source-style indices**: Two composite indices are constructed to reflect the dominant industrial pollution sources in Gert Sibande / Mpumalanga:

| Index | Pollutants | Source pathway |
|---|---|---|
| `coal_power_index` | SO₂ + PM10 | Direct coal combustion, fly ash, power station stack emissions |
| `fine_combustion_index` | PM2.5 + NO₂ | Combustion fine particles and oxidants; secondary aerosol formation |

Each index is computed as the row mean of the standardised constituent pollutants:

$$\text{Index}_t = \frac{1}{2} \sum_{p \in \mathcal{S}} \frac{C_{p,t} - \bar{C}_p}{\text{SD}(C_p)}$$

These labels are provisional and should be updated based on the empirical PCA loadings — if PM2.5 and SO₂ load on the same PC, the source attribution should be revised accordingly.

#### 2.10.4 Option 2: Bayesian Kernel Machine Regression (BKMR)

**Rationale**: BKMR (Bobb et al., 2015) estimates flexible nonlinear and interactive mixture effects without pre-specifying the functional form of the dose-response surface. It is used here as an exploratory/sensitivity analysis.

**Limitation**: `bkmr::kmbayes` is not a quasi-Poisson time-series count model. The outcome is log-transformed as $y_t = \log(Y_t + 0.5)$ to approximate normality, introducing a minor bias for zero or near-zero counts. BKMR results should therefore be interpreted as directional sensitivity evidence, not as primary effect estimates.

**Confounder matrix**: The linear confounder matrix $\mathbf{X}$ is constructed via `model.matrix()` with an unpenalised time spline:

```r
X <- model.matrix(
  ~ ns(time, df = 8) + dow + public_holiday + ns(tapp, df = 4),
  data = bkmr_dat
)
```

`df=8` (approximately 4 × number of study years) is used instead of `df=50` because `model.matrix()` produces unpenalised columns — using `df=50` would consume the majority of residual degrees of freedom before the mixture kernel term enters the model.

**Mixture matrix**: The four pollutants (or 14-day means) are scaled and passed as the exposure matrix $\mathbf{Z}$ to `kmbayes()`.

**MCMC settings**: `iter=25000`, `varsel=TRUE`. The minimum of 25,000 iterations is required for publication-quality convergence with four pollutants and variable selection. Each chain requires approximately 30–60 minutes; fits are saved as RDS files (`RDA/bkmr_fit_{outcome}.rds`) and reloaded for summary extraction.

**Convergence diagnostics**: Trace plots are produced for the error variance parameter (`sigsq.eps`) and the kernel scale parameters (`r`) for each pollutant. Acceptable mixing is characterised by a stationary horizontal pattern (caterpillar). Poor mixing or visible trends indicate the need for more iterations or model re-specification.

**Summaries extracted**:
- **Posterior Inclusion Probabilities (PIPs)** (`ExtractPIPs`): probability that each pollutant's kernel scale $r_j > 0$, indicating a non-zero mixture contribution. PIP > 0.5 is conventionally interpreted as evidence of a non-trivial effect.
- **Overall mixture risk** (`OverallRiskSummaries`): change in log-mortality as the joint mixture moves from the 25th to 75th percentile, with all components varying simultaneously.
- **Single-pollutant response curves** (`PredictorResponseUnivar`): marginal dose-response for each pollutant holding others fixed at their median.

#### 2.10.5 Loop Over All Outcomes

All GAM-based mixture models (PCA same-day, PCA 14-day, source indices same-day, source indices 14-day) are run over all outcomes via `purrr::map_dfr()`. Results are combined into three output CSVs:

| Output file | Contents |
|---|---|
| `RDA/pca_results_all_outcomes.csv` | PCA GAM estimates (same-day and 14-day) for all outcomes |
| `RDA/source_index_results_all_outcomes.csv` | Source index GAM estimates for all outcomes |
| `RDA/bkmr_pips_all_outcomes.csv` | BKMR PIPs for all outcomes (reads pre-saved RDS files) |

Primary outcomes are CVD and RD; secondary outcomes are sex- and age-stratified subgroups (male/female; 45–64 years; 65+ years).

---

## 3. Findings and Justification

### 3.1 Model Selection Justification

The selection of `seas_df=50` and `lag_df=2` is justified on three grounds:

1. **Statistical (QAIC)**: `seas_df=50` minimised QAIC in Stage 1 by >90 units over the next candidate. `lag_df=2` was selected on parsimony given a <2 unit QAIC range across lag df=2–5.

2. **Stability**: Cumulative RR estimates were virtually identical across all tested specifications (RR ≈ 1.01–1.03), demonstrating that the main result is not sensitive to the exact df choice.

3. **Residual diagnostics**: The final model showed no evidence of residual serial autocorrelation (Box-Ljung p=0.208), confirming adequate model specification.

### 3.2 Fourier vs. Spline

The sensitivity analysis demonstrated that Fourier seasonal control produces materially different and inflated RR estimates (≈1.17 vs ≈1.01), likely due to residual seasonal confounding in an industrial study area where pollution seasonality is irregular. The B-spline with df=50 is the preferred primary specification.

### 3.3 LSTM as Complementary Analysis

The LSTM provides a data-driven, model-agnostic perspective on the pollution–mortality relationship. The **Predicted Mortality Ratio (PMR)** is conceptually distinct from the DLM's cumulative RR — the former is a perturbation-based sensitivity measure derived from a black-box model under a simulated 10 µg/m³ pollution *reduction*, the latter is a formally adjusted epidemiological effect estimate with explicit distributional assumptions. A PMR < 1 is directionally consistent with a protective effect of pollution reduction, mirroring the DLM finding of RR > 1 for a 10 µg/m³ *increase*. PMR estimates are computed for all four pollutants (PM2.5, PM10, SO2, NO2), mirroring the multi-pollutant structure of the DLM analysis. Consistency in direction between the PMR and the DLM cumulative RR across lags 0–14 would strengthen confidence in the observed associations. Divergence would prompt further investigation into confounding structure or non-linearity not captured by the linear DLM.

### 3.4 Mortality Prediction Performance

The LSTM and CNN prediction models (Section 2.8) are evaluated on their ability to predict daily mortality counts from lagged pollution and meteorological exposures. Daily MAE, RMSE, and R² on the held-out test set provide the primary performance benchmark. Given the low signal-to-noise ratio inherent in daily mortality time series in a mid-sized industrial district, moderate R² values (0.3–0.6) are expected and do not invalidate the analysis. The convergence plots and monthly aggregation plots provide supplementary evidence that the models have learned a plausible seasonal mortality pattern rather than overfitting to noise.

### 3.5 Interpretation of the AQHI-ER Supplementary Analysis

The AQHI-ER DLM (Section 2.9) provides a single-index summary of the multi-pollutant mortality association. A statistically significant cumulative RR > 1 per 1 percentage-point increase in AQHI-ER would confirm that the combined industrial pollution mixture in Gert Sibande is associated with elevated short-term mortality risk. Because the composite weights are externally fixed (Adebayo-Ojo et al., 2023), the result is not subject to circularity with the outcome data — a key advantage over data-adaptive mixture approaches.

Reporting should include the observed range and IQR of `aqhi_er` in the study period, to contextualise what a 1-unit change represents relative to daily ambient conditions. The attributable fraction and number complement the cumulative RR by expressing the public-health burden attributable to the full pollution mixture over the study period.

Consistency between the AQHI-ER cumulative RR and the individual-pollutant DLM RRs (Sections 2.3–2.4) would strengthen the conclusion that the observed associations reflect a genuine mixture effect rather than artefacts of individual pollutant models.

---

### 3.6 Interpretation of the Mixture Analysis

The PCA/source-index GAM and BKMR analyses (Section 2.10) are supplementary to the primary single-pollutant DLMs. Their results should be interpreted as follows.

**PCA components**: A statistically significant effect of PC1 or PC2 on mortality, with a consistent direction across same-day and 14-day exposure windows, supports the conclusion that the industrial pollution mixture as a whole — rather than any single pollutant — is associated with elevated short-term mortality risk. The PCA loadings (saved to `RDA/pca_loadings.csv`) must be inspected to interpret which pollutants drive each component; the labels "coal power" and "fine combustion" are provisional and should be updated accordingly.

**Source indices**: The `coal_power_index` and `fine_combustion_index` effects provide a source-apportioned perspective on the mixture association. A significant positive effect of `coal_power_index` (SO₂ + PM10) would implicate power-station and industrial boiler emissions as the dominant mortality-relevant source pathway in Gert Sibande.

**14-day vs same-day**: If the 14-day mean exposure yields larger effect estimates than same-day, this is consistent with cumulative lagged effects captured by the DLM, and supports the biological plausibility of a delayed inflammatory response to pollution exposure.

**BKMR PIPs**: A PIP > 0.5 for a pollutant indicates that BKMR has identified a non-trivial marginal contribution to the mixture–mortality association above and beyond the other pollutants. Because BKMR uses a log-transformed outcome without quasipoisson variance correction, effect magnitudes should not be directly compared to the DLM RRs; only the directional pattern and relative PIPs across pollutants are informative.

**Convergence**: BKMR results must not be reported until trace plots confirm adequate mixing. If convergence has not been reached at `iter=25000`, the RDS fit should be discarded and re-run with `iter=50000` before extracting any summaries.

---

## References

- Gasparrini A (2011). Distributed Lag Linear and Non-Linear Models in R: The Package dlnm. *Journal of Statistical Software*, 43(8), 1–20.
- Burnham KP, Anderson DR (2002). *Model Selection and Multiinference: A Practical Information-Theoretic Approach*. 2nd ed. Springer.
- Gasparrini A, Armstrong B, Kenward MG (2010). Distributed lag non-linear models. *Statistics in Medicine*, 29(21), 2224–2234.
- Peng RD, Dominici F, Louis TA (2006). Model choice in time series studies of air pollution and mortality. *Journal of the Royal Statistical Society Series A*, 169(2), 179–203.
- Adebayo-Ojo TC, Wichmann J, Arowosegbe OO, Probst-Hensch N, Schindler C, Künzli N (2023). A New Global Air Quality Health Index Based on the WHO Air Quality Guideline Values With Application in Cape Town. *International Journal of Public Health*, 68:1606349. doi:10.3389/ijph.2023.1606349.
- Bobb JF, Valeri L, Claus Henn B, Christiani DC, Wright RO, Mazumdar M, Godleski JJ, Coull BA (2015). Bayesian kernel machine regression for estimating the health effects of multi-pollutant mixtures. *Biostatistics*, 16(3), 493–508. doi:10.1093/biostatistics/kxu058.
- Wood SN (2017). *Generalized Additive Models: An Introduction with R*. 2nd ed. Chapman and Hall/CRC.
