library(tidyverse)
library(corrplot)
library(Hmisc)
library(tsModel)
library(splines)
library(Epi)
library(dlnm)
library(ggplot2)
library(FluMoDL)

# LOAD THE DATA INTO THE SESSION
data = read.csv("C:/Users/User/Documents/GitHub/Health-impacts-of-air-pollution/MortData/GertPollPulMort.csv", header = T, sep = ";")

data$date <- as.Date(data$date, format = "%Y/%m/%d")

## Repalce NAs with 0
data[is.na(data)] = 0

# SET THE DEFAULT ACTION FOR MISSING DATA TO na.exclude
# (MISSING EXCLUDED IN ESTIMATION BUT RE-INSERTED IN PREDICTION/RESIDUALS)
options(na.action = "na.exclude")

# ADD APPARENT TEMPERATURE (TAPP) TO THE DATASET

svp <- 6.112 * 10^(7.5 * data$temp / (237.7 + data$temp))
avp <- (data$relHum * svp) / 100
dew <- (-430.22 + 237.7 * log(avp)) / (-log(avp) + 19.08)

data$tapp <- -2.653 + (0.994 * data$temp) + (0.0153 * dew)


cutoffs <- quantile(data$tapp, probs = 0:10/10)
tempdecile <- cut(data$tapp, breaks = cutoffs, include.lowest = TRUE)

# Day of week (from pre-existing DOW2 column: Monday=1 ... Sunday=7)
dow <- as.factor(data$DOW2)

# Public holiday indicator (pre-existing PublicHoliday2: 1=holiday, 0=non-holiday)
holiday <- as.factor(data$PublicHoliday2)

################################################################################
# MODELLING SEASONALITY AND LONG-TERM TREND
# (LEAVING OUT MAIN EXPOSURE FOR NOW)
############################################

#####################################
# OPTION 1: PERIODIC FUNCTIONS MODEL
# (FOURIER TERMS)
#####################################


# GENERATE FOURIER TERMS
# (USE FUNCTION harmonic, IN PACKAGE tsModel TO BE INSTALLED AND THEN LOADED)


# 4 SINE-COSINE PAIRS REPRESENTING DIFFERENT HARMONICS WITH PERIOD 1 YEAR
data$time <- seq(nrow(data))
fourier <- harmonic(data$time, nfreq = 4, period = 365.25)

#FIT A POISSON MODEL FOURIER TERMS + LINEAR TERM FOR TREND
# (USE OF quasipoisson FAMILY FOR SCALING THE STANDARD ERRORS)
model1 <- glm(death_count ~ fourier + time, data, family = quasipoisson)
#summary(model1)

# COMPUTE PREDICTED NUMBER OF DEATHS FROM THIS MODEL
pred1 <- predict(model1, type = "response")

#############
# FIGURE 1
#############

plot(data$date, data$death_count, ylim = c(0,30), pch = 19, cex = 0.2, col = grey(0.6),
     main = "Sine-cosine functions (Fourier terms)", ylab = "Daily number of deaths",
     xlab = "Date")
lines(data$date, pred1, lwd = 2)


#####################################
# OPTION 2: SPLINE MODEL
# (FLEXIBLE SPLINE FUNCTIONS)
#####################################

# GENERATE SPLINE TERMS
# (USE FUNCTION bs IN PACKAGE splines, TO BE LOADED)


# A CUBIC B-SPLINE WITH ? EQUALLY-SPACED KNOTS + ? BOUNDARY KNOTS
# (NOTE: THIS PARAMETERIZATION IS SLIGHTLY DIFFERENT THAN STATA'S)
# (THE ? BASIS VARIABLES ARE SET AS df, WITH DEFAULT KNOTS PLACEMENT. SEE ?bs)
# (OTHER TYPES OF SPLINES CAN BE PRODUCED WITH THE FUNCTION ns. SEE ?ns)
spl <- bs(data$time, degree = 3, df = 50)

# FIT A POISSON MODEL FOURIER TERMS + LINEAR TERM FOR TREND
# (USE OF quasipoisson FAMILY FOR SCALING THE STANDARD ERRORS)
model2 <- glm(death_count ~ spl, data, family = quasipoisson)
#summary(model2)

# COMPUTE PREDICTED NUMBER OF DEATHS FROM THIS MODEL
pred2 <- predict(model2, type = "response")

#############
# FIGURE 2
#############

plot(data$date, data$death_count, ylim = c(0,30), pch = 19, cex = 0.2, col = grey(0.6),
     main = "Flexible cubic spline model", ylab = "Daily number of deaths",
     xlab = "Date")
lines(data$date, pred2, lwd=2)

#####################################
# PLOT RESPONSE RESIDUALS OVER TIME
# FROM MODEL 2
#####################################

# GENERATE RESIDUALS
res2 <- residuals(model2, type = "response")

############
# FIGURE 3
############

plot(data$date, res2, ylim = c(-20,20), pch = 19, cex = 0.4, col = grey(0.6),
     main = "Residuals over time", ylab = "Residuals (observed-fitted)", xlab = "Date")
abline(h = 1, lty = 2, lwd = 2)


################################################################################
# ESTIMATING PM, SO2, NO2 - MORTALITY ASSOCIATION
############################################

# COMPARE THE RR (AND CI)
# (COMPUTED WITH THE FUNCTION ci.lin IN PACKAGE Epi


# UNADJUSTED MODEL
model3 <- glm(death_count ~ pm2.5, data, family = quasipoisson)
#summary(model3)
(eff3 <- ci.lin(model3, subset = "pm2.5", Exp = T))

model31 <- glm(death_count ~ pm10, data, family = quasipoisson)
#summary(model31)
(eff31 <- ci.lin(model31, subset = "pm10", Exp = T))

model32 <- glm(death_count ~ so2, data, family = quasipoisson)
#summary(model32)
(eff32 <- ci.lin(model32, subset = "so2", Exp = T))

model33 <- glm(death_count ~ no2, data, family = quasipoisson)
summary(model33)
(eff33 <- ci.lin(model33, subset = "no2", Exp = T))

model34 <- glm(death_count ~ pm2.5  + so2 + no2, data, family = quasipoisson)
#summary(model34)
(eff34 <- ci.lin(model34, subset = "pm2.5", Exp = T))
(eff341 <- ci.lin(model34, subset = "so2", Exp = T))
(eff342 <- ci.lin(model34, subset = "no2", Exp = T))

model35 <- glm(death_count ~ pm2.5  + so2 , data, family = quasipoisson)
#summary(model35)
(eff35 <- ci.lin(model35, subset = "pm2.5", Exp = T))
(eff351 <- ci.lin(model35, subset = "so2", Exp = T))

model36 <- glm(death_count ~ pm2.5  + no2 , data, family = quasipoisson)
#summary(model36)
(eff36 <- ci.lin(model36, subset = "pm2.5", Exp = T))
(eff361 <- ci.lin(model36, subset = "no2", Exp = T))

model37 <- glm(death_count ~ so2  + no2 , data, family = quasipoisson)
#summary(model37)
(eff37 <- ci.lin(model37, subset = "so2", Exp = T))
(eff371 <- ci.lin(model37, subset = "no2", Exp = T))

model38 <- glm(death_count ~ pm10  + so2 , data, family = quasipoisson)
#summary(model38)
(eff38 <- ci.lin(model38, subset = "pm10", Exp = T))
(eff381 <- ci.lin(model38, subset = "so2", Exp = T))

model39 <- glm(death_count ~ pm10  + no2 , data, family = quasipoisson)
#summary(model39)
(eff39 <- ci.lin(model39, subset = "pm10", Exp = T))
(eff391 <- ci.lin(model39, subset = "no2", Exp = T))

