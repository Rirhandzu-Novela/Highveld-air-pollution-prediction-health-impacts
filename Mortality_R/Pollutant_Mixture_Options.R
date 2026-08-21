################################################################################
# This script implements TWO mixture options:
#   OPTION 1: PCA / source-style pollutant indices + quasi-Poisson GAM
#   OPTION 2: BKMR exploratory mixture analysis
#
# Each option is run TWICE:
#   (a) Same-day (lag 0) concentrations  — comparable to the GLM section
#       (models 3-7x) in Associations.R
#   (b) 14-day rolling mean concentrations — approximates the DLM cumulative
#       lag window (lags 0-13) used in the constrained DLMs (models 8-10x)
#
# WQS (Weighted Quantile Sum) was excluded: gWQS does not support quasipoisson.
# Poisson-based SEs systematically underestimate variance for overdispersed
# daily mortality counts, making inference unreliable for comparative purposes.
#
# IMPORTANT:
# - BKMR is treated as exploratory/sensitivity because standard BKMR is not
#   designed as a full quasi-Poisson time-series DLNM count model.
################################################################################

############################
# 0. Load packages         #
############################
library(tidyverse)
library(lubridate)
library(mgcv)
library(splines)
library(zoo)       # rollmean() for 14-day exposure windows
library(bkmr)

set.seed(1234)

########################
# 1. Read and prepare   #
########################
dat <- read.csv("MortData/GertPollMortAllCart.csv", header = T, sep = ";")

# Clean column names into easier R names.
# pm2.5 becomes pm2_5; PublicHoliday1 becomes publicholiday1, etc.
names(dat) <- names(dat) |>
  tolower() |>
  gsub("\\.", "_", x = _) |>
  gsub("[^a-z0-9_]+", "_", x = _) |>
  gsub("_+$", "", x = _)

# Parse dates and create time variables.
dat <- dat %>%
  mutate(
    date = as.Date(date, format = "%Y/%m/%d"),
    year = year(date),
    month = month(date),
    doy = yday(date),
    time = as.numeric(date - min(date, na.rm = TRUE)) + 1,
    dow = factor(dow2),
    public_holiday = factor(publicholiday2)
  ) %>%
  arrange(date)

# Exposure variables.
pollutants <- c("pm2_5", "pm10", "so2", "no2")
met_vars <- c("temp", "relhum")

# Outcomes.
outcomes <- c(
  "rd", "rd_male", "rd_female", "rd_fiftosixtyfour", "rd_sixtyfiveplus",
  "cvd", "cvd_male", "cvd_female", "cvd_fiftosixtyfour", "cvd_sixtyfiveplus"
)

# Keep only columns that actually exist.
pollutants <- pollutants[pollutants %in% names(dat)]
met_vars <- met_vars[met_vars %in% names(dat)]
outcomes <- outcomes[outcomes %in% names(dat)]

# Convert key variables to numeric.
dat <- dat %>%
  mutate(across(all_of(c(pollutants, met_vars, outcomes)), as.numeric))

# Compute apparent temperature (TAPP) — consistent with Associations.R.
# Replaces raw temp + relHum as the thermal confounder in all models.
dat <- dat %>%
  mutate(
    svp  = 6.112 * 10^(7.5 * temp / (237.7 + temp)),
    avp  = (relhum * svp) / 100,
    dew  = (-430.22 + 237.7 * log(avp)) / (-log(avp) + 19.08),
    tapp = -2.653 + (0.994 * temp) + (0.0153 * dew)
  )

# Drop rows with missing values in variables required for models.
# tapp is included so that rows with missing temp/relhum are excluded.
model_vars <- c("date", "time", "dow", "public_holiday", pollutants, "tapp", outcomes)
dat_model <- dat %>%
  select(all_of(model_vars)) %>%
  drop_na()

# Choose one primary outcome for demonstration.
# Change this to "rd", "cvd_male", etc. as needed.
outcome_var <- "cvd"

