############################################################
# DLNM mortality time-series model selection workflow
############################################################

library(dlnm)
library(splines)
library(dplyr)
library(purrr)
library(ggplot2)

############################################################
# LOAD THE DATA INTO THE SESSION
############################################################


data = read.csv("MortData/GertPollPulMort.csv", header = T, sep = ";")

data$date <- as.Date(data$date, format = "%Y/%m/%d")

## Repalce NAs with 0
data[is.na(data)] = 0

# SET THE DEFAULT ACTION FOR MISSING DATA TO na.exclude
# (MISSING EXCLUDED IN ESTIMATION BUT RE-INSERTED IN PREDICTION/RESIDUALS)
options(na.action = "na.exclude")

data$time <- seq(nrow(data))

############################################################
# 0. Prepare temperature adjustment
############################################################

cutoffs <- quantile(data$temp,probs = seq(0, 1, 0.1),na.rm = TRUE)

cbTemp <- crossbasis(data$temp, lag = c(0, 14), argvar = list(fun = "strata", breaks = cutoffs[2:10]),
  arglag = list(fun = "integer"))

############################################################
# Helper function for QAIC
############################################################

get_QAIC <- function(model_quasi, model_pois) {
  phi <- summary(model_quasi)$dispersion
  k <- length(coef(model_quasi))
  -2 * as.numeric(logLik(model_pois)) / phi + 2 * k
}

############################################################
# STAGE 1: Seasonal df selection
############################################################

lag_df_fixed <- 3
seasonal_dfs <- c(50, 70, 90)

fit_season_model <- function(seas_df) {
  
  cbPM <- crossbasis(data$pm2.5, lag = 14, argvar = list(fun = "lin"),
    arglag = list(fun = "ns", df = lag_df_fixed))
  
  spl_seas <- bs(data$time, df = seas_df, degree = 3)
  
  m <- glm(death_count ~ cbPM + cbTemp + spl_seas, family = quasipoisson(), data = data)
  
  m_pois <- glm(death_count ~ cbPM + cbTemp + spl_seas, family = poisson(),
    data = data)
  
  qaic <- get_QAIC(m, m_pois)
  
  pr <- crosspred(cbPM, m, at = 10, cumul = TRUE)
  
  res <- na.omit(residuals(m, type = "pearson"))
  
  acf_obj <- acf(res, plot = FALSE)
  pacf_obj <- pacf(res, plot = FALSE)
  
  lb <- Box.test(res, lag = 30, type = "Ljung-Box")
  
  data.frame(
    seas_df = seas_df,
    QAIC = qaic,
    RR = pr$allRRfit,
    RRlow = pr$allRRlow,
    RRhigh = pr$allRRhigh,
    maxACF = max(abs(acf_obj$acf[-1])),
    maxPACF = max(abs(pacf_obj$acf)),
    LjungBoxP = lb$p.value)
}

season_results <- map_dfr(seasonal_dfs, fit_season_model)


ggplot(season_results, aes(x = seas_df, y = QAIC)) +
  geom_line() +
  geom_point(size = 3) +
  labs(
    title = "Seasonal spline df selection",
    x = "Seasonal spline df",
    y = "QAIC") +
  theme_bw()

ggplot(season_results, aes(x = seas_df, y = RR)) +
  geom_point(size = 3) +
  geom_errorbar(
    aes(ymin = RRlow, ymax = RRhigh),
    width = 2) +
  labs(
    title = "PM2.5 cumulative RR by seasonal df",
    x = "Seasonal spline df",
    y = "Cumulative RR per 10 µg/m3 PM2.5") +
  theme_bw()

############################################################
# Choose seasonal df after reviewing results
############################################################

best_season_df <- 50

############################################################
# STAGE 2: Lag df selection
############################################################

lag_dfs <- 2:5

fit_lag_model <- function(lag_df) {
  
  cbPM <- crossbasis(data$pm2.5, lag = 14, argvar = list(fun = "lin"),
    arglag = list(fun = "ns", df = lag_df))
  
  spl_seas <- bs(data$time, df = best_season_df, degree = 3)
  
  m <- glm(death_count ~ cbPM + cbTemp + spl_seas,
    family = quasipoisson(), data = data)
  
  m_pois <- glm(death_count ~ cbPM + cbTemp + spl_seas,
    family = poisson(), data = data)
  
  qaic <- get_QAIC(m, m_pois)
  
  pr <- crosspred(cbPM, m, at = 10, cumul = TRUE)
  
  data.frame(
    lag_df = lag_df,
    QAIC = qaic,
    RR = pr$allRRfit,
    RRlow = pr$allRRlow,
    RRhigh = pr$allRRhigh)
}