model30 <- glm(death_count ~ pm10  + so2 + no2, data, family = quasipoisson)
#summary(model30)
(eff30 <- ci.lin(model30, subset = "pm10", Exp = T))
(eff301 <- ci.lin(model30, subset = "so2", Exp = T))
(eff302 <- ci.lin(model30, subset = "no2", Exp = T))

## BUILD A SUMMARY TABLE
tabeff <- rbind(eff3,eff31,eff32,eff33,eff34,eff341,eff342,eff35,eff351,eff36,eff361,eff37,eff371,eff38,eff381,eff39,eff391,eff30,eff301,eff302)[,5:7]
dimnames(tabeff) <- list(c("PM2.5", "PM10", "SO2","NO2","PM2.5 + SO2 + NO2", "SO2 + PM2.5 + NO2", "NO2 + PM2.5 + SO2", "PM2.5 + SO2", 
                           "SO2 + PM2.5", "PM2.5 + NO2", "NO2 + PM2.5", "SO2 + NO2", "NO2 + SO2", "PM10 + SO2", "SO2 + PM10",
                           "PM10 + NO2", "NO2 + PM10", "PM10 + SO2 + NO2", "SO2 + PM10 + NO2", "NO2 + PM10 + SO2"),
                         c("RR","ci.low","ci.hi"))


# CONTROLLING FOR SEASONALITY AND LONG-TERM TREND (WITH SPLINE)
model4 <- update(model3, .~. + spl + tempdecile + dow + holiday)
#summary(model4)
(eff4 <- ci.lin(model4, subset = "pm2.5", Exp = T))

model41 <- update(model31, .~. + spl + tempdecile + dow + holiday)
#summary(model41)
(eff41 <- ci.lin(model41, subset = "pm10", Exp = T))

model42 <- update(model32, .~. + spl + tempdecile + dow + holiday)
#summary(model42)
(eff42 <- ci.lin(model42, subset = "so2", Exp = T))

model43 <- update(model33, .~. + spl + tempdecile + dow + holiday)
#summary(model43)
(eff43 <- ci.lin(model43, subset = "no2", Exp = T))

model44 <- update(model34, .~. + spl + tempdecile + dow + holiday)
#summary(model44)
(eff44 <- ci.lin(model44, subset = "pm2.5", Exp = T))
(eff441 <- ci.lin(model44, subset = "so2", Exp = T))
(eff442 <- ci.lin(model44, subset = "no2", Exp = T))

model45 <- update(model35, .~. + spl + tempdecile + dow + holiday)
#summary(model45)
(eff45 <- ci.lin(model45, subset = "pm2.5", Exp = T))
(eff451 <- ci.lin(model45, subset = "so2", Exp = T))

model46 <- update(model36, .~. + spl + tempdecile + dow + holiday)
#summary(model46)
(eff46 <- ci.lin(model46, subset = "pm2.5", Exp = T))
(eff461 <- ci.lin(model46, subset = "no2", Exp = T))

model47 <- update(model37, .~. + spl + tempdecile + dow + holiday)
#summary(model47)
(eff47 <- ci.lin(model47, subset = "so2", Exp = T))
(eff471 <- ci.lin(model47, subset = "no2", Exp = T))

model48 <- update(model38, .~. + spl + tempdecile + dow + holiday)
#summary(model48)
(eff48 <- ci.lin(model48, subset = "pm10", Exp = T))
(eff481 <- ci.lin(model48, subset = "so2", Exp = T))

model49 <- update(model39, .~. + spl + tempdecile + dow + holiday)
#summary(model49)
(eff49 <- ci.lin(model49, subset = "pm10", Exp = T))
(eff491 <- ci.lin(model49, subset = "no2", Exp = T))

model40 <- update(model30, .~. + spl + tempdecile + dow + holiday)
#summary(model40)
(eff40 <- ci.lin(model40, subset = "pm10", Exp = T))
(eff401 <- ci.lin(model40, subset = "so2", Exp = T))
(eff402 <- ci.lin(model40, subset = "no2", Exp = T))

## BUILD A SUMMARY TABLE
tabeff <- rbind(eff4,eff41,eff42,eff43,eff44,eff441,eff442,eff45,eff451,eff46,eff461,eff47,eff471,eff48,eff481,eff49,eff491,eff40,eff401,eff402)[,5:7]
dimnames(tabeff) <- list(c("PM2.5", "PM10", "SO2","NO2","PM2.5 + SO2 + NO2", "SO2 + PM2.5 + NO2", "NO2 + PM2.5 + SO2", "PM2.5 + SO2",
                           "SO2 + PM2.5", "PM2.5 + NO2", "NO2 + PM2.5", "SO2 + NO2", "NO2 + SO2",  "PM10 + SO2", "SO2 + PM10", 
                           "PM10 + NO2", "NO2 + PM10", "PM10 + SO2 + NO2", "SO2 + PM10 + NO2", "NO2 + PM10 + SO2"),
                         c("RR","ci.low","ci.hi"))
round(tabeff,3)

# CONTROLLING FOR SEASONALITY AND LONG-TERM TREND (WITH Fourier)
model0 <- update(model3, .~. + fourier + tempdecile + dow + holiday)
#summary(model0)
(eff0 <- ci.lin(model0, subset = "pm2.5", Exp = T))

model01 <- update(model31, .~. + fourier + tempdecile + dow + holiday)
#summary(model01)
(eff01 <- ci.lin(model01, subset = "pm10", Exp = T))

model02 <- update(model32, .~. + fourier + tempdecile + dow + holiday)
#summary(model02)
(eff02 <- ci.lin(model02, subset = "so2", Exp = T))

model03 <- update(model33, .~. + fourier + tempdecile + dow + holiday)
#summary(model03)
(eff03 <- ci.lin(model03, subset = "no2", Exp = T))

model04 <- update(model34, .~. + fourier + tempdecile + dow + holiday)
#summary(model04)
(eff04 <- ci.lin(model04, subset = "pm2.5", Exp = T))
(eff041 <- ci.lin(model04, subset = "so2", Exp = T))
(eff042 <- ci.lin(model04, subset = "no2", Exp = T))

model05 <- update(model35, .~. + fourier + tempdecile + dow + holiday)
#summary(model05)
(eff05 <- ci.lin(model05, subset = "pm2.5", Exp = T))
(eff051 <- ci.lin(model05, subset = "so2", Exp = T))

model06 <- update(model36, .~. + fourier + tempdecile + dow + holiday)
#summary(model06)
(eff06 <- ci.lin(model06, subset = "pm2.5", Exp = T))
(eff061 <- ci.lin(model06, subset = "no2", Exp = T))

model07 <- update(model37, .~. + fourier + tempdecile + dow + holiday)
#summary(model07)
(eff07 <- ci.lin(model07, subset = "so2", Exp = T))
(eff071 <- ci.lin(model07, subset = "no2", Exp = T))

model08 <- update(model38, .~. + fourier + tempdecile + dow + holiday)
#summary(model08)
(eff08 <- ci.lin(model08, subset = "pm10", Exp = T))
(eff081 <- ci.lin(model08, subset = "so2", Exp = T))

model09 <- update(model39, .~. + fourier + tempdecile + dow + holiday)
#summary(model09)
(eff09 <- ci.lin(model09, subset = "pm10", Exp = T))
(eff091 <- ci.lin(model09, subset = "no2", Exp = T))

model00 <- update(model30, .~. + fourier + tempdecile + dow + holiday)
#summary(model00)
(eff00 <- ci.lin(model00, subset = "pm10", Exp = T))
(eff001 <- ci.lin(model00, subset = "so2", Exp = T))
(eff002 <- ci.lin(model00, subset = "no2", Exp = T))