# LAGGED EXPOSURE WINDOWS -------------------------------------------------------
# Two exposure definitions aligned with Associations.R:
#   pollutants     = same-day (lag 0) — comparable to GLM section (model3-model7x)
#   pollutants_14d = 14-day rolling mean (lags 0-13) — approximates DLM cumulative
#                   window (model8-model10x). Right-aligned: each row is the
#                   mean of the current day and the 13 preceding days.
dat_model <- dat_model %>%
  arrange(date) %>%
  mutate(across(
    all_of(pollutants),
    ~ zoo::rollmean(.x, k = 14, fill = NA, align = "right"),
    .names = "{.col}_14d"
  ))

pollutants_14d <- paste0(pollutants, "_14d")

# dat_model_14d: drops the first 13 rows where the rolling mean is NA
dat_model_14d <- dat_model %>%
  drop_na(all_of(pollutants_14d))

cat(sprintf("Same-day n = %d | 14-day n = %d (-%d rows from rolling window)\n",
    nrow(dat_model), nrow(dat_model_14d),
    nrow(dat_model) - nrow(dat_model_14d)))

# Degrees of freedom for seasonality / long-term trend.
# Fixed at 50 to match the QAIC-selected cubic B-spline (df=50) in Associations.R.
# In mgcv GAM with REML penalisation, k=50 sets the maximum basis dimension;
# the effective df is determined automatically and will typically be lower.
df_time <- 50

# For BKMR, model.matrix() is unpenalised — df_time = 50 would consume most
# residual df before the mixture term enters. Use a shorter smooth.
bkmr_df_time <- 8

# Basic covariates used in all mixture models — aligned with Associations.R:
#   s(time, k=50)  corresponds to bs(time, degree=3, df=50) in Associations.R
#   s(tapp, k=6)   apparent temperature (TAPP), matching cbtempunc in Associations.R;
#                  replaces separate s(temp) + s(relhum) used in earlier version
#   dow            day-of-week factor (DOW2, renamed to dow via column cleaning)
#   public_holiday public holiday indicator (PublicHoliday2, renamed)
base_covariates <- paste0(
  "s(time, k = ", df_time, ") + ",
  "dow + public_holiday + ",
  "s(tapp, k = 6)")

#############################################
# 2. Descriptive pollutant correlation plot  #
#############################################

cor_mat <- cor(dat_model[, pollutants], use = "pairwise.complete.obs", method = "spearman")
write.csv(cor_mat, "RDA/pollutant_spearman_correlation.csv", row.names = TRUE)

cor_long <- as.data.frame(as.table(cor_mat)) %>%
  rename(var1 = Var1, var2 = Var2, rho = Freq)

p_cor <- ggplot(cor_long, aes(var1, var2, fill = rho)) +
  geom_tile() +
  geom_text(aes(label = round(rho, 2)), size = 3) +
  labs(
    title = "Spearman correlation between pollutants",
    x = NULL, y = NULL, fill = "rho") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


################################################################################
# OPTION 1: PCA / SOURCE-STYLE INDICES + QUASI-POISSON GAM
################################################################################

# Why PCA?
# PCA compresses correlated pollutants into components/factors.
# Example interpretation:
# - PC with high NO2, PM2.5 loadings -> traffic/combustion factor
# - PC with high PM2.5, PM10, SO2 loadings -> industrial/coal/combustion factor


# Standardize pollutants first because units differ.
# prcomp with center/scale. = TRUE stores means and SDs internally, enabling
# predict(pca_fit, newdata = ...) for consistent score computation in loops.
pca_fit <- prcomp(
  dat_model %>% select(all_of(pollutants)),
  center = TRUE, scale. = TRUE)

# PCA variance explained.
pca_variance <- tibble(
  component = paste0("PC", seq_along(pca_fit$sdev)),
  eigenvalue = pca_fit$sdev^2,
  prop_variance = eigenvalue / sum(eigenvalue),
  cum_variance = cumsum(prop_variance))

write.csv(pca_variance, "RDA/pca_variance_explained.csv", row.names = FALSE)

# PCA loadings.
pca_loadings <- as.data.frame(pca_fit$rotation) %>%
  rownames_to_column("pollutant")
write.csv(pca_loadings, "RDA/pca_loadings.csv", row.names = FALSE)

