################################################################################
# COUNTERFACTUAL ANALYSIS: PREVENTABLE DEATHS UNDER ALTERNATIVE STANDARDS
# ---------------------------------------------------------------------------
# Three scenario types for each pollutant:
#   1. WHO 2021 24-hr AQG     — deaths from exceedances above guideline
#   2. SA NAAQS 24-hr standard — deaths from exceedances above national standard
#   3. 10% proportional reduction — deaths prevented by uniform 10% reduction
#
# Models: model8 (PM2.5), model81 (PM10), model82 (SO2), model83 (NO2)
# All single-pollutant, fully adjusted (cbtempunc + spl + dow + holiday)
#
# Interpretation:
#   Threshold scenario: "X deaths could be prevented if [pollutant] never
#     exceeded [standard], assuming the DLM association is causal."
#   Proportional reduction: "X deaths could be prevented by a 10% reduction
#     in daily [pollutant] concentrations across all days."
################################################################################

# STANDARD THRESHOLDS (24-hour mean, µg/m³) -----------------------------------

# WHO 2021 Air Quality Guidelines (24-hr mean)
std_who <- list(pm2.5 = 15, pm10 = 45, so2 = 40, no2 = 25)

# South African NAAQS (24-hr average)
# Note: SA has no 24-hr NAAQS for NO2 (only 1-hr = 200 µg/m³).
# The WHO 24-hr AQG (25 µg/m³) is used as a proxy for NO2.
std_naaqs <- list(pm2.5 = 40, pm10 = 75, so2 = 125, no2 = 25)


# HELPER: attributable deaths above a fixed threshold -------------------------
# cen = threshold; range restricts to days exceeding the threshold.
# AN = deaths attributable to exceedances = deaths preventable if standard met.
# CI uses Monte Carlo simulation from the model covariance matrix.
an_threshold <- function(x, cb, model, threshold, nsim = 1000) {
  total <- sum(model$y, na.rm = TRUE)
  if (sum(x > threshold, na.rm = TRUE) == 0)
    return(list(an = 0, af_pct = 0, ci_low_an = 0, ci_hi_an = 0))
  an <- attrdl(x, cb, model, type = "an", dir = "forw", lag = c(0,14),
               tot = TRUE, cen = threshold, range = c(threshold, max(x, na.rm = TRUE)))
  set.seed(123)
  sim <- attrdl(x, cb, model, type = "af", dir = "forw", lag = c(0,14),
                tot = TRUE, cen = threshold, range = c(threshold, max(x, na.rm = TRUE)),
                sim = TRUE, nsim = nsim)
  sim_an <- sim * total
  list(an        = round(an),
       af_pct    = round(an / total * 100, 2),
       ci_low_an = round(quantile(sim_an, 0.025)),
       ci_hi_an  = round(quantile(sim_an, 0.975)))
}

# HELPER: prevented deaths under proportional reduction -----------------------
# Uses the same random seed for both attrdl calls so that the 1000 coefficient
# draws are identical. Subtracting paired draws gives a valid CI for the
# difference without inflating variance from independent sampling.
an_reduction <- function(x, cb, model, pct = 10, nsim = 1000) {
  x_scen <- x * (1 - pct / 100)
  total  <- sum(model$y, na.rm = TRUE)
  an_obs  <- attrdl(x,      cb, model, type = "an", dir = "forw",
                    lag = c(0,14), tot = TRUE, cen = 0)
  an_scen <- attrdl(x_scen, cb, model, type = "an", dir = "forw",
                    lag = c(0,14), tot = TRUE, cen = 0)
  set.seed(123)
  sim_obs  <- attrdl(x,      cb, model, type = "af", dir = "forw",
                     lag = c(0,14), tot = TRUE, cen = 0, sim = TRUE, nsim = nsim)
  set.seed(123)
  sim_scen <- attrdl(x_scen, cb, model, type = "af", dir = "forw",
                     lag = c(0,14), tot = TRUE, cen = 0, sim = TRUE, nsim = nsim)
  prevented_sim_an <- (sim_obs - sim_scen) * total
  list(an        = round(an_obs - an_scen),
       af_pct    = round((an_obs - an_scen) / total * 100, 2),
       ci_low_an = round(quantile(prevented_sim_an, 0.025)),
       ci_hi_an  = round(quantile(prevented_sim_an, 0.975)))
}

# RUN COUNTERFACTUAL SCENARIOS ------------------------------------------------

cat("\n--- PM2.5 ---\n")
r_pm25_who   <- an_threshold(data$pm2.5, cbpm2constr, model8, std_who$pm2.5)
r_pm25_naaqs <- an_threshold(data$pm2.5, cbpm2constr, model8, std_naaqs$pm2.5)
r_pm25_10pct <- an_reduction(data$pm2.5, cbpm2constr, model8, pct = 10)