## BUILD A SUMMARY TABLE
tabeff <- rbind(eff0,eff01,eff02,eff03,eff04,eff041,eff042,eff05,eff051,eff06,eff061,eff07,eff071,eff08,eff081,eff09,eff091,eff00,eff001,eff002)[,5:7]
dimnames(tabeff) <- list(c("PM2.5", "PM10", "SO2","NO2","PM2.5 + SO2 + NO2", "SO2 + PM2.5 + NO2", "NO2 + PM2.5 + SO2", "PM2.5 + SO2", 
                           "SO2 + PM2.5", "PM2.5 + NO2", "NO2 + PM2.5", "SO2 + NO2", "NO2 + SO2", "PM10 + SO2", "SO2 + PM10",
                           "PM10 + NO2", "NO2 + PM10", "PM10 + SO2 + NO2", "SO2 + PM10 + NO2", "NO2 + PM10 + SO2"),
                         c("RR","ci.low","ci.hi"))
round(tabeff,3)


tabeff <- tabeff |> 
  as.data.frame()

tabeff <- tabeff |>
  mutate(
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100)

write.csv(tabeff,"Data/GertPollPulMortdeath_count.csv")


################################################################################
# EXPLORING THE LAGGED (DELAYED) EFFECTS
############################################

####################################
# CONSTRAINED (LAG-STRATIFIED) DLM
####################################


# CONSTRAINED (LAG-STRATIFIED) DLM ----------------------------------------

# PRODUCE A DIFFERENT CROSS-BASIS FOR POLL
# USE STRATA FOR LAG STRUCTURE, WITH CUT-OFFS DEFINING RIGHT-OPEN INTERVALS 

# cbpm2constr <- crossbasis(data$pm2.5, lag = c(0,7), argvar = list(fun = "lin"),
#                           arglag = list(fun = "strata", breaks = c(1,3)))
# summary(cbpm2constr)

cbpm2constr <- crossbasis(data$pm2.5, lag = c(0,14), argvar = list(fun = "lin"),
                          arglag = list(fun="ns", df=3))
#summary(cbpm2constr)


cbpm1constr <- crossbasis(data$pm10, lag = c(0,14), argvar = list(fun = "lin"),
                          arglag = list(fun="ns", df=3))
#summary(cbpm1constr)

cbsoconstr <- crossbasis(data$so2, lag = c(0,14), argvar = list(fun = "lin"),
                         arglag = list(fun="ns", df=3))
#summary(cbsoconstr)

cbnoconstr <- crossbasis(data$no2, lag = c(0,14), argvar = list(fun = "lin"),
                         arglag = list(fun="ns", df=3))
#summary(cbnoconstr)



# Temperature cross-basis uses apparent temperature (TAPP) and tapp-based decile cutoffs
cbtempunc <- crossbasis(data$tapp, lag = c(0,14),
                        argvar = list(fun = "strata", breaks = cutoffs[2:10]),
                        arglag = list(fun = "integer"))
#summary(cbtempunc)