# Choose number of PCs retained.
# With only 4 pollutants, keeping 4 PCs is just a rotation — no compression.
# Capped at 3: ensures at least one dimension is reduced while still allowing
# up to 3 interpretable components. In practice, the eigenvalue > 1 rule with
# 4 correlated industrial pollutants usually yields 1-2 PCs. Review
# pca_variance (saved to RDA/) to confirm before reporting.
n_pc <- sum(pca_variance$eigenvalue > 1)
n_pc <- max(2, min(n_pc, 3))
message("Number of PCs retained: ", n_pc)

# Add PC scores to modelling data.
# Use predict() rather than indexing pca_fit$x directly so that the scores
# are computed from the stored centre/scale, not tied to training-set row order.
pc_mat    <- predict(pca_fit, newdata = dat_model[, pollutants, drop = FALSE])[, 1:n_pc, drop = FALSE]
pc_scores <- as.data.frame(pc_mat)
names(pc_scores) <- paste0("pc", seq_len(n_pc))

dat_pca <- bind_cols(dat_model, pc_scores)

# Fit quasi-Poisson GAM with PCA scores.
pca_terms <- paste0("pc", seq_len(n_pc), collapse = " + ")
form_pca <- as.formula(paste(outcome_var, "~", pca_terms, "+", base_covariates))

fit_pca <- gam(form_pca, family = quasipoisson(link = "log"), data = dat_pca, method = "REML")
summary(fit_pca)

# Extract PCA coefficient estimates and convert to percent change per 1 SD increase in PC score.
pca_results <- broom::tidy(fit_pca, parametric = TRUE, conf.int = TRUE) %>%
  filter(term %in% paste0("pc", seq_len(n_pc))) %>%
  mutate(
    outcome        = outcome_var,
    exposure       = "same-day",
    rr             = exp(estimate),
    rr_low         = exp(conf.low),
    rr_high        = exp(conf.high),
    percent_change = (rr      - 1) * 100,
    percent_low    = (rr_low  - 1) * 100,
    percent_high   = (rr_high - 1) * 100)

write.csv(pca_results, paste0("RDA/pca_gam_results_", outcome_var, ".csv"), row.names = FALSE)

# Plot PCA effects.
p_pca <- pca_results %>%
  mutate(term = factor(term, levels = paste0("pc", seq_len(n_pc)))) %>%
  ggplot(aes(x = term, y = percent_change, ymin = percent_low, ymax = percent_high)) +
  geom_pointrange() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    title = paste("PCA mixture indices and", toupper(outcome_var), "mortality"),
    x = "PCA/source-style pollutant component",
    y = "% change in mortality per 1 SD increase") +
  theme_minimal()


# ---- 1b. PCA on 14-day rolling mean exposures ---------------------------------
# Rolling-mean series have stronger mutual correlations (temporal smoothing),
# so PCA structure may differ from same-day. Variance table and loadings saved separately.
pca_fit_14d <- prcomp(
  dat_model_14d %>% select(all_of(pollutants_14d)),
  center = TRUE, scale. = TRUE)

pca_variance_14d <- tibble(
  component     = paste0("PC", seq_along(pca_fit_14d$sdev)),
  eigenvalue    = pca_fit_14d$sdev^2,
  prop_variance = eigenvalue / sum(eigenvalue),
  cum_variance  = cumsum(prop_variance))

write.csv(pca_variance_14d, "RDA/pca_variance_explained_14d.csv", row.names = FALSE)

pca_loadings_14d <- as.data.frame(pca_fit_14d$rotation) %>%
  rownames_to_column("pollutant")
write.csv(pca_loadings_14d, "RDA/pca_loadings_14d.csv", row.names = FALSE)

# Separate n_pc for the 14d fit: temporal smoothing concentrates variance
# differently from same-day, so the eigenvalue rule may yield a different count.
n_pc_14d <- sum(pca_variance_14d$eigenvalue > 1)
n_pc_14d <- max(2, min(n_pc_14d, 3))
message("Number of PCs retained (14-day): ", n_pc_14d)

pca_terms_14d <- paste0("pc", seq_len(n_pc_14d), collapse = " + ")
pc_mat_14d    <- predict(pca_fit_14d, newdata = dat_model_14d[, pollutants_14d, drop = FALSE])[, 1:n_pc_14d, drop = FALSE]
pc_scores_14d <- as.data.frame(pc_mat_14d)
names(pc_scores_14d) <- paste0("pc", seq_len(n_pc_14d))