lag_results <- map_dfr(lag_dfs, fit_lag_model)


ggplot(lag_results, aes(x = lag_df, y = QAIC)) +
  geom_line() +
  geom_point(size = 3) +
  labs(
    title = "Lag spline df selection",
    x = "Lag spline df",
    y = "QAIC") +
  theme_bw()

ggplot(lag_results, aes(x = lag_df, y = RR)) +
  geom_line() +
  geom_point(size = 3) +
  geom_errorbar(
    aes(ymin = RRlow, ymax = RRhigh),
    width = 0.1) +
  labs(
    title = "PM2.5 cumulative RR by lag df",
    x = "Lag spline df",
    y = "Cumulative RR per 10 µg/m3 PM2.5") +
  theme_bw()

############################################################
# Choose lag df after reviewing results
############################################################

best_lag_df <- 2  # QAIC range df=2–5 is <2 units; df=2 selected on parsimony

############################################################
# STAGE 3: Final model
############################################################

cbPM_final <- crossbasis(data$pm2.5, lag = 14, argvar = list(fun = "lin"),
  arglag = list(fun = "ns", df = best_lag_df))

spl_final <- bs(data$time, df = best_season_df, degree = 3)

final_model <- glm(death_count ~ cbPM_final + cbTemp + spl_final,
  family = quasipoisson(), data = data)

summary(final_model)

############################################################
# Final cumulative RR
############################################################

pred_final <- crosspred(cbPM_final, final_model, at = 10, cumul = TRUE)

final_RR <- data.frame(
  Model = "Final model",
  RR = pred_final$allRRfit,
  Low = pred_final$allRRlow,
  High = pred_final$allRRhigh)


############################################################
# Final residual diagnostics
############################################################

res_final <- na.omit(residuals(final_model, type = "pearson"))

par(mfrow = c(1, 2))

acf(res_final, lag.max = 60, main = "Residual ACF")

pacf(res_final, lag.max = 60, main = "Residual PACF")

Box.test(res_final, lag = 30, type = "Ljung-Box")

par(mfrow = c(1, 1))

############################################################
# Lag-response plot
############################################################

plot(pred_final, "slices", var = 10, ci = "area",
  main = "Lag-response curve for 10 µg/m3 PM2.5",
  xlab = "Lag days",
  ylab = "Relative Risk")


############################################################
# STAGE 4: Fourier seasonality sensitivity
############################################################

fourier <- harmonic(data$time, nfreq = 4, period = 365.25)

m_fourier <- glm(
  death_count ~ cbPM_final + cbTemp + fourier,
  family = quasipoisson(),
  data = data)

pr_fourier <- crosspred(cbPM_final, m_fourier, at = 10, cumul = TRUE)

############################################################
# Final sensitivity table
############################################################

sensitivity_table <- bind_rows(
  
  data.frame(
    Model = "Main final model",
    RR = pred_final$allRRfit,
    Low = pred_final$allRRlow,
    High = pred_final$allRRhigh),
  
  season_results %>%
    transmute(
      Model = paste0("Seasonal df = ", seas_df),
      RR = RR,
      Low = RRlow,
      High = RRhigh),
  
  lag_results %>%
    transmute(
      Model = paste0("Lag df = ", lag_df),
      RR = RR,
      Low = RRlow,
      High = RRhigh),
  
  data.frame(
    Model = "Fourier seasonality",
    RR = pr_fourier$allRRfit,
    Low = pr_fourier$allRRlow,
    High = pr_fourier$allRRhigh))


############################################################
# Sensitivity table plot
############################################################

ggplot(
  sensitivity_table,
  aes(x = reorder(Model, RR), y = RR)) +
  geom_point(size = 3) +
  geom_errorbar(
    aes(ymin = Low, ymax = High),
    width = 0.2) +
  coord_flip() +
  labs(
    title = "Sensitivity analysis of cumulative PM2.5 effect",
    x = "",
    y = "Cumulative RR per 10 µg/m3 PM2.5") +
  theme_bw()