# RUN THE MODEL AND OBTAIN PREDICTIONS FOR PM2.5 LEVEL 10ug/m3
model8 <- glm(death_count ~ cbpm2constr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred8 <- crosspred(cbpm2constr, model8, at = 10, cumul  = TRUE)
#summary(model8)

# ESTIMATED EFFECTS AT EACH LAG
tablag3 <- with(pred8,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag3) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag3 <- tablag3 |> 
  as.data.frame()

tablag3 <- tablag3 |>
  mutate(
    Pollutant = "PM2.5",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag3 <- rownames_to_column(tablag3, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred8, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ug/m3 PM2.5 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred8, var = 10,  cumul = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ug/m3 PM2.5 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for PM2.5 (single pollutant)
an8 <- attrdl(x = data$pm2.5, basis = cbpm2constr, cases = data$death_count, model = model8,
  type = "an", dir = "forw", tot = TRUE, cen = 5)

af8 <- attrdl(x = data$pm2.5, basis = cbpm2constr, cases = data$death_count, model = model8,
  type = "af", dir = "forw", tot = TRUE, cen = 5)


af_sim8 <- attrdl(x = data$pm2.5, basis = cbpm2constr, cases = data$death_count, model = model8,
  type = "af", dir = "forw", tot = TRUE, cen = 5, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an8), "\n")
cat("Attributable fraction:", round(af8 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim8, 0.025) * 100, 2), "% -", round(quantile(af_sim8, 0.975) * 100, 2), "%\n")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR PM10 LEVEL 10ug/m3
model81 <- glm(death_count ~ cbpm1constr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred81 <- crosspred(cbpm1constr, model81, at = 10, cumul  = TRUE)
#summary(model81)

# ESTIMATED EFFECTS AT EACH LAG
tablag31 <- with(pred81,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag31) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag31 <- tablag31 |> 
  as.data.frame()

tablag31 <- tablag31 |>
  mutate(
    Pollutant = "PM10",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag31 <- rownames_to_column(tablag31, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred81, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ug/m3 PM10 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred81, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ug/m3 PM10 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for PM10 (single pollutant)
an81 <- attrdl(x = data$pm10, basis = cbpm1constr, cases = data$death_count, model = model81,
                 type = "an", dir = "forw", tot = TRUE, cen = 15)

af81 <- attrdl(x = data$pm10, basis = cbpm1constr, cases = data$death_count, model = model81,
                 type = "af", dir = "forw", tot = TRUE, cen = 15)


af_sim81 <- attrdl(x = data$pm10, basis = cbpm1constr, cases = data$death_count, model = model81,
                 type = "af", dir = "forw", tot = TRUE, cen = 15, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an81), "\n")
cat("Attributable fraction:", round(af81 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim81, 0.025) * 100, 2), "% -", round(quantile(af_sim81, 0.975) * 100, 2), "%\n")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR SO2 LEVEL 10ppb
model82 <- glm(death_count ~ cbsoconstr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred82 <- crosspred(cbsoconstr, model82, at = 10, cumul  = TRUE)
#summary(model82)

# ESTIMATED EFFECTS AT EACH LAG
tablag32 <- with(pred82,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag32) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag32 <- tablag32 |> 
  as.data.frame()

tablag32 <- tablag32 |>
  mutate(
    Pollutant = "SO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag32 <- rownames_to_column(tablag32, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred82, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred82, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for SO2 (single pollutant)
an82 <- attrdl(x = data$so2, basis = cbsoconstr, cases = data$death_count, model = model82,
                 type = "an", dir = "forw", tot = TRUE, cen = 7.63)

af82 <- attrdl(x = data$so2, basis = cbsoconstr, cases = data$death_count, model = model82,
                 type = "af", dir = "forw", tot = TRUE, cen = 7.63)


af_sim82 <- attrdl(x = data$so2, basis = cbsoconstr, cases = data$death_count, model = model82,
                     type = "af", dir = "forw", tot = TRUE, cen = 7.63, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an82), "\n")
cat("Attributable fraction:", round(af82 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim82, 0.025) * 100, 2), "% -", round(quantile(af_sim82, 0.975) * 100, 2), "%\n")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR NO2 LEVEL 10ppb
model83 <- glm(death_count ~ cbnoconstr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred83 <- crosspred(cbnoconstr, model83, at = 10, cumul  = TRUE)
#summary(model83)

# ESTIMATED EFFECTS AT EACH LAG
tablag33 <- with(pred83,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag33) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag33 <- tablag33 |> 
  as.data.frame()

tablag33 <- tablag33 |>
  mutate(
    Pollutant = "NO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)


tablag33 <- rownames_to_column(tablag33, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred83, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred83, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for NO2 (single pollutant)
an83 <- attrdl(x = data$no2, basis = cbnoconstr, cases = data$death_count, model = model83,
                type = "an", dir = "forw", tot = TRUE, cen = 5.3)

af83 <- attrdl(x = data$no2, basis = cbnoconstr, cases = data$death_count, model = model83,
                type = "af", dir = "forw", tot = TRUE, cen = 5.3)


af_sim83 <- attrdl(x = data$no2, basis = cbnoconstr, cases = data$death_count, model = model83,
                    type = "af", dir = "forw", tot = TRUE, cen = 5.3, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an83), "\n")
cat("Attributable fraction:", round(af83 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim83, 0.025) * 100, 2), "% -", round(quantile(af_sim83, 0.975) * 100, 2), "%\n")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR PM2.5 + SO2 + NO2 LEVEL 10ug/m3
model84 <- glm(death_count ~ cbpm2constr + cbsoconstr + cbnoconstr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred84 <- crosspred(cbpm2constr, model84, at = 10, cumul  = TRUE)
#summary(model84)

# ESTIMATED EFFECTS AT EACH LAG
tablag34 <- with(pred84,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag34) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag34 <- tablag34 |> 
  as.data.frame()

tablag34 <- tablag34 |>
  mutate(
    Pollutant = "PM2.5 + SO2 + NO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag34 <- rownames_to_column(tablag34, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred84, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ug/m3 PM2.5 + SO2 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred84, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ug/m3 PM2.5 + SO2 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for PM2.5 + SO2 + NO2
an84 <- attrdl(x = data$pm2.5, basis = cbpm2constr, cases = data$death_count, model = model84,
              type = "an", dir = "forw", tot = TRUE, cen = 5)

af84 <- attrdl(x = data$pm2.5, basis = cbpm2constr, cases = data$death_count, model = model84,
              type = "af", dir = "forw", tot = TRUE, cen = 5)


af_sim84 <- attrdl(x = data$pm2.5, basis = cbpm2constr, cases = data$death_count, model = model84,
                  type = "af", dir = "forw", tot = TRUE, cen = 5, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an84), "\n")
cat("Attributable fraction:", round(af84 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim84, 0.025) * 100, 2), "% -", round(quantile(af_sim84, 0.975) * 100, 2), "%\n")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR SO2 + PM2.5 + NO2 LEVEL 10ppb
model841 <- glm(death_count ~ cbsoconstr + cbpm2constr + cbnoconstr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred841 <- crosspred(cbsoconstr, model841, at = 10, cumul  = TRUE)
#summary(model841)

# ESTIMATED EFFECTS AT EACH LAG
tablag341 <- with(pred841,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag341) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag341 <- tablag341 |> 
  as.data.frame()

tablag341 <- tablag341 |>
  mutate(
    Pollutant = "SO2 + PM2.5 + NO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag341 <- rownames_to_column(tablag341, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred841, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ug/m3 SO2 + PM2.5 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred841, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ug/m3 SO2 + PM2.5 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for SO2 + PM2.5 + NO2
an841 <- attrdl(x = data$so2, basis = cbsoconstr, cases = data$death_count, model = model841,
               type = "an", dir = "forw", tot = TRUE, cen = 7.63)

af841 <- attrdl(x = data$so2, basis = cbsoconstr, cases = data$death_count, model = model841,
               type = "af", dir = "forw", tot = TRUE, cen = 7.63)


af_sim841 <- attrdl(x = data$so2, basis = cbsoconstr, cases = data$death_count, model = model841,
                   type = "af", dir = "forw", tot = TRUE, cen = 7.63, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an841), "\n")
cat("Attributable fraction:", round(af841 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim841, 0.025) * 100, 2), "% -", round(quantile(af_sim841, 0.975) * 100, 2), "%\n")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR NO2 + PM2.5 + SO2 LEVEL 10ppb
model842 <- glm(death_count ~ cbnoconstr + cbpm2constr + cbsoconstr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred842 <- crosspred(cbnoconstr, model842, at = 10, cumul  = TRUE)
#summary(model842)

# ESTIMATED EFFECTS AT EACH LAG
tablag342 <- with(pred842,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag342) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag342 <- tablag342 |> 
  as.data.frame()

tablag342 <- tablag342 |>
  mutate(
    Pollutant = "NO2 + PM2.5 + SO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag342 <- rownames_to_column(tablag342, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred842, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ug/m3 NO2 + PM2.5 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred842, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ug/m3 NO2 + PM2.5 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for NO2 + PM2.5 + SO2
an842 <- attrdl(x = data$no2, basis = cbnoconstr, cases = data$death_count, model = model842,
               type = "an", dir = "forw", tot = TRUE, cen = 5.3)

af842 <- attrdl(x = data$no2, basis = cbnoconstr, cases = data$death_count, model = model842,
               type = "af", dir = "forw", tot = TRUE, cen = 5.3)


af_sim842 <- attrdl(x = data$no2, basis = cbnoconstr, cases = data$death_count, model = model842,
                   type = "af", dir = "forw", tot = TRUE, cen = 5.3, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an842), "\n")
cat("Attributable fraction:", round(af842 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim842, 0.025) * 100, 2), "% -", round(quantile(af_sim842, 0.975) * 100, 2), "%\n")


# RUN THE MODEL AND OBTAIN PREDICTIONS FOR PM2.5 + SO2 LEVEL 10ug/m3
model85 <- glm(death_count ~ cbpm2constr + cbsoconstr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred85 <- crosspred(cbpm2constr, model85, at = 10, cumul  = TRUE)
#summary(model85)

# ESTIMATED EFFECTS AT EACH LAG
tablag35 <- with(pred85,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag35) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag35 <- tablag35 |> 
  as.data.frame()

tablag35 <- tablag35 |>
  mutate(
    Pollutant = "PM2.5 + SO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag35 <- rownames_to_column(tablag35, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred85, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb PM2.5 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred85, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb PM2.5 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for PM2.5 + SO2
an85 <- attrdl(x = data$pm2.5, basis = cbpm2constr, cases = data$death_count, model = model85,
              type = "an", dir = "forw", tot = TRUE, cen = 5)

af85 <- attrdl(x = data$pm2.5, basis = cbpm2constr, cases = data$death_count, model = model85,
              type = "af", dir = "forw", tot = TRUE, cen = 5)


af_sim85 <- attrdl(x = data$pm2.5, basis = cbpm2constr, cases = data$death_count, model = model85,
                  type = "af", dir = "forw", tot = TRUE, cen = 5, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an85), "\n")
cat("Attributable fraction:", round(af85 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim85, 0.025) * 100, 2), "% -", round(quantile(af_sim85, 0.975) * 100, 2), "%\n")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR SO2 + PM2.5 LEVEL 10ppb
model851 <- glm(death_count ~ cbsoconstr + cbpm2constr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred851 <- crosspred(cbsoconstr, model851, at = 10, cumul  = TRUE)
#summary(model851)

# ESTIMATED EFFECTS AT EACH LAG
tablag351 <- with(pred851,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag351) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag351 <- tablag351 |> 
  as.data.frame()

tablag351 <- tablag351 |>
  mutate(
    Pollutant = "SO2 + PM2.5",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag351 <- rownames_to_column(tablag351, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred851, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb SO2 + PM2.5 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred851, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb SO2 + PM2.5 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for SO2 + PM2.5
an851 <- attrdl(x = data$so2, basis = cbsoconstr, cases = data$death_count, model = model851,
               type = "an", dir = "forw", tot = TRUE, cen = 7.63)

af851 <- attrdl(x = data$so2, basis = cbsoconstr, cases = data$death_count, model = model851,
               type = "af", dir = "forw", tot = TRUE, cen = 7.63)


af_sim851 <- attrdl(x = data$so2, basis = cbsoconstr, cases = data$death_count, model = model851,
                   type = "af", dir = "forw", tot = TRUE, cen = 7.63, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an851), "\n")
cat("Attributable fraction:", round(af851 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim851, 0.025) * 100, 2), "% -", round(quantile(af_sim851, 0.975) * 100, 2), "%\n")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR PM2.5 + NO2 LEVEL 10ug/m3
model86 <- glm(death_count ~ cbpm2constr + cbnoconstr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred86 <- crosspred(cbpm2constr, model86, at = 10, cumul  = TRUE)
#summary(model86)

# ESTIMATED EFFECTS AT EACH LAG
tablag36 <- with(pred86,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag36) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag36 <- tablag36 |> 
  as.data.frame()

tablag36 <- tablag36 |>
  mutate(
    Pollutant = "PM2.5 + NO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag36 <- rownames_to_column(tablag36, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred86, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb PM2.5 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred86, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb PM2.5 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for PM2.5 + NO2
an86 <- attrdl(x = data$pm2.5, basis = cbpm2constr, cases = data$death_count, model = model86,
              type = "an", dir = "forw", tot = TRUE, cen = 5)

af86 <- attrdl(x = data$pm2.5, basis = cbpm2constr, cases = data$death_count, model = model86,
              type = "af", dir = "forw", tot = TRUE, cen = 5)


af_sim86 <- attrdl(x = data$pm2.5, basis = cbpm2constr, cases = data$death_count, model = model86,
                  type = "af", dir = "forw", tot = TRUE, cen = 5, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an86), "\n")
cat("Attributable fraction:", round(af86 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim86, 0.025) * 100, 2), "% -", round(quantile(af_sim86, 0.975) * 100, 2), "%\n")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR NO2 + PM2.5 LEVEL 10ppb
model861 <- glm(death_count ~ cbnoconstr + cbpm2constr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred861 <- crosspred(cbnoconstr, model861, at = 10, cumul  = TRUE)
#summary(model861)

# ESTIMATED EFFECTS AT EACH LAG
tablag361 <- with(pred861,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag361) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag361 <- tablag361 |> 
  as.data.frame()

tablag361 <- tablag361 |>
  mutate(
    Pollutant = "NO2 + PM2.5",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag361 <- rownames_to_column(tablag361, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred861, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb NO2 + PM2.5 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred861, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb NO2 + PM2.5 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for NO2 + PM2.5
an861 <- attrdl(x = data$no2, basis = cbnoconstr, cases = data$death_count, model = model861,
               type = "an", dir = "forw", tot = TRUE, cen = 5.3)

af861 <- attrdl(x = data$no2, basis = cbnoconstr, cases = data$death_count, model = model861,
               type = "af", dir = "forw", tot = TRUE, cen = 5.3)


af_sim861 <- attrdl(x = data$no2, basis = cbnoconstr, cases = data$death_count, model = model861,
                   type = "af", dir = "forw", tot = TRUE, cen = 5.3, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an861), "\n")
cat("Attributable fraction:", round(af861 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim861, 0.025) * 100, 2), "% -", round(quantile(af_sim861, 0.975) * 100, 2), "%\n")


# RUN THE MODEL AND OBTAIN PREDICTIONS FOR SO2 + NO2 LEVEL 10ppb
model87 <- glm(death_count ~ cbsoconstr + cbnoconstr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred87 <- crosspred(cbsoconstr, model87, at = 10, cumul  = TRUE)
#summary(model87)

# ESTIMATED EFFECTS AT EACH LAG
tablag37 <- with(pred87,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag37) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag37 <- tablag37 |> 
  as.data.frame()

tablag37 <- tablag37 |>
  mutate(
    Pollutant = "SO2 + NO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag37 <- rownames_to_column(tablag37, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred87, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb SO2 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred87, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb SO2 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for SO2 + NO2
an87 <- attrdl(x = data$so2, basis = cbsoconstr, cases = data$death_count, model = model87,
               type = "an", dir = "forw", tot = TRUE, cen = 7.63)

af87 <- attrdl(x = data$so2, basis = cbsoconstr, cases = data$death_count, model = model87,
               type = "af", dir = "forw", tot = TRUE, cen = 7.63)


af_sim87 <- attrdl(x = data$so2, basis = cbsoconstr, cases = data$death_count, model = model87,
                   type = "af", dir = "forw", tot = TRUE, cen = 7.63, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an87), "\n")
cat("Attributable fraction:", round(af87 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim87, 0.025) * 100, 2), "% -", round(quantile(af_sim87, 0.975) * 100, 2), "%\n")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR NO2 + SO2 LEVEL 10ppb
model871 <- glm(death_count ~ cbnoconstr + cbsoconstr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred871 <- crosspred(cbnoconstr, model871, at = 10, cumul  = TRUE)
#summary(model871)

# ESTIMATED EFFECTS AT EACH LAG
tablag371 <- with(pred871,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag371) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag371 <- tablag371 |> 
  as.data.frame()

tablag371 <- tablag371 |>
  mutate(
    Pollutant = "NO2 + SO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag371 <- rownames_to_column(tablag371, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred871, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb NO2 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred871, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb NO2 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for NO2 + SO2
an871 <- attrdl(x = data$no2, basis = cbnoconstr, cases = data$death_count, model = model871,
               type = "an", dir = "forw", tot = TRUE, cen = 5.3)

af871 <- attrdl(x = data$no2, basis = cbnoconstr, cases = data$death_count, model = model871,
               type = "af", dir = "forw", tot = TRUE, cen = 5.3)


af_sim871 <- attrdl(x = data$no2, basis = cbnoconstr, cases = data$death_count, model = model871,
                   type = "af", dir = "forw", tot = TRUE, cen = 5.3, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an871), "\n")
cat("Attributable fraction:", round(af871 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim871, 0.025) * 100, 2), "% -", round(quantile(af_sim871, 0.975) * 100, 2), "%\n")


# RUN THE MODEL AND OBTAIN PREDICTIONS FOR PM10 + SO2 LEVEL 10ug/m3
model88 <- glm(death_count ~ cbpm1constr + cbsoconstr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred88 <- crosspred(cbpm1constr, model88, at = 10, cumul  = TRUE)
#summary(model88)

# ESTIMATED EFFECTS AT EACH LAG
tablag38 <- with(pred88,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag38) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag38 <- tablag38 |> 
  as.data.frame()

tablag38 <- tablag38 |>
  mutate(
    Pollutant = "PM10 + SO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag38 <- rownames_to_column(tablag38, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred88, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb PM10 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred88, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb PM10 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for PM10 + SO2
an88 <- attrdl(x = data$pm10, basis = cbpm1constr, cases = data$death_count, model = model88,
               type = "an", dir = "forw", tot = TRUE, cen = 15)

af88 <- attrdl(x = data$pm10, basis = cbpm1constr, cases = data$death_count, model = model88,
               type = "af", dir = "forw", tot = TRUE, cen = 15)


af_sim88 <- attrdl(x = data$pm10, basis = cbpm1constr, cases = data$death_count, model = model88,
                   type = "af", dir = "forw", tot = TRUE, cen = 15, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an88), "\n")
cat("Attributable fraction:", round(af88 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim88, 0.025) * 100, 2), "% -", round(quantile(af_sim88, 0.975) * 100, 2), "%\n")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR SO2 + PM10 LEVEL 10ppb
model881 <- glm(death_count ~ cbsoconstr + cbpm1constr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred881 <- crosspred(cbsoconstr, model881, at = 10, cumul  = TRUE)
#summary(model881)

# ESTIMATED EFFECTS AT EACH LAG
tablag381 <- with(pred881,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag381) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag381 <- tablag381 |> 
  as.data.frame()

tablag381 <- tablag381 |>
  mutate(
    Pollutant = "SO2 + PM10",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag381 <- rownames_to_column(tablag381, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred881, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb SO2 + PM10 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred881, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb SO2 + PM10 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for SO2 + PM10
an881 <- attrdl(x = data$so2, basis = cbsoconstr, cases = data$death_count, model = model881,
               type = "an", dir = "forw", tot = TRUE, cen = 7.63)

af881 <- attrdl(x = data$so2, basis = cbsoconstr, cases = data$death_count, model = model881,
               type = "af", dir = "forw", tot = TRUE, cen = 7.63)


af_sim881 <- attrdl(x = data$so2, basis = cbsoconstr, cases = data$death_count, model = model881,
                   type = "af", dir = "forw", tot = TRUE, cen = 7.63, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an881), "\n")
cat("Attributable fraction:", round(af881 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim881, 0.025) * 100, 2), "% -", round(quantile(af_sim881, 0.975) * 100, 2), "%\n")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR PM10 + NO2 LEVEL 10ug/m3
model89 <- glm(death_count ~ cbpm1constr + cbnoconstr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred89 <- crosspred(cbpm1constr, model89, at = 10, cumul  = TRUE)
#summary(model89)

# ESTIMATED EFFECTS AT EACH LAG
tablag39 <- with(pred89,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag39) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag39 <- tablag39 |> 
  as.data.frame()

tablag39 <- tablag39 |>
  mutate(
    Pollutant = "PM10 + NO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag39 <- rownames_to_column(tablag39, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred89, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb PM10 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred89, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb PM10 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for PM10 + NO2
an89 <- attrdl(x = data$pm10, basis = cbpm1constr, cases = data$death_count, model = model89,
               type = "an", dir = "forw", tot = TRUE, cen = 15)

af89 <- attrdl(x = data$pm10, basis = cbpm1constr, cases = data$death_count, model = model89,
               type = "af", dir = "forw", tot = TRUE, cen = 15)


af_sim89 <- attrdl(x = data$pm10, basis = cbpm1constr, cases = data$death_count, model = model89,
                   type = "af", dir = "forw", tot = TRUE, cen = 15, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an89), "\n")
cat("Attributable fraction:", round(af89 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim89, 0.025) * 100, 2), "% -", round(quantile(af_sim89, 0.975) * 100, 2), "%\n")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR NO2 + PM10 LEVEL 10ppb
model891 <- glm(death_count ~ cbnoconstr + cbpm1constr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred891 <- crosspred(cbnoconstr, model891, at = 10, cumul  = TRUE)
#summary(model891)

# ESTIMATED EFFECTS AT EACH LAG
tablag391 <- with(pred891,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag391) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag391 <- tablag391 |> 
  as.data.frame()

tablag391 <- tablag391 |>
  mutate(
    Pollutant = "NO2 + PM10",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag391 <- rownames_to_column(tablag391, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred891, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb NO2 + PM10 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred891, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ppb NO2 + PM10 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for NO2 + PM10
an891 <- attrdl(x = data$no2, basis = cbnoconstr, cases = data$death_count, model = model891,
               type = "an", dir = "forw", tot = TRUE, cen = 5.3)

af891 <- attrdl(x = data$no2, basis = cbnoconstr, cases = data$death_count, model = model891,
               type = "af", dir = "forw", tot = TRUE, cen = 5.3)


af_sim891 <- attrdl(x = data$no2, basis = cbnoconstr, cases = data$death_count, model = model891,
                   type = "af", dir = "forw", tot = TRUE, cen = 5.3, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an891), "\n")
cat("Attributable fraction:", round(af891 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim891, 0.025) * 100, 2), "% -", round(quantile(af_sim891, 0.975) * 100, 2), "%\n")


# RUN THE MODEL AND OBTAIN PREDICTIONS FOR PM10 + SO2 + NO2 LEVEL 10ug/m3
model80 <- glm(death_count ~ cbpm1constr + cbsoconstr + cbnoconstr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred80 <- crosspred(cbpm1constr, model80, at = 10, cumul  = TRUE)
#summary(model80)

# ESTIMATED EFFECTS AT EACH LAG
tablag30 <- with(pred80,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag30) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag30 <- tablag30 |> 
  as.data.frame()

tablag30 <- tablag30 |>
  mutate(
    Pollutant = "PM10 + SO2 + NO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag30 <- rownames_to_column(tablag30, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred80, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ug/m3 PM10 + SO2 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred80, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ug/m3 PM10 + SO2 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for PM10 + SO2 + NO2
an80 <- attrdl(x = data$pm10, basis = cbpm1constr, cases = data$death_count, model = model80,
               type = "an", dir = "forw", tot = TRUE, cen = 15)

af80 <- attrdl(x = data$pm10, basis = cbpm1constr, cases = data$death_count, model = model80,
               type = "af", dir = "forw", tot = TRUE, cen = 15)


af_sim80 <- attrdl(x = data$pm10, basis = cbpm1constr, cases = data$death_count, model = model80,
                   type = "af", dir = "forw", tot = TRUE, cen = 15, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an80), "\n")
cat("Attributable fraction:", round(af80 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim80, 0.025) * 100, 2), "% -", round(quantile(af_sim80, 0.975) * 100, 2), "%\n")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR SO2 + PM10 + NO2 LEVEL 10ppb
model801 <- glm(death_count ~ cbsoconstr + cbpm1constr + cbnoconstr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred801 <- crosspred(cbsoconstr, model801, at = 10, cumul  = TRUE)
#summary(model801)

# ESTIMATED EFFECTS AT EACH LAG
tablag301 <- with(pred801,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag301) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag301 <- tablag301 |> 
  as.data.frame()

tablag301 <- tablag301 |>
  mutate(
    Pollutant = "SO2 + PM10 + NO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag301 <- rownames_to_column(tablag301, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred801, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ug/m3 SO2 + PM10 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred801, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ug/m3 SO2 + PM10 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for SO2 + PM10 + NO2
an801 <- attrdl(x = data$so2, basis = cbsoconstr, cases = data$death_count, model = model801,
               type = "an", dir = "forw", tot = TRUE, cen = 7.63)

af801 <- attrdl(x = data$so2, basis = cbsoconstr, cases = data$death_count, model = model801,
               type = "af", dir = "forw", tot = TRUE, cen = 7.63)


af_sim801 <- attrdl(x = data$so2, basis = cbsoconstr, cases = data$death_count, model = model801,
                   type = "af", dir = "forw", tot = TRUE, cen = 7.63, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an801), "\n")
cat("Attributable fraction:", round(af801 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim801, 0.025) * 100, 2), "% -", round(quantile(af_sim801, 0.975) * 100, 2), "%\n")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR NO2 + PM10 + SO2 LEVEL 10ppb
model802 <- glm(death_count ~ cbnoconstr + cbpm1constr + cbsoconstr + cbtempunc + fourier + dow + holiday, data, family = quasipoisson)
pred802 <- crosspred(cbnoconstr, model802, at = 10, cumul  = TRUE)
#summary(model802)

# ESTIMATED EFFECTS AT EACH LAG
tablag302 <- with(pred802,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag302) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag302 <- tablag302 |> 
  as.data.frame()

tablag302 <- tablag302 |>
  mutate(
    Pollutant = "NO2 + PM10 + SO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

tablag302 <- rownames_to_column(tablag302, var = "lag")


# PLOT THE LAGGED EFFECTS
plot(pred802, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ug/m3 NO2 + PM10 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

plot(pred802, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.1),
     main = "RR and 95% CI per 10 ug/m3 NO2 + PM10 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95% CI")

# Attributable fraction and number for NO2 (single pollutant)
an802 <- attrdl(x = data$no2, basis = cbnoconstr, cases = data$death_count, model = model802,
               type = "an", dir = "forw", tot = TRUE, cen = 5.3)

af802 <- attrdl(x = data$no2, basis = cbnoconstr, cases = data$death_count, model = model802,
               type = "af", dir = "forw", tot = TRUE, cen = 5.3)


af_sim802 <- attrdl(x = data$no2, basis = cbnoconstr, cases = data$death_count, model = model802,
                   type = "af", dir = "forw", tot = TRUE, cen = 5.3, sim = TRUE, nsim = 1000)

cat("Attributable deaths:", round(an802), "\n")
cat("Attributable fraction:", round(af802 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim802, 0.025) * 100, 2), "% -", round(quantile(af_sim802, 0.975) * 100, 2), "%\n")


# SAVE THE RESULTS

GertPollPulMortPM2death_count <- rbind(tablag3, tablag35, tablag36, tablag34)
write.csv(GertPollPulMortPM2death_count,"Data/GertPollPulMortPM2death_count.csv")

GertPollPulMortPM1death_count <- rbind(tablag31, tablag38, tablag39, tablag30)
write.csv(GertPollPulMortPM1death_count,"Data/GertPollPulMortPM1death_count.csv")

GertPollPulMortSOdeath_count <- rbind(tablag32, tablag351, tablag381, tablag37, tablag341, tablag301)
write.csv(GertPollPulMortSOdeath_count,"Data/GertPollPulMortSOdeath_count.csv")

GertPollPulMortNOdeath_count <- rbind(tablag33, tablag361, tablag391, tablag371, tablag342, tablag302)
write.csv(GertPollPulMortNOdeath_count,"Data/GertPollPulMortNOdeath_count.csv")

################################################################################
# MODEL CHECKING
##################

# GENERATE DEVIANCE RESIDUALS FROM UNCONSTRAINED DISTRIBUTED LAG MODEL
res8 <- residuals(model8, type = "deviance")

#############
# FIGURE A1
#############

plot(data$date, res8, ylim = c(-5,10), pch = 19, cex = 0.7, col = grey(0.6),
     main = "Residuals over time", ylab = "Deviance residuals", xlab = "Date")
abline(h = 0, lty = 2, lwd = 2)

#############################
# FIGURE A2a
#############################

pacf(res8, na.action = na.omit, main = "From original model")


# INCLUDE THE 1-DAY LAGGED RESIDUAL IN THE MODEL
model10 <- update(model8, .~. + Lag(res8,1))

#############################
# FIGURE A2b
#############################

pacf(residuals(model10, type = "deviance"), na.action = na.omit,
     main = "From model adjusted for residual autocorrelation")

################################################################################
# SENSITIVITY ANALYSIS: 
# ---------------------------------------------------------------------------
# 1. Sensitivity to lag period
# 2. Sensitivity to counterfactual concentration
# 3. Sensitivity to exposure-response shape

################################################################################

# 0 - 7

cbpm2_lag7 <- crossbasis(data$pm2.5, lag = c(0,7), argvar = list(fun = "lin"),
  arglag = list(fun = "ns", df = 2))

model_lag7 <- glm(death_count ~ cbpm2_lag7 + cbtempunc + spl + dow + holiday, data = data, family = quasipoisson)

af_lag7 <- attrdl(x = data$pm2.5, basis = cbpm2_lag7, cases = data$death_count, model = model_lag7,
  type = "af", dir = "forw", tot = TRUE, cen = 5)

an_lag7 <- attrdl(x = data$pm2.5, basis = cbpm2_lag7, cases = data$death_count, model = model_lag7,
  type = "an", dir = "forw", tot = TRUE, cen = 5)

# O-21

cbpm2_lag21 <- crossbasis(data$pm2.5, lag = c(0,21), argvar = list(fun = "lin"),
  arglag = list(fun = "ns", df = 3))

model_lag21 <- glm(death_count ~ cbpm2_lag21 + cbtempunc + spl + dow + holiday, data = data, family = quasipoisson)

af_lag21 <- attrdl(x = data$pm2.5, basis = cbpm2_lag21, cases = data$death_count, model = model_lag21,
  type = "af", dir = "forw", tot = TRUE, cen = 5)

an_lag21 <- attrdl(x = data$pm2.5, basis = cbpm2_lag21, cases = data$death_count, model = model_lag21,
  type = "an", dir = "forw", tot = TRUE, cen = 5)

# 2. Sensitivity to counterfactual concentration

# NAAQS (20 µg/m³)

af_naaqs <- attrdl(data$pm2.5, cbpm2constr, data$death_count, model8,
  type = "af", dir = "forw", tot = TRUE, cen = 20)


# Minimum observed concentration
af_min <- attrdl(data$pm2.5, cbpm2constr, data$death_count, model8,
  type = "af", dir = "forw", tot = TRUE, cen = min(data$pm2.5, na.rm = TRUE))

# 5th percentile

cen_p5 <- quantile(data$pm2.5, 0.05, na.rm = TRUE)

af_p5 <- attrdl(data$pm2.5, cbpm2constr, data$death_count, model8,
  type = "af", dir = "forw", tot = TRUE, cen = cen_p5)

# 10th percentile

cen_p10 <- quantile(data$pm2.5, 0.10, na.rm = TRUE)

af_p10 <- attrdl(data$pm2.5, cbpm2constr, data$death_count, model8,
  type = "af", dir = "forw", tot = TRUE, cen = cen_p10)

# 3. Sensitivity to exposure-response shape

cbpm2_ns <- crossbasis(data$pm2.5, lag = c(0,14), argvar = list(fun = "ns", df = 3),
  arglag = list(fun = "ns", df = 2))

model_ns <- glm(death_count ~ cbpm2_ns + cbtempunc + spl + dow + holiday, data = data, family = quasipoisson)


summary(model8)
summary(model_ns)

pred_ns <- crosspred(cbpm2_ns, model_ns, cen = 5, cumul = TRUE)

plot(pred_ns, "overall")


sens_results <- data.frame(
  Analysis = c(
    "Lag 0-7, cen=5",
    "Lag 0-14, cen=5",
    "Lag 0-21, cen=5",
    "Lag 0-14, cen=20",
    "Lag 0-14, cen=P5",
    "Lag 0-14, cen=P10"),
  AF = c(
    af_lag7,
    af_pm2,
    af_lag21,
    af_naaqs,
    af_p5,
    af_p10) * 100)

sens_results


# not so sure what

summary(data$pm2.5)

quantile(
  data$pm2.5,
  probs = c(0, 0.01, 0.05, 0.10, 0.25, 0.50, 0.75, 0.90, 0.95, 0.99, 1),
  na.rm = TRUE)

table(cut(data$pm2.5, breaks = c(0,5,10,20,40,60,80,100,150,Inf)))

################################################################################
# SUPPLEMENTARY ANALYSIS: CONTINUOUS AQHI-ER COMPOSITE (MULTI-POLLUTANT DLM)
# ---------------------------------------------------------------------------
# Composite exposure = sum of continuous excess risks (% per pollutant)
# based on beta coefficients from Adebayo-Ojo et al. (2023), IJPH 68:1606349.
# Includes PM2.5, PM10, SO2, NO2 (o3 not available for Mpumalanga).
# A 1-unit increase = 1 percentage-point increase in total excess risk.
# This is presented as a supplementary sensitivity analysis complementing
# the primary single-pollutant DLMs above.
################################################################################

# COMPUTE CONTINUOUS EXCESS RISK COMPOSITE (AQHI-ER) -------------------------
beta_pm25 <- 0.00065
beta_pm10  <- 0.00041
beta_no2   <- 0.00072
beta_so2   <- 0.00059

data$aqhi_er2 <- 100 * (exp(beta_pm25 * data$pm2.5) - 1) +
                 100 * (exp(beta_no2   * data$no2)   - 1) +
                 100 * (exp(beta_so2   * data$so2)   - 1)

#summary(data$aqhi_er2)

# CROSS-BASIS FOR AQHI-ER COMPOSITE
cbaqhier2constr <- crossbasis(data$aqhi_er2, lag = c(0,14),
                             argvar = list(fun = "lin"),
                             arglag = list(fun = "ns", df = 3))
#summary(cbaqhier2constr)

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR A 1-UNIT INCREASE IN AQHI-ER
model_aqhier2 <- glm(death_count ~ cbaqhier2constr + cbtempunc + fourier + dow + holiday,
                    data, family = quasipoisson)
pred_aqhier2 <- crosspred(cbaqhier2constr, model_aqhier2, at = 1, cumul = TRUE)
#summary(model_aqhier2)

# ESTIMATED EFFECTS AT EACH LAG
tablag_aqhier2 <- with(pred_aqhier2,
                      t(rbind(matRRfit, matRRlow, matRRhigh,
                              cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag_aqhier2) <- c("RR", "ci.low", "ci.hi",
                              "cumRR", "cumci.low", "cumci.hi")
tablag_aqhier2 <- tablag_aqhier2 |>
  as.data.frame()

tablag_aqhier2 <- tablag_aqhier2 |>
  mutate(
    Pollutant     = "AQHI-ER2 (PM2.5 + NO2 + SO2)",
    RR.perc       = (RR       - 1) * 100,
    ci.low.perc   = (ci.low   - 1) * 100,
    ci.hi.perc    = (ci.hi    - 1) * 100,
    cumRR.perc    = (cumRR    - 1) * 100,
    cumci.low.perc = (cumci.low - 1) * 100,
    cumci.hi.perc  = (cumci.hi  - 1) * 100)

tablag_aqhier2 <- rownames_to_column(tablag_aqhier2, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred_aqhier2, var = 1, type = "p", ci = "bars", col = 1, pch = 19,
     ylim = c(0.9, 1.1),
     main = "RR and 95% CI per 1-unit increase in AQHI-ER composite",
     xlab = "Lag (days)", ylab = "RR and 95% CI")

plot(pred_aqhier2, var = 1, cumul = TRUE, type = "p", ci = "bars", col = 1,
     pch = 19, ylim = c(0.9, 1.1),
     main = "Cumulative RR and 95% CI per 1-unit increase in AQHI-ER composite",
     xlab = "Lag (days)", ylab = "RR and 95% CI")

# ATTRIBUTABLE FRACTION AND NUMBER FOR AQHI-ER COMPOSITE
an_aqhier2 <- attrdl(x = data$aqhi_er2, basis = cbaqhier2constr, cases = data$death_count, model = model_aqhier2,
                    type = "an", dir = "forw", tot = TRUE, cen = 3)

af_aqhier2 <- attrdl(x = data$aqhi_er2, basis = cbaqhier2constr, cases = data$death_count, model = model_aqhier2,
                    type = "af", dir = "forw",  tot = TRUE, cen = 3)

af_sim_aqhier2 <- attrdl(x = data$aqhi_er2, basis = cbaqhier2constr, cases = data$death_count, model = model_aqhier2,
                        type = "af", dir = "forw", tot = TRUE, cen = 3, sim = TRUE, nsim = 1000)

cat("Attributable deaths (AQHI-ER composite):", round(an_aqhier2), "\n")
cat("Attributable fraction (AQHI-ER composite):", round(af_aqhier2 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim_aqhier2, 0.025) * 100, 2), "% -",
             round(quantile(af_sim_aqhier2, 0.975) * 100, 2), "%\n")

# SAVE THE RESULTS
write.csv(tablag_aqhier, "Data/GertPollPulMortAQHIERdeath_count.csv", row.names = FALSE)

# aqhi_er1 - PM10

data$aqhi_er1 <- 100 * (exp(beta_pm10  * data$pm10)  - 1) +
                 100 * (exp(beta_no2   * data$no2)   - 1) +
                 100 * (exp(beta_so2   * data$so2)   - 1)

#summary(data$aqhi_er1)

# CROSS-BASIS FOR AQHI-ER COMPOSITE
cbaqhier1constr <- crossbasis(data$aqhi_er1, lag = c(0,14),
                              argvar = list(fun = "lin"),
                              arglag = list(fun = "ns", df = 3))
#summary(cbaqhier1constr)

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR A 1-UNIT INCREASE IN AQHI-ER
model_aqhier1 <- glm(death_count ~ cbaqhier1constr + cbtempunc + fourier + dow + holiday,
                     data, family = quasipoisson)
pred_aqhier1 <- crosspred(cbaqhier1constr, model_aqhier1, at = 1, cumul = TRUE)
#summary(model_aqhier1)

# ESTIMATED EFFECTS AT EACH LAG
tablag_aqhier1 <- with(pred_aqhier1,
                       t(rbind(matRRfit, matRRlow, matRRhigh,
                               cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag_aqhier1) <- c("RR", "ci.low", "ci.hi",
                              "cumRR", "cumci.low", "cumci.hi")
tablag_aqhier1 <- tablag_aqhier1 |>
  as.data.frame()

tablag_aqhier1 <- tablag_aqhier1 |>
  mutate(
    Pollutant     = "AQHI-ER1 (PM10 + NO2 + SO2)",
    RR.perc       = (RR       - 1) * 100,
    ci.low.perc   = (ci.low   - 1) * 100,
    ci.hi.perc    = (ci.hi    - 1) * 100,
    cumRR.perc    = (cumRR    - 1) * 100,
    cumci.low.perc = (cumci.low - 1) * 100,
    cumci.hi.perc  = (cumci.hi  - 1) * 100)

tablag_aqhier1 <- rownames_to_column(tablag_aqhier1, var = "lag")

# PLOT THE LAGGED EFFECTS
plot(pred_aqhier1, var = 1, type = "p", ci = "bars", col = 1, pch = 19,
     ylim = c(0.9, 1.1),
     main = "RR and 95% CI per 1-unit increase in AQHI-ER composite",
     xlab = "Lag (days)", ylab = "RR and 95% CI")

plot(pred_aqhier1, var = 1, cumul = TRUE, type = "p", ci = "bars", col = 1,
     pch = 19, ylim = c(0.9, 1.1),
     main = "Cumulative RR and 95% CI per 1-unit increase in AQHI-ER composite",
     xlab = "Lag (days)", ylab = "RR and 95% CI")

# ATTRIBUTABLE FRACTION AND NUMBER FOR AQHI-ER COMPOSITE
an_aqhier1 <- attrdl(x = data$aqhi_er1, basis = cbaqhier1constr, cases = data$death_count, model = model_aqhier1,
                     type = "an", dir = "forw", tot = TRUE, cen = 3)

af_aqhier1 <- attrdl(x = data$aqhi_er1, basis = cbaqhier1constr, cases = data$death_count, model = model_aqhier1,
                     type = "af", dir = "forw",  tot = TRUE, cen = 3)

af_sim_aqhier1 <- attrdl(x = data$aqhi_er1, basis = cbaqhier1constr, cases = data$death_count, model = model_aqhier1,
                         type = "af", dir = "forw", tot = TRUE, cen = 3, sim = TRUE, nsim = 1000)

cat("Attributable deaths (AQHI-ER composite):", round(an_aqhier1), "\n")
cat("Attributable fraction (AQHI-ER composite):", round(af_aqhier1 * 100, 2), "%\n")
cat("95% CI:", round(quantile(af_sim_aqhier1, 0.025) * 100, 2), "% -",
    round(quantile(af_sim_aqhier1, 0.975) * 100, 2), "%\n")

# SAVE THE RESULTS
write.csv(tablag_aqhier, "Data/GertPollPulMortAQHIERdeath_count.csv", row.names = FALSE)