cat(sprintf("WHO AQG    (%3g µg/m³): AN = %4d | AF = %5.2f%% (95%%CI: %d to %d)\n",
            std_who$pm2.5, r_pm25_who$an, r_pm25_who$af_pct, r_pm25_who$ci_low_an, r_pm25_who$ci_hi_an))
cat(sprintf("SA NAAQS   (%3g µg/m³): AN = %4d | AF = %5.2f%% (95%%CI: %d to %d)\n",
            std_naaqs$pm2.5, r_pm25_naaqs$an, r_pm25_naaqs$af_pct, r_pm25_naaqs$ci_low_an, r_pm25_naaqs$ci_hi_an))
cat(sprintf("10%% reduction        : AN = %4d | AF = %5.2f%% (95%%CI: %d to %d)\n",
            r_pm25_10pct$an, r_pm25_10pct$af_pct, r_pm25_10pct$ci_low_an, r_pm25_10pct$ci_hi_an))

cat("\n--- PM10 ---\n")
r_pm10_who   <- an_threshold(data$pm10, cbpm1constr, model81, std_who$pm10)
r_pm10_naaqs <- an_threshold(data$pm10, cbpm1constr, model81, std_naaqs$pm10)
r_pm10_10pct <- an_reduction(data$pm10, cbpm1constr, model81, pct = 10)

cat(sprintf("WHO AQG    (%3g µg/m³): AN = %4d | AF = %5.2f%% (95%%CI: %d to %d)\n",
            std_who$pm10, r_pm10_who$an, r_pm10_who$af_pct, r_pm10_who$ci_low_an, r_pm10_who$ci_hi_an))
cat(sprintf("SA NAAQS   (%3g µg/m³): AN = %4d | AF = %5.2f%% (95%%CI: %d to %d)\n",
            std_naaqs$pm10, r_pm10_naaqs$an, r_pm10_naaqs$af_pct, r_pm10_naaqs$ci_low_an, r_pm10_naaqs$ci_hi_an))
cat(sprintf("10%% reduction        : AN = %4d | AF = %5.2f%% (95%%CI: %d to %d)\n",
            r_pm10_10pct$an, r_pm10_10pct$af_pct, r_pm10_10pct$ci_low_an, r_pm10_10pct$ci_hi_an))

cat("\n--- SO2 ---\n")
r_so2_who   <- an_threshold(data$so2, cbsoconstr, model82, std_who$so2)
r_so2_naaqs <- an_threshold(data$so2, cbsoconstr, model82, std_naaqs$so2)
r_so2_10pct <- an_reduction(data$so2, cbsoconstr, model82, pct = 10)

cat(sprintf("WHO AQG    (%3g µg/m³): AN = %4d | AF = %5.2f%% (95%%CI: %d to %d)\n",
            std_who$so2, r_so2_who$an, r_so2_who$af_pct, r_so2_who$ci_low_an, r_so2_who$ci_hi_an))
cat(sprintf("SA NAAQS   (%3g µg/m³): AN = %4d | AF = %5.2f%% (95%%CI: %d to %d)\n",
            std_naaqs$so2, r_so2_naaqs$an, r_so2_naaqs$af_pct, r_so2_naaqs$ci_low_an, r_so2_naaqs$ci_hi_an))
cat(sprintf("10%% reduction        : AN = %4d | AF = %5.2f%% (95%%CI: %d to %d)\n",
            r_so2_10pct$an, r_so2_10pct$af_pct, r_so2_10pct$ci_low_an, r_so2_10pct$ci_hi_an))

cat("\n--- NO2 ---\n")
# Note: SA has no 24-hr NAAQS for NO2; WHO 24-hr AQG (25 µg/m³) used for both rows
r_no2_who   <- an_threshold(data$no2, cbnoconstr, model83, std_who$no2)
r_no2_naaqs <- an_threshold(data$no2, cbnoconstr, model83, std_naaqs$no2)
r_no2_10pct <- an_reduction(data$no2, cbnoconstr, model83, pct = 10)

cat(sprintf("WHO AQG    (%3g µg/m³): AN = %4d | AF = %5.2f%% (95%%CI: %d to %d)\n",
            std_who$no2, r_no2_who$an, r_no2_who$af_pct, r_no2_who$ci_low_an, r_no2_who$ci_hi_an))
cat(sprintf("SA NAAQS   (%3g µg/m³): AN = %4d | AF = %5.2f%% (95%%CI: %d to %d)\n",
            std_naaqs$no2, r_no2_naaqs$an, r_no2_naaqs$af_pct, r_no2_naaqs$ci_low_an, r_no2_naaqs$ci_hi_an))