dat_pca_14d  <- bind_cols(dat_model_14d, pc_scores_14d)
form_pca_14d <- as.formula(paste(outcome_var, "~", pca_terms_14d, "+", base_covariates))
fit_pca_14d  <- gam(form_pca_14d, family = quasipoisson(link = "log"),
                    data = dat_pca_14d, method = "REML")
summary(fit_pca_14d)

pca_results_14d <- broom::tidy(fit_pca_14d, parametric = TRUE, conf.int = TRUE) %>%
  filter(term %in% paste0("pc", seq_len(n_pc_14d))) %>%
  mutate(
    outcome        = outcome_var,
    exposure       = "14-day mean",
    rr             = exp(estimate),
    rr_low         = exp(conf.low),
    rr_high        = exp(conf.high),
    percent_change = (rr      - 1) * 100,
    percent_low    = (rr_low  - 1) * 100,
    percent_high   = (rr_high - 1) * 100)

write.csv(pca_results_14d,
          paste0("RDA/pca_gam_results_14d_", outcome_var, ".csv"), row.names = FALSE)

p_pca_14d <- pca_results_14d %>%
  mutate(term = factor(term, levels = paste0("pc", seq_len(n_pc_14d)))) %>%
  ggplot(aes(x = term, y = percent_change, ymin = percent_low, ymax = percent_high)) +
  geom_pointrange() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    title = paste("PCA (14-day mean) indices and", toupper(outcome_var), "mortality"),
    x = "PCA component", y = "% change in mortality per 1 SD increase") +
  theme_minimal()


# Source-style indices for Gert Sibande / Mpumalanga industrial context.
# Names reflect dominant pollution pathways in a coal-belt study area.
# Labels are provisional — update based on empirical PCA loadings (pca_loadings.csv).
#
#   coal_power_index     : SO2 + PM10 — direct coal combustion signature
#                          (power stations, industrial boilers, fly ash)
#   fine_combustion_index: PM2.5 + NO2 — fine particles and oxidants from
#                          combustion (also captures secondary aerosol formation)

build_source_indices <- function(d, poll_suffix = "") {
  so2_col  <- paste0("so2",   poll_suffix)
  pm10_col <- paste0("pm10",  poll_suffix)
  pm25_col <- paste0("pm2_5", poll_suffix)
  no2_col  <- paste0("no2",   poll_suffix)
  d %>%
    mutate(
      coal_power_index      = rowMeans(
        scale(select(., any_of(c(so2_col, pm10_col)))), na.rm = TRUE),
      fine_combustion_index = rowMeans(
        scale(select(., any_of(c(pm25_col, no2_col)))), na.rm = TRUE))
}

source_index_vars <- c("coal_power_index", "fine_combustion_index")

# ---- Same-day source indices ----
dat_source  <- build_source_indices(dat_model, poll_suffix = "")
form_source <- as.formula(paste(
  outcome_var, "~ coal_power_index + fine_combustion_index +", base_covariates))
fit_source  <- gam(form_source, family = quasipoisson(link = "log"),
                   data = dat_source, method = "REML")
summary(fit_source)

source_results <- broom::tidy(fit_source, parametric = TRUE, conf.int = TRUE) %>%
  filter(term %in% source_index_vars) %>%
  mutate(
    outcome        = outcome_var,
    exposure       = "same-day",
    rr             = exp(estimate),
    rr_low         = exp(conf.low),
    rr_high        = exp(conf.high),
    percent_change = (rr      - 1) * 100,
    percent_low    = (rr_low  - 1) * 100,
    percent_high   = (rr_high - 1) * 100)
write.csv(source_results,
          paste0("RDA/source_index_results_", outcome_var, ".csv"), row.names = FALSE)

p_source <- source_results %>%
  ggplot(aes(x = term, y = percent_change, ymin = percent_low, ymax = percent_high)) +
  geom_pointrange() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    title = paste("Source indices (same-day) and", toupper(outcome_var), "mortality"),
    x = "Source index", y = "% change in mortality per 1 SD increase") +
  theme_minimal()

