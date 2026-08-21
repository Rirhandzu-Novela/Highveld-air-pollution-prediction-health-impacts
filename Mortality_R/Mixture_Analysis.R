################################################################################
# This script implements TWO mixture options:
#   OPTION 1: WEIGHTED QUANTILE SUM (WQS) REGRESSION
#   OPTION 2: BKMR exploratory mixture analysis
#   OPTION 3: PCA / source-style pollutant indices + quasi-Poisson GAM
################################################################################

############################
# 0. Load packages         #
############################
library(tidyverse)
library(lubridate)
library(mgcv)
library(splines)
library(bkmr)
library(gWQS)

set.seed(1234)

########################
# 1. Read and prepare   #
########################
dat <-  read.csv("C:/Users/User/Documents/GitHub/Health-impacts-of-air-pollution/MortData/GertPollPulMort.csv", header = T, sep = ";")

dat$date <- as.Date(dat$date, format = "%Y/%m/%d")

## Repalce NAs with 0
dat[is.na(dat)] = 0

# SET THE DEFAULT ACTION FOR MISSING DATA TO na.exclude
# (MISSING EXCLUDED IN ESTIMATION BUT RE-INSERTED IN PREDICTION/RESIDUALS)
options(na.action = "na.exclude")

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
    public_holiday = factor(publicholiday2)) %>%
  arrange(date)

# Exposure variables.
pollutants <- c("pm2_5", "pm10", "so2", "no2")
met_vars <- c("temp", "relhum")

# Outcomes.
outcomes <- c("death_count")

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
    tapp = -2.653 + (0.994 * temp) + (0.0153 * dew))

# Drop rows with missing values in variables required for models.
# tapp is included so that rows with missing temp/relhum are excluded.
model_vars <- c("date", "time", "dow", "public_holiday", pollutants, "tapp", outcomes)
dat_model <- dat %>%
  select(all_of(model_vars)) %>%
  drop_na()


outcome_var <- "death_count"

# Degrees of freedom for seasonality / long-term trend.
# Fixed at 50 to match the QAIC-selected cubic B-spline (df=50) in Associations.R.
# In mgcv GAM with REML penalisation, k=50 sets the maximum basis dimension;
# the effective df is determined automatically and will typically be lower.
df_time <- 50


# Basic covariates used in all mixture models — aligned with Associations.R:
#   s(time, k=50)  corresponds to bs(time, degree=3, df=50) in Associations.R
#   s(tapp, k=6)   apparent temperature (TAPP), matching cbtempunc in Associations.R;
#                  replaces separate s(temp) + s(relhum) used in earlier version
#   dow            day-of-week factor (DOW2, renamed to dow via column cleaning)
#   public_holiday public holiday indicator (PublicHoliday2, renamed)

base_covariates <- paste0("s(time, k = ", df_time, ") + ", "dow + public_holiday + ", "s(tapp, k = 6)")

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
# OPTION 1: WEIGHTED QUANTILE SUM (WQS) REGRESSION
################################################################################
# WQS creates one weighted mixture index from quantiled pollutants.
# It estimates:
#   1) an overall mixture association, and
#   2) pollutant weights showing which pollutants contribute most to that mixture.
#
# Practical notes:
# - WQS usually assumes all mixture components act in the same direction.
# - Run separate positive and negative direction models if needed.
# - The gWQS package uses repeated bootstrapping and can be slow.
# - This code uses a modest setup; increase b and validation fraction for final paper.

# gWQS works best with simple covariate structures.
# We create spline basis columns explicitly for long-term trend and meteorology.
# This avoids some formula incompatibilities with s() inside gwqs().


#------------------------------------------------------------------------------
# PREPARE DATA
#------------------------------------------------------------------------------

make_spline_df <- function(x, df, prefix) {
  mat <- splines::ns(x, df = df)
  
  out <- as.data.frame(mat)
  
  names(out) <- paste0(
    prefix,
    seq_len(ncol(out)))
  
  out
}

wqs_dat <- dat_model %>%
  mutate(
    outcome = .data[[outcome_var]],
    dow = factor(dow),
    public_holiday = factor(public_holiday)) %>%
  bind_cols(
    make_spline_df(
      dat_model$time,
      df = df_time,
      prefix = "ns_time_")) %>%
  bind_cols(
    make_spline_df(
      dat_model$tapp,
      df = 4,
      prefix = "ns_tapp_"))

#------------------------------------------------------------------------------
# COVARIATES
#------------------------------------------------------------------------------