cat(sprintf("10%% reduction        : AN = %4d | AF = %5.2f%% (95%%CI: %d to %d)\n",
            r_no2_10pct$an, r_no2_10pct$af_pct, r_no2_10pct$ci_low_an, r_no2_10pct$ci_hi_an))

# SUMMARY TABLE ---------------------------------------------------------------
counterfactual_table <- data.frame(
  Pollutant  = rep(c("PM2.5","PM10","SO2","NO2"), each = 3),
  Scenario   = rep(c("WHO AQG","SA NAAQS","10% reduction"), 4),
  Threshold_ugm3 = c(std_who$pm2.5, std_naaqs$pm2.5, NA,
                     std_who$pm10,  std_naaqs$pm10,  NA,
                     std_who$so2,   std_naaqs$so2,   NA,
                     std_who$no2,   std_naaqs$no2,   NA),
  AN_prevented = c(r_pm25_who$an,  r_pm25_naaqs$an,  r_pm25_10pct$an,
                   r_pm10_who$an,  r_pm10_naaqs$an,  r_pm10_10pct$an,
                   r_so2_who$an,   r_so2_naaqs$an,   r_so2_10pct$an,
                   r_no2_who$an,   r_no2_naaqs$an,   r_no2_10pct$an),
  AF_pct       = c(r_pm25_who$af_pct,  r_pm25_naaqs$af_pct,  r_pm25_10pct$af_pct,
                   r_pm10_who$af_pct,  r_pm10_naaqs$af_pct,  r_pm10_10pct$af_pct,
                   r_so2_who$af_pct,   r_so2_naaqs$af_pct,   r_so2_10pct$af_pct,
                   r_no2_who$af_pct,   r_no2_naaqs$af_pct,   r_no2_10pct$af_pct),
  CI_low_AN  = c(r_pm25_who$ci_low_an,  r_pm25_naaqs$ci_low_an,  r_pm25_10pct$ci_low_an,
                 r_pm10_who$ci_low_an,  r_pm10_naaqs$ci_low_an,  r_pm10_10pct$ci_low_an,
                 r_so2_who$ci_low_an,   r_so2_naaqs$ci_low_an,   r_so2_10pct$ci_low_an,
                 r_no2_who$ci_low_an,   r_no2_naaqs$ci_low_an,   r_no2_10pct$ci_low_an),
  CI_high_AN = c(r_pm25_who$ci_hi_an,  r_pm25_naaqs$ci_hi_an,  r_pm25_10pct$ci_hi_an,
                 r_pm10_who$ci_hi_an,  r_pm10_naaqs$ci_hi_an,  r_pm10_10pct$ci_hi_an,
                 r_so2_who$ci_hi_an,   r_so2_naaqs$ci_hi_an,   r_so2_10pct$ci_hi_an,
                 r_no2_who$ci_hi_an,   r_no2_naaqs$ci_hi_an,   r_no2_10pct$ci_hi_an))

print(counterfactual_table)
write.csv(counterfactual_table, "Data/GertPollPulMortCounterfactual.csv", row.names = FALSE)

################################################################################
# AQHI-ER COUNTERFACTUAL: PREVENTABLE DEATHS BY RISK CATEGORY
# ---------------------------------------------------------------------------
# The categorical AQHI uses five risk bands:
#   Good (1-3) | Moderate (4-5) | Unhealthy (6-7) | Very Unhealthy (8-9) | Hazardous (10+)
#
# Each category boundary corresponds to a specific excess-risk threshold for
# each pollutant (from Adebayo-Ojo et al. 2023, as coded in Air_Poll_R/Gert.R):
#
#   Pollutant   cat3/4     cat5/6     cat7/8
#   PM10        0.63 %     1.05 %     1.47 %
#   NO2         0.72 %     1.20 %     1.68 %
#   SO2         1.20 %     2.00 %     2.80 %
#   PM2.5*      0.998 %    1.664 %    2.330 %   (* derived by scaling PM10 by beta ratio)
#
# Counterfactual: deaths prevented if AQHI-ER composite never exceeded the
# Good/Moderate boundary (primary), Moderate/Unhealthy, Unhealthy/Very Unhealthy.
# Uses the same an_threshold() helper defined in the counterfactual section above.
################################################################################

# Category boundary excess-risk thresholds (from Gert.R aqhi_* vectors) ------
er_cat34_pm10 <- 0.63;   er_cat56_pm10 <- 1.05;   er_cat78_pm10 <- 1.47
er_cat34_no2  <- 0.72;   er_cat56_no2  <- 1.20;   er_cat78_no2  <- 1.68
er_cat34_so2  <- 1.20;   er_cat56_so2  <- 2.00;   er_cat78_so2  <- 2.80