# ---- 14-day mean source indices ----
dat_source_14d  <- build_source_indices(dat_model_14d, poll_suffix = "_14d")
form_source_14d <- as.formula(paste(
  outcome_var, "~ coal_power_index + fine_combustion_index +", base_covariates))
fit_source_14d  <- gam(form_source_14d, family = quasipoisson(link = "log"),
                       data = dat_source_14d, method = "REML")
summary(fit_source_14d)

source_results_14d <- broom::tidy(fit_source_14d, parametric = TRUE, conf.int = TRUE) %>%
  filter(term %in% source_index_vars) %>%
  mutate(
    outcome        = outcome_var,
    exposure       = "14-day mean",
    rr             = exp(estimate),
    rr_low         = exp(conf.low),
    rr_high        = exp(conf.high),
    percent_change = (rr      - 1) * 100,
    percent_low    = (rr_low  - 1) * 100,
    percent_high   = (rr_high - 1) * 100)

write.csv(source_results_14d,
          paste0("RDA/source_index_results_14d_", outcome_var, ".csv"), row.names = FALSE)

p_source_14d <- source_results_14d %>%
  ggplot(aes(x = term, y = percent_change, ymin = percent_low, ymax = percent_high)) +
  geom_pointrange() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    title = paste("Source indices (14-day mean) and", toupper(outcome_var), "mortality"),
    x = "Source index", y = "% change in mortality per 1 SD increase") +
  theme_minimal()

################################################################################
# OPTION 2: BKMR EXPLORATORY MIXTURE ANALYSIS
################################################################################

# BKMR estimates flexible nonlinear and interactive mixture effects.
# Limitation: bkmr::kmbayes is not a quasi-Poisson time-series count model.
# Treated as exploratory/sensitivity analysis alongside primary DLM results.
# Outcome: log(count + 0.5) approximation; all confounders aligned with Associations.R.

# ---- 2a. BKMR on same-day exposures ------------------------------------------
bkmr_dat <- dat_model %>%
  mutate(
    y_bkmr         = log(.data[[outcome_var]] + 0.5),
    dow            = factor(dow),
    public_holiday = factor(public_holiday))

Z <- bkmr_dat %>%
  select(all_of(pollutants)) %>%
  scale(center = TRUE, scale = TRUE) %>%
  as.matrix()

X <- model.matrix(
  ~ ns(time, df = bkmr_df_time) + dow + public_holiday + ns(tapp, df = 4),
  data = bkmr_dat)

Y <- bkmr_dat$y_bkmr

# iter = 25000: minimum for publication-quality convergence with 4 pollutants.
# varsel = TRUE: posterior inclusion probabilities (PIPs) per pollutant.
# Runtime: ~30-60 min per run. Plan to run overnight for final analysis.
# set.seed() placed here (not at top of script) so this section is reproducible
# whether run in isolation or as part of the full script.
set.seed(1234)
fit_bkmr <- kmbayes(
  y = Y, Z = Z, X = X,
  iter = 25000, varsel = TRUE, verbose = TRUE)

saveRDS(fit_bkmr, paste0("RDA/bkmr_fit_", outcome_var, ".rds"))

# Convergence diagnostics — inspect before extracting any summaries.
# Trace plots should show stable horizontal mixing (caterpillar pattern).
# Visible trends or poor mixing = increase iter or check model specification.
TracePlot(fit_bkmr, par = "sigsq.eps",
          main = "Trace (same-day): error variance")
TracePlot(fit_bkmr, par = "r", comp = 1,
          main = paste("Trace: kernel scale", pollutants[1]))
TracePlot(fit_bkmr, par = "r", comp = 2,
          main = paste("Trace: kernel scale", pollutants[2]))

bkmr_pips <- ExtractPIPs(fit_bkmr) %>%
  as.data.frame() %>%
  rownames_to_column("pollutant") %>%
  mutate(outcome = outcome_var, exposure = "same-day")
write.csv(bkmr_pips, paste0("RDA/bkmr_pips_", outcome_var, ".csv"), row.names = FALSE)

overall_risk <- OverallRiskSummaries(
  fit = fit_bkmr, qs = seq(0.25, 0.75, by = 0.05), q.fixed = 0.5, method = "exact")

write.csv(overall_risk, paste0("RDA/bkmr_overall_risk_", outcome_var, ".csv"), row.names = FALSE)