wqs_covars <- names(wqs_dat)[
  grepl(
    "^(ns_time_|ns_tapp_)",
    names(wqs_dat))
]

wqs_covars <- c(
  wqs_covars,
  "dow",
  "public_holiday")

form_wqs <- as.formula(
  paste(
    "outcome ~ wqs +",
    paste(wqs_covars, collapse = " + ")))

################################################################################
# POSITIVE DIRECTION MODEL
################################################################################

set.seed(1234)

fit_wqs_pos <- gwqs(
  formula = form_wqs,
  mix_name = pollutants,
  data = wqs_dat,
  q = 4,
  validation = 0.6,
  b = 100,                     # use 500 for final analysis
  b1_pos = TRUE,
  b1_constr = TRUE,
  family = "poisson",
  seed = 1234)

#summary(fit_wqs_pos)

# Positive Direction RR
wqs_coef_pos <- summary(
  fit_wqs_pos)$coefficients

wqs_results_pos <- as.data.frame(
  wqs_coef_pos) %>%
  rownames_to_column("term") %>%
  filter(term == "wqs") %>%
  mutate(
    rr = exp(Estimate),
    rr_low = exp(
      Estimate - 1.96 * `Std. Error`),
    rr_high = exp(
      Estimate + 1.96 * `Std. Error`),
    percent_change = (rr - 1) * 100,
    percent_low = (rr_low - 1) * 100,
    percent_high = (rr_high - 1) * 100)

write.csv(wqs_results_pos, paste0("RDA/wqs_positive_mixture_effect_",
    outcome_var,".csv"),row.names = FALSE)

wqs_results_pos

# Positive Direction Weights
wqs_weights_pos <- fit_wqs_pos$final_weights %>%
  arrange(desc(mean_weight))

write.csv(wqs_weights_pos,paste0("RDA/wqs_positive_weights_",
    outcome_var,".csv"), row.names = FALSE)

p_wqs_weights_pos <- ggplot(
  wqs_weights_pos,
  aes(
    x = reorder(mix_name,
                mean_weight),
    y = mean_weight)) +
  geom_col() +
  coord_flip() +
  labs(
    title = paste(
      "Positive WQS weights:",
      toupper(outcome_var)),
    x = "Pollutant",
    y = "Weight") +
  theme_minimal()

ggsave(paste0("RDA/wqs_positive_weights_", outcome_var, ".png"),
  p_wqs_weights_pos, width = 7, height = 5, dpi = 300)

# Negative Direction Model
fit_wqs_neg <- gwqs(
  formula = form_wqs,
  mix_name = pollutants,
  data = wqs_dat,
  q = 4,
  validation = 0.6,
  b = 100,
  b1_pos = FALSE,
  b1_constr = TRUE,
  family = "poisson",
  seed = 1234)

#summary(fit_wqs_neg)

# Negative Direction RR
wqs_coef_neg <- summary(fit_wqs_neg)$coefficients

wqs_results_neg <- as.data.frame(
  wqs_coef_neg) %>%
  rownames_to_column("term") %>%
  filter(term == "wqs") %>%
  mutate(
    rr = exp(Estimate),
    rr_low = exp(
      Estimate - 1.96 * `Std. Error`),
    rr_high = exp(
      Estimate + 1.96 * `Std. Error`),
    percent_change = (rr - 1) * 100,
    percent_low = (rr_low - 1) * 100,
    percent_high = (rr_high - 1) * 100)

write.csv(wqs_results_neg,paste0("RDA/wqs_negative_mixture_effect_",
    outcome_var, ".csv"), row.names = FALSE)

# Negative Direction Weights
wqs_weights_neg <- fit_wqs_neg$final_weights %>%
  arrange(desc(mean_weight))

write.csv(wqs_weights_neg, paste0("RDA/wqs_negative_weights_",
    outcome_var, ".csv"), row.names = FALSE)

################################################################################
# OPTION 2: BKMR EXPLORATORY MIXTURE ANALYSIS
################################################################################

# BKMR estimates flexible nonlinear and interactive mixture effects.
# Limitation: bkmr::kmbayes is not a quasi-Poisson time-series count model.
# Treated as exploratory/sensitivity analysis alongside primary DLM results.
# Outcome: log(count + 0.5) approximation; all confounders aligned with Associations.R.

# ---- 2a. BKMR on same-day exposures ------------------------------------------
################################################################################

bkmr_df_time <- 8

bkmr_dat <- dat_model %>%
  mutate(
    y_bkmr = log(death_count + 0.5),
    dow = factor(dow),
    public_holiday = factor(public_holiday))