# PM2.5 not in original categorical AQHI; boundary derived by scaling from PM10
# using the beta ratio (same underlying WHO methodology):
pm25_scale <- beta_pm25 / beta_pm10   # ≈ 1.585
er_cat34_pm25 <- er_cat34_pm10 * pm25_scale  # ≈ 0.999 %
er_cat56_pm25 <- er_cat56_pm10 * pm25_scale  # ≈ 1.665 %
er_cat78_pm25 <- er_cat78_pm10 * pm25_scale  # ≈ 2.331 %

# AQHI-ER threshold = sum of per-pollutant excess risks at each category boundary
aqhi_er_thr_good     <- er_cat34_pm25 + er_cat34_pm10 + er_cat34_no2 + er_cat34_so2
aqhi_er_thr_moderate <- er_cat56_pm25 + er_cat56_pm10 + er_cat56_no2 + er_cat56_so2
aqhi_er_thr_unhealthy <- er_cat78_pm25 + er_cat78_pm10 + er_cat78_no2 + er_cat78_so2

cat(sprintf("AQHI-ER threshold: Good/Moderate boundary      = %.3f %%\n", aqhi_er_thr_good))
cat(sprintf("AQHI-ER threshold: Moderate/Unhealthy boundary  = %.3f %%\n", aqhi_er_thr_moderate))
cat(sprintf("AQHI-ER threshold: Unhealthy/VeryUnhealthy bnd  = %.3f %%\n", aqhi_er_thr_unhealthy))
cat(sprintf("Days above Good boundary: %d of %d (%.1f%%)\n",
            sum(data$aqhi_er > aqhi_er_thr_good, na.rm = TRUE), nrow(data),
            100 * mean(data$aqhi_er > aqhi_er_thr_good, na.rm = TRUE)))

# RUN AQHI-ER CATEGORY COUNTERFACTUALS ----------------------------------------
r_aqhier_good      <- an_threshold(data$aqhi_er, cbaqhierconstr, model_aqhier, aqhi_er_thr_good)
r_aqhier_moderate  <- an_threshold(data$aqhi_er, cbaqhierconstr, model_aqhier, aqhi_er_thr_moderate)
r_aqhier_unhealthy <- an_threshold(data$aqhi_er, cbaqhierconstr, model_aqhier, aqhi_er_thr_unhealthy)

cat("\n--- AQHI-ER Counterfactual by Risk Category ---\n")
cat(sprintf("Keep AQHI in Good      (≤3): AN = %4d | AF = %5.2f%% (95%%CI: %d to %d)\n",
            r_aqhier_good$an, r_aqhier_good$af_pct,
            r_aqhier_good$ci_low_an, r_aqhier_good$ci_hi_an))
cat(sprintf("Keep AQHI in Moderate  (≤5): AN = %4d | AF = %5.2f%% (95%%CI: %d to %d)\n",
            r_aqhier_moderate$an, r_aqhier_moderate$af_pct,
            r_aqhier_moderate$ci_low_an, r_aqhier_moderate$ci_hi_an))
cat(sprintf("Keep AQHI in Unhealthy (≤7): AN = %4d | AF = %5.2f%% (95%%CI: %d to %d)\n",
            r_aqhier_unhealthy$an, r_aqhier_unhealthy$af_pct,
            r_aqhier_unhealthy$ci_low_an, r_aqhier_unhealthy$ci_hi_an))

# SUMMARY TABLE ---------------------------------------------------------------
aqhier_cf_table <- data.frame(
  Scenario       = c("Keep in Good (AQHI ≤3)",
                     "Keep in Moderate (AQHI ≤5)",
                     "Keep in Unhealthy (AQHI ≤7)"),
  AQHI_ER_threshold = round(c(aqhi_er_thr_good,
                              aqhi_er_thr_moderate,
                              aqhi_er_thr_unhealthy), 3),
  Days_exceeding = c(sum(data$aqhi_er > aqhi_er_thr_good,      na.rm = TRUE),
                     sum(data$aqhi_er > aqhi_er_thr_moderate,   na.rm = TRUE),
                     sum(data$aqhi_er > aqhi_er_thr_unhealthy,  na.rm = TRUE)),
  AN_prevented   = c(r_aqhier_good$an,      r_aqhier_moderate$an,      r_aqhier_unhealthy$an),
  AF_pct         = c(r_aqhier_good$af_pct,  r_aqhier_moderate$af_pct,  r_aqhier_unhealthy$af_pct),
  CI_low_AN      = c(r_aqhier_good$ci_low_an,  r_aqhier_moderate$ci_low_an,  r_aqhier_unhealthy$ci_low_an),
  CI_high_AN     = c(r_aqhier_good$ci_hi_an,   r_aqhier_moderate$ci_hi_an,   r_aqhier_unhealthy$ci_hi_an))

print(aqhier_cf_table)
write.csv(aqhier_cf_table, "Data/GertPollPulMortAQHIERCounterfactual.csv", row.names = FALSE)