p_bkmr_overall <- ggplot(overall_risk,
    aes(x = quantile, y = est, ymin = est - 1.96 * sd, ymax = est + 1.96 * sd)) +
  geom_pointrange() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    title = paste("BKMR overall mixture (same-day) \u2014", toupper(outcome_var)),
    x = "Joint pollutant quantile",
    y = "Difference in log mortality vs median mixture") +
  theme_minimal()

singvar <- PredictorResponseUnivar(fit = fit_bkmr, q.fixed = 0.5, method = "exact")
write.csv(singvar, paste0("RDA/bkmr_single_pollutant_response_", outcome_var, ".csv"),
          row.names = FALSE)

p_bkmr_single <- ggplot(singvar,
    aes(x = z, y = est, ymin = est - 1.96 * se, ymax = est + 1.96 * se)) +
  geom_ribbon(alpha = 0.2) +
  geom_line() +
  facet_wrap(~ variable, scales = "free_x") +
  labs(
    title = paste("BKMR single-pollutant response (same-day) \u2014", toupper(outcome_var)),
    x = "Standardized pollutant level", y = "Difference in log mortality") +
  theme_minimal()


# ---- 2b. BKMR on 14-day rolling mean exposures --------------------------------
bkmr_dat_14d <- dat_model_14d %>%
  mutate(
    y_bkmr         = log(.data[[outcome_var]] + 0.5),
    dow            = factor(dow),
    public_holiday = factor(public_holiday))

Z_14d <- bkmr_dat_14d %>%
  select(all_of(pollutants_14d)) %>%
  scale(center = TRUE, scale = TRUE) %>%
  as.matrix()

X_14d <- model.matrix(
  ~ ns(time, df = bkmr_df_time) + dow + public_holiday + ns(tapp, df = 4),
  data = bkmr_dat_14d)

Y_14d <- bkmr_dat_14d$y_bkmr

set.seed(1234)
fit_bkmr_14d <- kmbayes(
  y = Y_14d, Z = Z_14d, X = X_14d,
  iter = 25000, varsel = TRUE, verbose = TRUE)

saveRDS(fit_bkmr_14d, paste0("RDA/bkmr_fit_14d_", outcome_var, ".rds"))

TracePlot(fit_bkmr_14d, par = "sigsq.eps",
          main = "Trace (14-day): error variance")
TracePlot(fit_bkmr_14d, par = "r", comp = 1,
          main = paste("Trace (14d): kernel scale", pollutants[1]))

bkmr_pips_14d <- ExtractPIPs(fit_bkmr_14d) %>%
  as.data.frame() %>%
  rownames_to_column("pollutant") %>%
  mutate(outcome = outcome_var, exposure = "14-day mean")
write.csv(bkmr_pips_14d, paste0("RDA/bkmr_pips_14d_", outcome_var, ".csv"), row.names = FALSE)

overall_risk_14d <- OverallRiskSummaries(
  fit = fit_bkmr_14d, qs = seq(0.25, 0.75, by = 0.05), q.fixed = 0.5, method = "exact")

write.csv(overall_risk_14d,
          paste0("RDA/bkmr_overall_risk_14d_", outcome_var, ".csv"), row.names = FALSE)

p_bkmr_overall_14d <- ggplot(overall_risk_14d,
    aes(x = quantile, y = est, ymin = est - 1.96 * sd, ymax = est + 1.96 * sd)) +
  geom_pointrange() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    title = paste("BKMR overall mixture (14-day mean) \u2014", toupper(outcome_var)),
    x = "Joint pollutant quantile",
    y = "Difference in log mortality vs median mixture") +
  theme_minimal()

singvar_14d <- PredictorResponseUnivar(fit = fit_bkmr_14d, q.fixed = 0.5, method = "exact")
write.csv(singvar_14d,
          paste0("RDA/bkmr_single_pollutant_response_14d_", outcome_var, ".csv"),
          row.names = FALSE)