# Mixture matrix (standardized)
Z <- bkmr_dat %>%
  select(all_of(pollutants)) %>%
  scale(center = TRUE, scale = TRUE) %>%
  as.matrix()

# Covariate matrix
X <- model.matrix(
  ~ ns(time, df = bkmr_df_time) +
    dow +
    public_holiday +
    ns(tapp, df = 4),
  data = bkmr_dat)

Y <- bkmr_dat$y_bkmr

#------------------------------------------------------------------------------
# FIT BKMR
#------------------------------------------------------------------------------

set.seed(1234)

fit_bkmr <- kmbayes(
  y = Y,
  Z = Z,
  X = X,
  iter = 2500, #change to 25000 for final analysis
  varsel = TRUE,
  verbose = TRUE)

saveRDS(fit_bkmr, paste0("RDA/bkmr_fit_", outcome_var, ".rds"))

#Convergence Diagnostics
TracePlot(
  fit_bkmr,
  par = "sigsq.eps",
  main = "Trace Plot: Error Variance")

TracePlot(
  fit_bkmr,
  par = "r",
  comp = 1,
  main = paste("Kernel Scale:", pollutants[1]))

TracePlot(
  fit_bkmr,
  par = "r",
  comp = 2,
  main = paste("Kernel Scale:", pollutants[2]))

# Posterior Inclusion Probabilities (PIPs)
bkmr_pips <- ExtractPIPs(fit_bkmr) %>%
  as.data.frame() %>%
  rownames_to_column("pollutant") %>%
  mutate(outcome = outcome_var)

write.csv(bkmr_pipspaste0("RDA/bkmr_pips_", outcome_var, ".csv"), row.names = FALSE)

bkmr_pips

ggplot(bkmr_pips,
  aes(
    x = reorder(pollutant, PIP),
    y = PIP)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Posterior Inclusion Probabilities",
    x = "Pollutant",
    y = "PIP") +
  theme_minimal()

# Overall Mixture-Response Function
overall_risk <- OverallRiskSummaries(
  fit = fit_bkmr,
  qs = seq(0.25, 0.75, by = 0.05),
  q.fixed = 0.50,
  method = "exact")

write.csv(overall_risk, paste0("RDA/bkmr_overall_risk_", outcome_var, ".csv"), row.names = FALSE)

overall_risk

ggplot(overall_risk,
  aes(
    x = quantile,
    y = est)) +
  geom_line() +
  geom_point() +
  geom_errorbar(
    aes(
      ymin = est - 1.96 * sd,
      ymax = est + 1.96 * sd),
    width = 0.01) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed") +
  labs(
    title = "Overall Mixture-Response Function",
    x = "Mixture Quantile",
    y = "Change in Log Mortality") +
  theme_minimal()

# Single-Pollutant Exposure-Response Curves
single_resp <- PredictorResponseUnivar(
  fit = fit_bkmr,
  q.fixed = 0.5,
  method = "exact")

write.csv(single_resp, paste0("RDA/bkmr_single_pollutant_response_", outcome_var, ".csv"), row.names = FALSE)

ggplot(single_resp,
  aes(
    x = z,
    y = est)) +
  geom_line() +
  geom_ribbon(
    aes(
      ymin = est - 1.96 * se,
      ymax = est + 1.96 * se),
    alpha = 0.2) +
  facet_wrap(
    ~ variable,
    scales = "free_x") +
  labs(
    title = "Single Pollutant Response Functions",
    x = "Standardized Pollutant Concentration",
    y = "Change in Log Mortality") +
  theme_minimal()

# Pollutant Interaction Surfaces
int_pm25_no2 <- PredictorResponseBivar(
  fit = fit_bkmr,
  min.plot.dist = 0.5,
  z.pair = c("pm2_5", "no2"),
  method = "exact")

write.csv(int_pm25_no2,"RDA/bkmr_interaction_pm25_no2.csv",row.names = FALSE)

ggplot(
  int_pm25_no2,
  aes(
    x = z1,
    y = est,
    colour = factor(z2))) +
  geom_line(size = 1) +
  labs(
    title = "PM2.5 × NO2 Interaction",
    x = "PM2.5",
    y = "Change in Log Mortality",
    colour = "NO2 Level") +
  theme_minimal()


################################################################################
# OPTION 3: PCA / SOURCE-STYLE INDICES + QUASI-POISSON GAM
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
n_pc <- max(3, min(n_pc, 3))
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
#summary(fit_pca)

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



