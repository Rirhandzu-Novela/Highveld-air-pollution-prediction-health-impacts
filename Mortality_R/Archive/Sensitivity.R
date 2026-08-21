library(tidyverse)
library(corrplot)
library(Hmisc)
library(tsModel)
library(splines)
library(Epi)
library(dlnm)
library(ggplot2)

# LOAD THE DATA INTO THE SESSION
data = read.csv("MortData/GertPollPulMort.csv", header = T, sep = ";")

data$date <- as.Date(data$date, format = "%Y/%m/%d")

## Repalce NAs with 0
data[is.na(data)] = 0

# SET THE DEFAULT ACTION FOR MISSING DATA TO na.exclude
# (MISSING EXCLUDED IN ESTIMATION BUT RE-INSERTED IN PREDICTION/RESIDUALS)
options(na.action = "na.exclude")

data$time <- seq(nrow(data))


#############################
# Sensitivity analysis - spline 
#############################

cutoffs <- quantile(data$temp, probs = 0:10/10)


# Sensitivity analysis 1: Varying lag and seasonal spline df

results <- expand.grid(
  lag_df    = 2:5,
  seas_df   = c(50,70,90)) %>% 
  mutate(
    fit = pmap(
      list(lag_df, seas_df),
      function(lag_df, seas_df) {
        # Rebuild seasonal spline
        spl_seas <- bs(data$time, df = seas_df, degree = 3)
        
        # Rebuild crossbasis with lag spline
        cbP <- crossbasis(data$pm2.5, lag = 14,argvar = list(fun = "lin"),
          arglag = list(fun = "ns", df = lag_df))
        
        cbtempunc <- crossbasis(data$temp, lag = c(0,14),
                                argvar = list(fun = "strata", breaks = cutoffs[2:10]),
                                arglag = list(fun = "integer"))
        
        # Fit model
        m <- glm(death_count ~ cbP  + cbtempunc + spl_seas,
                 data = data, family = quasipoisson)
        
        # Estimate dispersion
        phi <- summary(m)$dispersion
        
        # Compute QAIC: deviance / phi + 2k (standard quasi-AIC)
        k <- length(coef(m))
        qaic <- deviance(m) / phi + 2 * k
        
        # Predict cumulative RR
        pr <- crosspred(cbP, m, at = 10, cumul = TRUE)
        
        list(model = m, QAIC = qaic, cumRR = pr$allRRfit, cumLo = pr$allRRlow, cumHi = pr$allRRhigh)
      }
    ))

# Extract QAIC and RR
results_unnested <- results %>%
  mutate(
    QAIC   = map_dbl(fit, ~ .x$QAIC),
    cumRR  = map_dbl(fit, ~ .x$cumRR),
    cumLo  = map_dbl(fit, ~ .x$cumLo),
    cumHi  = map_dbl(fit, ~ .x$cumHi))

# QAIC plot
ggplot(results_unnested, aes(x = lag_df, y = QAIC, color = factor(seas_df))) +
  geom_line() +
  geom_point() +
  labs(
    title = "QAIC vs Lag-spline and Seasonal-spline df",
    x = "Lag spline df",
    y = "Quasi-AIC",
    color = "Seasonal spline df") +
  theme_minimal()

# Cumulative RR plot
ggplot(results_unnested, aes(x = lag_df, y = cumRR, color = factor(seas_df))) +
  geom_line() +
  geom_point() +
  geom_errorbar(aes(ymin = cumLo, ymax = cumHi), width = 0.1) +
  labs(
    title = "Cumulative RR vs Lag/Seasonal spline df",
    x = "Lag spline df",
    y = "Cumulative RR (per 10 μg/m³ PM2.5)",
    color = "Seasonal spline df"
  ) +
  theme_minimal()


#############################
# Sensitivity analysis - FOURIER 
#############################

results2 <- expand.grid(
  lag_df    = 2:5) %>% 
  mutate(
    fit = pmap(
      list(lag_df),
      function(lag_df) {
        
        # Rebuild crossbasis with lag spline
        cbP <- crossbasis(data$pm2.5, lag = 14, argvar = list(fun = "lin"),
          arglag = list(fun = "ns", df = lag_df))
        
        fourier <- harmonic(data$time, nfreq = 4, period = 365.25)
        
        cbtempunc <- crossbasis(data$temp, lag = c(0,14),
                                argvar = list(fun = "strata", breaks = cutoffs[2:10]),
                                arglag = list(fun = "integer"))
        
        # Fit model
        m <- glm(death_count ~ cbP + cbtempunc + fourier,
                 data = data, family = quasipoisson)
        
        # Estimate dispersion
        phi <- summary(m)$dispersion
        
        # Compute QAIC: deviance / phi + 2k (standard quasi-AIC)
        k <- length(coef(m))
        qaic <- deviance(m) / phi + 2 * k
        
        # Predict cumulative RR
        pr <- crosspred(cbP, m, at = 10, cumul = TRUE)
        
        list(model = m, QAIC = qaic, cumRR = pr$allRRfit, cumLo = pr$allRRlow, cumHi = pr$allRRhigh)
      }
    ))

# Extract QAIC and RR
results_unnested2 <- results2 %>%
  mutate(
    QAIC   = map_dbl(fit, ~ .x$QAIC),
    cumRR  = map_dbl(fit, ~ .x$cumRR),
    cumLo  = map_dbl(fit, ~ .x$cumLo),
    cumHi  = map_dbl(fit, ~ .x$cumHi))

# QAIC plot
ggplot(results_unnested2, aes(x = lag_df, y = QAIC)) +
  geom_line() +
  geom_point() +
  labs(
    title = "QAIC vs Lag-spline",
    x = "Lag spline df",
    y = "Quasi-AIC",) +
  theme_minimal()