p_bkmr_single_14d <- ggplot(singvar_14d,
    aes(x = z, y = est, ymin = est - 1.96 * se, ymax = est + 1.96 * se)) +
  geom_ribbon(alpha = 0.2) +
  geom_line() +
  facet_wrap(~ variable, scales = "free_x") +
  labs(
    title = paste("BKMR single-pollutant response (14-day mean) \u2014", toupper(outcome_var)),
    x = "Standardized pollutant level", y = "Difference in log mortality") +
  theme_minimal()


################################################################################
# 4. LOOP OVER ALL OUTCOMES
################################################################################
# Primary outcomes:   CVD (cardiovascular), RD (respiratory)
# Secondary outcomes: by sex (male/female) and age group (45-64, 65+)
#
# NOTE: BKMR loop reads from pre-saved RDS files — run sections 2a/2b per
# outcome before using the BKMR loop. Each fit at iter=25000 takes ~30-60 min.

primary_outcomes   <- intersect(c("cvd", "rd"), outcomes)
secondary_outcomes <- intersect(
  c("cvd_male", "cvd_female", "cvd_fiftosixtyfour", "cvd_sixtyfiveplus",
    "rd_male",  "rd_female",  "rd_fiftosixtyfour",  "rd_sixtyfiveplus"),
  outcomes)

all_outcomes_loop <- c(primary_outcomes, secondary_outcomes)

# ---- PCA loop (same-day) ----
run_pca_model_for_outcome <- function(yvar, data = dat_model, npcs = n_pc) {
  pc_mat    <- predict(pca_fit, newdata = data[, pollutants, drop = FALSE])[, 1:npcs, drop = FALSE]
  pc_scores <- as.data.frame(pc_mat)
  names(pc_scores) <- paste0("pc", seq_len(npcs))
  d     <- bind_cols(data, pc_scores)
  terms <- paste0("pc", seq_len(npcs), collapse = " + ")
  f     <- as.formula(paste(yvar, "~", terms, "+", base_covariates))
  fit   <- gam(f, family = quasipoisson(link = "log"), data = d, method = "REML")
  broom::tidy(fit, parametric = TRUE, conf.int = TRUE) %>%
    filter(term %in% paste0("pc", seq_len(npcs))) %>%
    mutate(
      outcome = yvar, exposure = "same-day",
      rr = exp(estimate), rr_low = exp(conf.low), rr_high = exp(conf.high),
      percent_change = (rr      - 1) * 100,
      percent_low    = (rr_low  - 1) * 100,
      percent_high   = (rr_high - 1) * 100)
}

# ---- PCA loop (14-day mean) ----
run_pca_14d_model_for_outcome <- function(yvar, data = dat_model_14d, npcs = n_pc_14d) {
  pc_mat        <- predict(pca_fit_14d, newdata = data[, pollutants_14d, drop = FALSE])[, 1:npcs, drop = FALSE]
  pc_scores_14d <- as.data.frame(pc_mat)
  names(pc_scores_14d) <- paste0("pc", seq_len(npcs))
  d     <- bind_cols(data, pc_scores_14d)
  terms <- paste0("pc", seq_len(npcs), collapse = " + ")
  f     <- as.formula(paste(yvar, "~", terms, "+", base_covariates))
  fit   <- gam(f, family = quasipoisson(link = "log"), data = d, method = "REML")
  broom::tidy(fit, parametric = TRUE, conf.int = TRUE) %>%
    filter(term %in% paste0("pc", seq_len(npcs))) %>%
    mutate(
      outcome = yvar, exposure = "14-day mean",
      rr = exp(estimate), rr_low = exp(conf.low), rr_high = exp(conf.high),
      percent_change = (rr      - 1) * 100,
      percent_low    = (rr_low  - 1) * 100,
      percent_high   = (rr_high - 1) * 100)
}

# ---- Source index loop ----
run_source_model_for_outcome <- function(yvar, data, label) {
  f   <- as.formula(paste(
    yvar, "~ coal_power_index + fine_combustion_index +", base_covariates
  ))
  fit <- gam(f, family = quasipoisson(link = "log"), data = data, method = "REML")
  broom::tidy(fit, parametric = TRUE, conf.int = TRUE) %>%
    filter(term %in% c("coal_power_index", "fine_combustion_index")) %>%
    mutate(
      outcome = yvar, exposure = label,
      rr = exp(estimate), rr_low = exp(conf.low), rr_high = exp(conf.high),
      percent_change = (rr      - 1) * 100,
      percent_low    = (rr_low  - 1) * 100,
      percent_high   = (rr_high - 1) * 100)
}

pca_all_outcomes     <- map_dfr(all_outcomes_loop, run_pca_model_for_outcome)
pca_all_outcomes_14d <- map_dfr(all_outcomes_loop, run_pca_14d_model_for_outcome)

# Pre-compute source index data frames once — avoids rebuilding them 10× each
# inside map_dfr (build_source_indices output is identical for every outcome).
dat_source_loop     <- build_source_indices(dat_model,    poll_suffix = "")
dat_source_14d_loop <- build_source_indices(dat_model_14d, poll_suffix = "_14d")

source_all_same_day <- map_dfr(all_outcomes_loop,
  ~ run_source_model_for_outcome(.x, dat_source_loop,     "same-day"))
source_all_14d      <- map_dfr(all_outcomes_loop,
  ~ run_source_model_for_outcome(.x, dat_source_14d_loop, "14-day mean"))

write.csv(bind_rows(pca_all_outcomes, pca_all_outcomes_14d),
          "RDA/pca_results_all_outcomes.csv", row.names = FALSE)
write.csv(bind_rows(source_all_same_day, source_all_14d),
          "RDA/source_index_results_all_outcomes.csv", row.names = FALSE)

# ---- BKMR PIPs loop (reads from pre-saved RDS) ----
# Loads each pre-fitted BKMR object and extracts PIPs. Skips with a message
# if the RDS does not exist (run sections 2a/2b manually per outcome first).
extract_bkmr_pips <- function(yvar, suffix = "", label) {
  rds_path <- paste0("RDA/bkmr_fit", suffix, "_", yvar, ".rds")
  if (!file.exists(rds_path)) {
    message("BKMR RDS not found for: ", yvar, " (", label, ") \u2014 skipping.")
    return(NULL)
  }
  fit <- readRDS(rds_path)
  ExtractPIPs(fit) %>%
    as.data.frame() %>%
    rownames_to_column("pollutant") %>%
    mutate(outcome = yvar, exposure = label)
}

bkmr_pips_all <- bind_rows(
  map_dfr(all_outcomes_loop, extract_bkmr_pips, suffix = "",     label = "same-day"),
  map_dfr(all_outcomes_loop, extract_bkmr_pips, suffix = "_14d", label = "14-day mean"))

if (nrow(bkmr_pips_all) > 0)
  write.csv(bkmr_pips_all, "RDA/bkmr_pips_all_outcomes.csv", row.names = FALSE)

################################################################################
# 5. SAVE PLOTS
################################################################################
# All plots written to PLOTS/ as PNG. Filenames include outcome_var so re-running
# with different outcome_var values does not overwrite previous outputs.

dir.create("PLOTS", showWarnings = FALSE)

ggsave("PLOTS/pollutant_spearman_correlation.png", p_cor, width = 6, height = 5, dpi = 300)

ggsave(paste0("PLOTS/pca_effects_", outcome_var, ".png"), p_pca, width = 6, height = 4, dpi = 300)

ggsave(paste0("PLOTS/pca_14d_effects_", outcome_var, ".png"), p_pca_14d, width = 6, height = 4, dpi = 300)

ggsave(paste0("PLOTS/source_effects_", outcome_var, ".png"), p_source, width = 6, height = 4, dpi = 300)

ggsave(paste0("PLOTS/source_14d_effects_", outcome_var, ".png"), p_source_14d, width = 6, height = 4, dpi = 300)

ggsave(paste0("PLOTS/bkmr_overall_", outcome_var, ".png"), p_bkmr_overall, width = 6, height = 4, dpi = 300)

ggsave(paste0("PLOTS/bkmr_overall_14d_", outcome_var, ".png"), p_bkmr_overall_14d, width = 6, height = 4, dpi = 300)

ggsave(paste0("PLOTS/bkmr_single_", outcome_var, ".png"), p_bkmr_single,      width = 8, height = 5, dpi = 300)

ggsave(paste0("PLOTS/bkmr_single_14d_", outcome_var, ".png"), p_bkmr_single_14d,  width = 8, height = 5, dpi = 300)
