library(tidyverse)
library(corrplot)
library(Hmisc)
library(tsModel)
library(splines)
library(Epi)
library(dlnm)
library(ggplot2)

# LOAD THE DATA INTO THE SESSION
data = read.csv("MortData/NkaPollPulMort.csv", header = T, sep = ";")

data$date <- as.Date(data$date, format = "%Y/%m/%d")

## Repalce NAs with 0
data[is.na(data)] = 0

# SET THE DEFAULT ACTION FOR MISSING DATA TO na.exclude
# (MISSING EXCLUDED IN ESTIMATION BUT RE-INSERTED IN PREDICTION/RESIDUALS)
options(na.action = "na.exclude")


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
model1 <- glm(J95_J99 ~ fourier + time, data, family = quasipoisson)
summary(model1)

# COMPUTE PREDICTED NUMBER OF DEATHS FROM THIS MODEL
pred1 <- predict(model1, type = "response")

#############
# FIGURE 1
#############

plot(data$date, data$J95_J99, ylim = c(0,30), pch = 19, cex = 0.2, col = grey(0.6),
     main = "Sine-cosine functions (Fourier terms)", ylab = "Daily number of deaths",
     xlab = "Date")
lines(data$date, pred1, lwd = 2)


#####################################
# OPTION 2: SPLINE MODEL
# (FLEXIBLE SPLINE FUNCTIONS)
#####################################

# GENERATE SPLINE TERMS
# (USE FUNCTION bs IN PACKAGE splines, TO BE LOADED)


# A CUBIC B-SPLINE WITH 32 EQUALLY-SPACED KNOTS + 2 BOUNDARY KNOTS
# (NOTE: THIS PARAMETERIZATION IS SLIGHTLY DIFFERENT THAN STATA'S)
# (THE 35 BASIS VARIABLES ARE SET AS df, WITH DEFAULT KNOTS PLACEMENT. SEE ?bs)
# (OTHER TYPES OF SPLINES CAN BE PRODUCED WITH THE FUNCTION ns. SEE ?ns)
spl <- bs(data$time, degree = 3, df = 70)

# FIT A POISSON MODEL FOURIER TERMS + LINEAR TERM FOR TREND
# (USE OF quasipoisson FAMILY FOR SCALING THE STANDARD ERRORS)
model2 <- glm(J95_J99 ~ spl, data, family = quasipoisson)
summary(model2)

# COMPUTE PREDICTED NUMBER OF DEATHS FROM THIS MODEL
pred2 <- predict(model2, type = "response")

#############
# FIGURE 2
#############

plot(data$date, data$J95_J99, ylim = c(0,30), pch = 19, cex = 0.2, col = grey(0.6),
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
# ESTIMATING PM-MORTALITY ASSOCIATION
# (CONTROLLING FOR CONFOUNDERS)
############################################

# COMPARE THE RR (AND CI)
# (COMPUTED WITH THE FUNCTION ci.lin IN PACKAGE Epi


# UNADJUSTED MODEL
model3 <- glm(J95_J99 ~ pm2.5, data, family = quasipoisson)
summary(model3)
(eff3 <- ci.lin(model3, subset = "pm2.5", Exp = T))

model31 <- glm(J95_J99 ~ pm10, data, family = quasipoisson)
summary(model31)
(eff31 <- ci.lin(model31, subset = "pm10", Exp = T))

model32 <- glm(J95_J99 ~ so2, data, family = quasipoisson)
summary(model32)
(eff32 <- ci.lin(model32, subset = "so2", Exp = T))

model33 <- glm(J95_J99 ~ no2, data, family = quasipoisson)
summary(model33)
(eff33 <- ci.lin(model33, subset = "no2", Exp = T))

model34 <- glm(J95_J99 ~ pm2.5  + so2 + no2, data, family = quasipoisson)
summary(model34)
(eff34 <- ci.lin(model34, subset = "pm2.5", Exp = T))
(eff341 <- ci.lin(model34, subset = "so2", Exp = T))
(eff342 <- ci.lin(model34, subset = "no2", Exp = T))

model35 <- glm(J95_J99 ~ pm2.5  + so2 , data, family = quasipoisson)
summary(model35)
(eff35 <- ci.lin(model35, subset = "pm2.5", Exp = T))
(eff351 <- ci.lin(model35, subset = "so2", Exp = T))

model36 <- glm(J95_J99 ~ pm2.5  + no2 , data, family = quasipoisson)
summary(model36)
(eff36 <- ci.lin(model36, subset = "pm2.5", Exp = T))
(eff361 <- ci.lin(model36, subset = "no2", Exp = T))

model37 <- glm(J95_J99 ~ so2  + no2 , data, family = quasipoisson)
summary(model37)
(eff37 <- ci.lin(model37, subset = "so2", Exp = T))
(eff371 <- ci.lin(model37, subset = "no2", Exp = T))

model38 <- glm(J95_J99 ~ pm10  + so2 , data, family = quasipoisson)
summary(model38)
(eff38 <- ci.lin(model38, subset = "pm10", Exp = T))
(eff381 <- ci.lin(model38, subset = "so2", Exp = T))

model39 <- glm(J95_J99 ~ pm10  + no2 , data, family = quasipoisson)
summary(model39)
(eff39 <- ci.lin(model39, subset = "pm10", Exp = T))
(eff391 <- ci.lin(model39, subset = "no2", Exp = T))

model30 <- glm(J95_J99 ~ pm10  + so2 + no2, data, family = quasipoisson)
summary(model34)
(eff30 <- ci.lin(model30, subset = "pm10", Exp = T))
(eff301 <- ci.lin(model30, subset = "so2", Exp = T))
(eff302 <- ci.lin(model30, subset = "no2", Exp = T))

## BUILD A SUMMARY TABLE
tabeff <- rbind(eff3,eff31,eff32,eff33,eff34,eff341,eff342,eff35,eff351,eff36,eff361,eff37,eff371,eff38,eff381,eff39,eff391,eff30,eff301,eff302)[,5:7]
dimnames(tabeff) <- list(c("PM2.5", "PM10", "SO2","NO2","PM2.5 + SO2 + NO2", "SO2 + PM2.5 + NO2", "NO2 + PM2.5 + SO2", "PM2.5 + SO2", 
                           "SO2 + PM2.5", "PM2.5 + NO2", "NO2 + PM2.5", "SO2 + NO2", "NO2 + SO2", "PM10 + SO2", "SO2 + PM10",
                           "PM10 + NO2", "NO2 + PM10", "PM10 + SO2 + NO2", "SO2 + PM10 + NO2", "NO2 + PM10 + SO2"),
                         c("RR","ci.low","ci.hi"))


# CONTROLLING FOR SEASONALITY (WITH SPLINE AS IN MODEL 3)
model4 <- update(model3, .~. + spl)
summary(model4)
(eff4 <- ci.lin(model4, subset = "pm2.5", Exp = T))

model41 <- update(model31, .~. + spl)
summary(model41)
(eff41 <- ci.lin(model41, subset = "pm10", Exp = T))

model42 <- update(model32, .~. + spl)
summary(model42)
(eff42 <- ci.lin(model42, subset = "so2", Exp = T))

model43 <- update(model33, .~. + spl)
summary(model43)
(eff43 <- ci.lin(model43, subset = "no2", Exp = T))

model44 <- update(model34, .~. + spl)
summary(model44)
(eff44 <- ci.lin(model44, subset = "pm2.5", Exp = T))
(eff441 <- ci.lin(model44, subset = "so2", Exp = T))
(eff442 <- ci.lin(model44, subset = "no2", Exp = T))

model45 <- update(model35, .~. + spl)
summary(model45)
(eff45 <- ci.lin(model45, subset = "pm2.5", Exp = T))
(eff451 <- ci.lin(model45, subset = "so2", Exp = T))

model46 <- update(model36, .~. + spl)
summary(model46)
(eff46 <- ci.lin(model46, subset = "pm2.5", Exp = T))
(eff461 <- ci.lin(model46, subset = "no2", Exp = T))

model47 <- update(model37, .~. + spl)
summary(model47)
(eff47 <- ci.lin(model47, subset = "so2", Exp = T))
(eff471 <- ci.lin(model47, subset = "no2", Exp = T))

model48 <- update(model38, .~. + spl)
summary(model48)
(eff48 <- ci.lin(model48, subset = "pm10", Exp = T))
(eff481 <- ci.lin(model48, subset = "so2", Exp = T))

model49 <- update(model39, .~. + spl)
summary(model49)
(eff49 <- ci.lin(model49, subset = "pm10", Exp = T))
(eff491 <- ci.lin(model49, subset = "no2", Exp = T))

model40 <- update(model30, .~. + spl)
summary(model40)
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


# CONTROLLING FOR SEASONALITY (WITH Fourier AS IN MODEL 3)
model0 <- update(model3, .~. + fourier)
summary(model0)
(eff0 <- ci.lin(model0, subset = "pm2.5", Exp = T))

model01 <- update(model31, .~. + fourier)
summary(model01)
(eff01 <- ci.lin(model01, subset = "pm10", Exp = T))

model02 <- update(model32, .~. + fourier)
summary(model02)
(eff02 <- ci.lin(model02, subset = "so2", Exp = T))

model03 <- update(model33, .~. + fourier)
summary(model03)
(eff03 <- ci.lin(model03, subset = "no2", Exp = T))

model04 <- update(model34, .~. + fourier)
summary(model04)
(eff04 <- ci.lin(model04, subset = "pm2.5", Exp = T))
(eff041 <- ci.lin(model04, subset = "so2", Exp = T))
(eff042 <- ci.lin(model04, subset = "no2", Exp = T))

model05 <- update(model35, .~. + fourier)
summary(model05)
(eff05 <- ci.lin(model05, subset = "pm2.5", Exp = T))
(eff051 <- ci.lin(model05, subset = "so2", Exp = T))

model06 <- update(model36, .~. + fourier)
summary(model06)
(eff06 <- ci.lin(model06, subset = "pm2.5", Exp = T))
(eff061 <- ci.lin(model06, subset = "no2", Exp = T))

model07 <- update(model37, .~. + fourier)
summary(model07)
(eff07 <- ci.lin(model07, subset = "so2", Exp = T))
(eff071 <- ci.lin(model07, subset = "no2", Exp = T))

model08 <- update(model38, .~. + fourier)
summary(model08)
(eff08 <- ci.lin(model08, subset = "pm10", Exp = T))
(eff081 <- ci.lin(model08, subset = "so2", Exp = T))

model09 <- update(model39, .~. + fourier)
summary(model09)
(eff09 <- ci.lin(model09, subset = "pm10", Exp = T))
(eff091 <- ci.lin(model09, subset = "no2", Exp = T))

model00 <- update(model30, .~. + fourier)
summary(model00)
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

# CONTROLLING FOR TEMPERATURE
# (TEMPERATURE MODELLED WITH CATEGORICAL VARIABLES FOR DECILES)
# (MORE SOPHISTICATED APPROACHES ARE AVAILABLE - SEE ARMSTRONG EPIDEMIOLOGY 2006)
cutoffs <- quantile(data$temp, probs = 0:10/10)
tempdecile <- cut(data$temp, breaks = cutoffs, include.lowest = TRUE)

model5 <- update(model3, .~. + tempdecile)

summary(model5)
(eff5 <- ci.lin(model5, subset = "pm2.5", Exp = T))

model51 <- update(model31, .~. + tempdecile)
summary(model51)
(eff51 <- ci.lin(model51, subset = "pm10", Exp = T))

model52 <- update(model32, .~. + tempdecile)
summary(model52)
(eff52 <- ci.lin(model52, subset = "so2", Exp = T))

model53 <- update(model33, .~. + tempdecile)
summary(model53)
(eff53 <- ci.lin(model53, subset = "no2", Exp = T))

model54 <- update(model34, .~. + tempdecile)
summary(model54)
(eff54 <- ci.lin(model54, subset = "pm2.5", Exp = T))
(eff541 <- ci.lin(model54, subset = "so2", Exp = T))
(eff542 <- ci.lin(model54, subset = "no2", Exp = T))

model55 <- update(model35, .~. + tempdecile)
summary(model55)
(eff55 <- ci.lin(model55, subset = "pm2.5", Exp = T))
(eff551 <- ci.lin(model55, subset = "so2", Exp = T))

model56 <- update(model36, .~. + tempdecile)
summary(model56)
(eff56 <- ci.lin(model56, subset = "pm2.5", Exp = T))
(eff561 <- ci.lin(model56, subset = "no2", Exp = T))

model57 <- update(model37, .~. + tempdecile)
summary(model57)
(eff57 <- ci.lin(model57, subset = "so2", Exp = T))
(eff571 <- ci.lin(model57, subset = "no2", Exp = T))

model58 <- update(model38, .~. + tempdecile)
summary(model58)
(eff58 <- ci.lin(model58, subset = "pm10", Exp = T))
(eff581 <- ci.lin(model58, subset = "so2", Exp = T))

model59 <- update(model39, .~. + tempdecile)
summary(model59)
(eff59 <- ci.lin(model59, subset = "pm10", Exp = T))
(eff591 <- ci.lin(model59, subset = "no2", Exp = T))

model50 <- update(model30, .~. + tempdecile)
summary(model50)
(eff50 <- ci.lin(model50, subset = "pm10", Exp = T))
(eff501 <- ci.lin(model50, subset = "so2", Exp = T))
(eff502 <- ci.lin(model50, subset = "no2", Exp = T))

## BUILD A SUMMARY TABLE
tabeff <- rbind(eff5,eff51,eff52,eff53,eff54,eff541,eff542,eff55,eff551,eff56,eff561,eff57,eff571,eff58,eff581,eff59,eff591,eff50,eff501,eff502)[,5:7]
dimnames(tabeff) <- list(c("PM2.5", "PM10", "SO2","NO2","PM2.5 + SO2 + NO2", "SO2 + PM2.5 + NO2", "NO2 + PM2.5 + SO2", "PM2.5 + SO2", 
                           "SO2 + PM2.5", "PM2.5 + NO2", "NO2 + PM2.5", "SO2 + NO2", "NO2 + SO2", "PM10 + SO2", "SO2 + PM10",
                           "PM10 + NO2", "NO2 + PM10", "PM10 + SO2 + NO2", "SO2 + PM10 + NO2", "NO2 + PM10 + SO2"),
                         c("RR","ci.low","ci.hi"))
round(tabeff,3)

# CONTROLLING FOR SEASONALITY + TEMPERATURE
model6 <- update(model0, .~. + tempdecile)
summary(model6)
(eff6 <- ci.lin(model6, subset = "pm2.5", Exp = T))

model61 <- update(model01, .~. + tempdecile)
summary(model61)
(eff61 <- ci.lin(model61, subset = "pm10", Exp = T))

model62 <- update(model02, .~. + tempdecile)
summary(model62)
(eff62 <- ci.lin(model62, subset = "so2", Exp = T))

model63 <- update(model03, .~. + tempdecile)
summary(model63)
(eff63 <- ci.lin(model63, subset = "no2", Exp = T))

model64 <- update(model04, .~. + tempdecile)
summary(model64)
(eff64 <- ci.lin(model64, subset = "pm2.5", Exp = T))
(eff641 <- ci.lin(model64, subset = "so2", Exp = T))
(eff642 <- ci.lin(model64, subset = "no2", Exp = T))

model65 <- update(model05, .~. + tempdecile)
summary(model65)
(eff65 <- ci.lin(model65, subset = "pm2.5", Exp = T))
(eff651 <- ci.lin(model65, subset = "so2", Exp = T))

model66 <- update(model06, .~. + tempdecile)
summary(model66)
(eff66 <- ci.lin(model66, subset = "pm2.5", Exp = T))
(eff661 <- ci.lin(model66, subset = "no2", Exp = T))

model67 <- update(model07, .~. + tempdecile)
summary(model67)
(eff67 <- ci.lin(model67, subset = "so2", Exp = T))
(eff671 <- ci.lin(model67, subset = "no2", Exp = T))

model68 <- update(model08, .~. + tempdecile)
summary(model68)
(eff68 <- ci.lin(model68, subset = "pm10", Exp = T))
(eff681 <- ci.lin(model68, subset = "so2", Exp = T))

model69 <- update(model09, .~. + tempdecile)
summary(model69)
(eff69 <- ci.lin(model69, subset = "pm10", Exp = T))
(eff691 <- ci.lin(model69, subset = "no2", Exp = T))

model60 <- update(model00, .~. + tempdecile)
summary(model60)
(eff60 <- ci.lin(model60, subset = "pm10", Exp = T))
(eff601 <- ci.lin(model60, subset = "so2", Exp = T))
(eff602 <- ci.lin(model60, subset = "no2", Exp = T))


## BUILD A SUMMARY TABLE
tabeff <- rbind(eff6,eff61,eff62,eff63,eff64,eff641,eff642,eff65,eff651,eff66,eff661,eff67,eff671,eff68,eff681,eff69,eff691,eff60,eff601,eff602)[,5:7]
dimnames(tabeff) <- list(c("PM2.5", "PM10", "SO2","NO2","PM2.5 + SO2 + NO2", "SO2 + PM2.5 + NO2", "NO2 + PM2.5 + SO2", "PM2.5 + SO2", 
                           "SO2 + PM2.5", "PM2.5 + NO2", "NO2 + PM2.5", "SO2 + NO2", "NO2 + SO2",  "PM10 + SO2", "SO2 + PM10", 
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

write.csv(tabeff,"Data/GertPollPulMortJ95_J99.csv")
################################################################################
# EXPLORING THE LAGGED (DELAYED) EFFECTS
############################################

#####################
# SINGLE-LAG MODELS
#####################

cutoffs <- quantile(data$temp, probs = 0:10/10)

# PREPARE THE TABLE WITH ESTIMATES
tablagPM2 <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),
                                                   c("RR","ci.low","ci.hi")))

# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  PM2lag <- Lag(data$pm2.5,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ PM2lag + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagPM2[i+1,] <- ci.lin(mod, subset = "PM2lag", Exp = T)[5:7]
}
tablagPM2

# PLOT THE LAGGED EFFECTS
plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 PM2.5 increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagPM2[,2], 0:14, tablagPM2[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagPM2[,1], pch = 19)

# PREPARE THE TABLE WITH ESTIMATES
tablagPM1 <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),
                                                   c("RR","ci.low","ci.hi")))

# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  PM1lag <- Lag(data$pm10,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ PM1lag + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagPM1[i+1,] <- ci.lin(mod, subset = "PM1lag", Exp = T)[5:7]
}
tablagPM1

# PLOT THE LAGGED EFFECTS
plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 PM10 increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagPM1[,2], 0:14, tablagPM1[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagPM1[,1], pch = 19)

# PREPARE THE TABLE WITH ESTIMATES
tablagSO <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),
                                                  c("RR","ci.low","ci.hi")))

# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  so2lag <- Lag(data$so2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ so2lag + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagSO[i+1,] <- ci.lin(mod, subset = "so2lag", Exp = T)[5:7]
}
tablagSO

# PLOT THE LAGGED EFFECTS
plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 SO2 increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagSO[,2], 0:14, tablagSO[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagSO[,1], pch = 19)

# PREPARE THE TABLE WITH ESTIMATES
tablagNO <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),
                                                  c("RR","ci.low","ci.hi")))

# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  no2lag <- Lag(data$no2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ no2lag + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagNO[i+1,] <- ci.lin(mod, subset = "no2lag", Exp = T)[5:7]
}
tablagNO

# PLOT THE LAGGED EFFECTS
plot(0:14, 0:14, type = "n", ylim = c(0.99,1.02), main = "RR and 95% CI per 10 ug/m3 NO2 increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagNO[,2], 0:14, tablagNO[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagNO[,1], pch = 19)

# PREPARE THE TABLE WITH ESTIMATES
tablagPM2SN <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),
                                                     c("RR","ci.low","ci.hi")))
# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  PM2lag <- Lag(data$pm2.5,i)
  so2lag <- Lag(data$so2,i)
  no2lag <- Lag(data$no2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ PM2lag + so2lag + no2lag + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagPM2SN[i+1,] <- ci.lin(mod, subset = "PM2lag", Exp = T)[5:7]
}
tablagPM2SN

# PLOT THE LAGGED EFFECTS
plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 PM2.5 + SO2 + NO2 increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagPM2SN[,2], 0:14, tablagPM2SN[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagPM2SN[,1], pch = 19)

# PREPARE THE TABLE WITH ESTIMATES
tablagSPM2N <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),
                                                     c("RR","ci.low","ci.hi")))
# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  PM2lag <- Lag(data$pm2.5,i)
  so2lag <- Lag(data$so2,i)
  no2lag <- Lag(data$no2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ so2lag + PM2lag + no2lag + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagSPM2N[i+1,] <- ci.lin(mod, subset = "so2lag", Exp = T)[5:7]
}
tablagSPM2N

# PLOT THE LAGGED EFFECTS
plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 SO2 + PM2.5 + NO2 increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagSPM2N[,2], 0:14, tablagSPM2N[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagSPM2N[,1], pch = 19)

# PREPARE THE TABLE WITH ESTIMATES
tablagNPM2S <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),
                                                     c("RR","ci.low","ci.hi")))
# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  PM2lag <- Lag(data$pm2.5,i)
  so2lag <- Lag(data$so2,i)
  no2lag <- Lag(data$no2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ no2lag + PM2lag + so2lag + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagNPM2S[i+1,] <- ci.lin(mod, subset = "no2lag", Exp = T)[5:7]
}
tablagNPM2S

# PLOT THE LAGGED EFFECTS
plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 NO2 + PM2.5 + SO2 increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagNPM2S[,2], 0:14, tablagNPM2S[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagNPM2S[,1], pch = 19)

# PREPARE THE TABLE WITH ESTIMATES
tablagPM2S <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),                                                   c("RR","ci.low","ci.hi")))

# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  PM2lag <- Lag(data$pm2.5,i)
  so2lag <- Lag(data$so2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ PM2lag + so2lag +  tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagPM2S[i+1,] <- ci.lin(mod, subset = "PM2lag", Exp = T)[5:7]
}
tablagPM2S

# PLOT THE LAGGED EFFECTS
plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 PM2.5 + SO2 increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagPM2S[,2], 0:14, tablagPM2S[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagPM2S[,1], pch = 19)


# PREPARE THE TABLE WITH ESTIMATES
tablagSPM2 <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),                                                   c("RR","ci.low","ci.hi")))

# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  PM2lag <- Lag(data$pm2.5,i)
  so2lag <- Lag(data$so2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ so2lag + PM2lag +  tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagSPM2[i+1,] <- ci.lin(mod, subset = "so2lag", Exp = T)[5:7]
}
tablagSPM2

# PLOT THE LAGGED EFFECTS
plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 SO2 + PM2.5 increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagSPM2[,2], 0:14, tablagSPM2[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagSPM2[,1], pch = 19)

# PREPARE THE TABLE WITH ESTIMATES
tablagPM2N <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),                                                   c("RR","ci.low","ci.hi")))

# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  PM2lag <- Lag(data$pm2.5,i)
  no2lag <- Lag(data$no2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ PM2lag  + no2lag + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagPM2N[i+1,] <- ci.lin(mod, subset = "PM2lag", Exp = T)[5:7]
}
tablagPM2N

# PREPARE THE TABLE WITH ESTIMATES
plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 PM2.5 + NO2 increase",
     xlab = "Lag (days)", ylab = "PM2.5 + NO2 RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagPM2N[,2], 0:14, tablagPM2N[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagPM2N[,1], pch = 19)

# PREPARE THE TABLE WITH ESTIMATES
tablagNPM2 <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),                                                   c("RR","ci.low","ci.hi")))

# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  PM2lag <- Lag(data$pm2.5,i)
  no2lag <- Lag(data$no2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ no2lag + PM2lag  + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagNPM2[i+1,] <- ci.lin(mod, subset = "no2lag", Exp = T)[5:7]
}
tablagNPM2

plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 NO2 + PM2.5 increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagNPM2[,2], 0:14, tablagNPM2[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagNPM2[,1], pch = 19)

# PREPARE THE TABLE WITH ESTIMATES
tablagSN <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),
                                                  c("RR","ci.low","ci.hi")))
# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  so2lag <- Lag(data$so2,i)
  no2lag <- Lag(data$no2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ so2lag +  no2lag + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagSN[i+1,] <- ci.lin(mod, subset = "so2lag", Exp = T)[5:7]
}
tablagSN

# PLOT THE LAGGED EFFECTS
plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 SO2 + NO2 increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagSN[,2], 0:14, tablagSN[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagSN[,1], pch = 19)

# PREPARE THE TABLE WITH ESTIMATES
tablagNS <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),
                                                  c("RR","ci.low","ci.hi")))
# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  so2lag <- Lag(data$so2,i)
  no2lag <- Lag(data$no2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ no2lag + so2lag + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagNS[i+1,] <- ci.lin(mod, subset = "no2lag", Exp = T)[5:7]
}
tablagNS

# PLOT THE LAGGED EFFECTS
plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 NO2 + SO2 increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagNS[,2], 0:14, tablagNS[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagNS[,1], pch = 19)

# PREPARE THE TABLE WITH ESTIMATES
tablagPM1S <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),                                                   c("RR","ci.low","ci.hi")))

# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  PM1lag <- Lag(data$pm10,i)
  so2lag <- Lag(data$so2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ PM1lag + so2lag +  tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagPM1S[i+1,] <- ci.lin(mod, subset = "PM1lag", Exp = T)[5:7]
}
tablagPM1S

# PLOT THE LAGGED EFFECTS
plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 PM10 + SO2  increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagPM1S[,2], 0:14, tablagPM1S[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagPM1S[,1], pch = 19)

# PREPARE THE TABLE WITH ESTIMATES
tablagSPM1 <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),                                                   c("RR","ci.low","ci.hi")))

# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  PM1lag <- Lag(data$pm10,i)
  so2lag <- Lag(data$so2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ so2lag + PM1lag +  tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagSPM1[i+1,] <- ci.lin(mod, subset = "so2lag", Exp = T)[5:7]
}
tablagSPM1

# PLOT THE LAGGED EFFECTS
plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 SO2 + PM10 increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagSPM1[,2], 0:14, tablagSPM1[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagSPM1[,1], pch = 19)

# PREPARE THE TABLE WITH ESTIMATES
tablagPM1N <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),                                                   c("RR","ci.low","ci.hi")))

# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  PM1lag <- Lag(data$pm10,i)
  no2lag <- Lag(data$no2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ PM1lag  + no2lag + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagPM1N[i+1,] <- ci.lin(mod, subset = "PM1lag", Exp = T)[5:7]
}
tablagPM1N

# PREPARE THE TABLE WITH ESTIMATES
plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 PM10 + NO2 increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagPM1N[,2], 0:14, tablagPM1N[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagPM1N[,1], pch = 19)


# PREPARE THE TABLE WITH ESTIMATES
tablagNPM1 <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),                                                   c("RR","ci.low","ci.hi")))

# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  PM1lag <- Lag(data$pm10,i)
  no2lag <- Lag(data$no2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ no2lag + PM1lag  + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagNPM1[i+1,] <- ci.lin(mod, subset = "no2lag", Exp = T)[5:7]
}
tablagNPM1

plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 NO2 + PM10 increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagNPM1[,2], 0:14, tablagNPM1[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagNPM1[,1], pch = 19)

# PREPARE THE TABLE WITH ESTIMATES
tablagPM1SN <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),
                                                     c("RR","ci.low","ci.hi")))
# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  PM1lag <- Lag(data$pm10,i)
  so2lag <- Lag(data$so2,i)
  no2lag <- Lag(data$no2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ PM1lag + so2lag + no2lag + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagPM1SN[i+1,] <- ci.lin(mod, subset = "PM1lag", Exp = T)[5:7]
}
tablagPM1SN

# PLOT THE LAGGED EFFECTS
plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 PM10 + SO2 + NO2  increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagPM1SN[,2], 0:14, tablagPM1SN[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagPM1SN[,1], pch = 19)

# PREPARE THE TABLE WITH ESTIMATES
tablagSPM1N <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),
                                                     c("RR","ci.low","ci.hi")))
# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  PM1lag <- Lag(data$pm10,i)
  so2lag <- Lag(data$so2,i)
  no2lag <- Lag(data$no2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ so2lag + PM1lag + no2lag + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagSPM1N[i+1,] <- ci.lin(mod, subset = "so2lag", Exp = T)[5:7]
}
tablagSPM1N

# PLOT THE LAGGED EFFECTS
plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 SO2 + PM10 + NO2 increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagSPM1N[,2], 0:14, tablagSPM1N[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagSPM1N[,1], pch = 19)

# PREPARE THE TABLE WITH ESTIMATES
tablagNPM1S <- matrix(NA, 14 + 1, 3, dimnames = list(paste("Lag", 0:14),
                                                     c("RR","ci.low","ci.hi")))
# RUN THE LOOP
for(i in 0:14) {
  # LAG PM AND TEMPERATURE VARIABLES
  PM1lag <- Lag(data$pm10,i)
  so2lag <- Lag(data$so2,i)
  no2lag <- Lag(data$no2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(J95_J99 ~ no2lag + PM1lag + so2lag + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagNPM1S[i+1,] <- ci.lin(mod, subset = "no2lag", Exp = T)[5:7]
}
tablagNPM1S

# PLOT THE LAGGED EFFECTS
plot(0:14, 0:14, type = "n", ylim = c(0.99,1.01), main = "RR and 95% CI per 10 ug/m3 NO2 + PM10 + SO2 increase",
     xlab = "Lag (days)", ylab = "RR and 95% CI")
abline(h = 1)
arrows(0:14, tablagNPM1S[,2], 0:14, tablagNPM1S[,3], length = 0.05, angle = 90, code = 3)
points(0:14, tablagNPM1S[,1], pch = 19)


#####################
# UNCONSTRAINED DLM
#####################

# FACILITATED BY THE FUNCTIONS IN PACKAGE dlnm
# IN PARTICULAR, THE FUNCTION crossbasis PRODUCES THE TRANSFORMATION FOR 
#   SPECIFIC LAG STRUCTURES AND OPTIONALLY FOR NON-LINEARITY
# THE FUNCTION crosspred INSTEAD PREDICTS ESTIMATED EFFECTS

# PRODUCE THE CROSS-BASIS FOR POLL(SCALING NOT NEEDED)
# A SIMPLE UNSTRANSFORMED LINEAR TERM AND THE UNCONSTRAINED LAG STRUCTURE
cbPM2unc <- crossbasis(data$pm2.5, lag = c(0,14), argvar = list(fun = "lin"),
                       arglag = list(fun = "integer"))
summary(cbPM2unc)

cbPM1unc <- crossbasis(data$pm10, lag = c(0,14), argvar = list(fun = "lin"),
                       arglag = list(fun = "integer"))
summary(cbPM1unc)

cbSOunc <- crossbasis(data$so2, lag = c(0,14), argvar = list(fun = "lin"),
                      arglag = list(fun = "integer"))
summary(cbSOunc)

cbNOunc <- crossbasis(data$no2, lag = c(0,14), argvar = list(fun = "lin"),
                      arglag = list(fun = "integer"))
summary(cbNOunc)


# PRODUCE THE CROSS-BASIS FOR TEMPERATURE
# AS ABOVE, BUT WITH STRATA DEFINED BY INTERNAL CUT-OFFS
cbtempunc <- crossbasis(data$temp, lag = c(0,14),
                        argvar = list(fun = "strata", breaks = cutoffs[2:10]),
                        arglag = list(fun = "integer"))
summary(cbtempunc)

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model7 <- glm(J95_J99 ~ cbPM2unc + cbtempunc + fourier, data, family = quasipoisson)
pred7 <- crosspred(cbPM2unc, model7, at = 10, cumul  = TRUE)
summary(model7)

# ESTIMATED EFFECTS AT EACH LAG
tablag2 <- with(pred7,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag2) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag2 <- tablag2 |> 
  as.data.frame()

tablag2 <- tablag2 |>
  mutate(
    Pollutant = "PM2.5",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred7, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ug/m3 PM2.5 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred7, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ug/m3 PM2.5 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")


# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model71 <- glm(J95_J99 ~ cbPM1unc + cbtempunc + fourier, data, family = quasipoisson)
pred71 <- crosspred(cbPM1unc, model71, at = 10, cumul  = TRUE)
summary(model71)

# ESTIMATED EFFECTS AT EACH LAG
tablag21 <- with(pred71,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag21) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag21 <- tablag21 |> 
  as.data.frame()

tablag21 <- tablag21 |>
  mutate(
    Pollutant = "PM10",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred71, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ug/m3 PM10 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred71, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ug/m3 PM10 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")


# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model72 <- glm(J95_J99 ~ cbSOunc + cbtempunc + fourier, data, family = quasipoisson)
pred72 <- crosspred(cbSOunc, model72, at = 10, cumul  = TRUE)
summary(model72)

# ESTIMATED EFFECTS AT EACH LAG
tablag22 <- with(pred72,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag22) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag22 <- tablag22 |> 
  as.data.frame()

tablag22 <- tablag22 |>
  mutate(
    Pollutant = "SO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred72, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred72, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")


# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model73 <- glm(J95_J99 ~ cbNOunc + cbtempunc + fourier, data, family = quasipoisson)
pred73 <- crosspred(cbNOunc, model73, at = 10, cumul  = TRUE)
summary(model73)

# ESTIMATED EFFECTS AT EACH LAG
tablag23 <- with(pred73,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag23) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag23 <- tablag23 |> 
  as.data.frame()

tablag23 <- tablag23 |>
  mutate(
    Pollutant = "NO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred73, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.80,1.30),
     main = "RR and 95%CI per 10 ppb NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred73, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.80,1.30),
     main = "RR and 95%CI per 10 ppb NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")


# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model74 <- glm(J95_J99 ~ cbPM2unc + cbSOunc + cbNOunc + cbtempunc + fourier, data, family = quasipoisson)
pred74 <- crosspred(cbPM2unc, model74, at = 10, cumul  = TRUE)
summary(model74)

# ESTIMATED EFFECTS AT EACH LAG
tablag24 <- with(pred74,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag24) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag24 <- tablag24 |> 
  as.data.frame()

tablag24 <- tablag24 |>
  mutate(
    Pollutant = "PM2.5 + SO2 + NO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred74, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ug/m3 PM2.5 + SO2 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred74, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ug/m3 PM2.5 + SO2 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model741 <- glm(J95_J99 ~ cbSOunc + cbPM2unc + cbNOunc +  cbtempunc + fourier, data, family = quasipoisson)
pred741 <- crosspred(cbSOunc, model741, at = 10, cumul  = TRUE)
summary(model741)

# ESTIMATED EFFECTS AT EACH LAG
tablag241 <- with(pred741,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag241) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag241 <- tablag241 |> 
  as.data.frame()

tablag241 <- tablag241 |>
  mutate(
    Pollutant = "SO2 + PM2.5 + NO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred741, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ug/m3 SO2 + PM2.5 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred741, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ug/m3 SO2 + PM2.5 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model742 <- glm(J95_J99 ~ cbNOunc + cbPM2unc + cbSOunc + cbtempunc + fourier, data, family = quasipoisson)
pred742 <- crosspred(cbNOunc, model742, at = 10, cumul  = TRUE)
summary(model742)

# ESTIMATED EFFECTS AT EACH LAG
tablag242 <- with(pred742,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag242) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag242 <- tablag242 |> 
  as.data.frame()

tablag242 <- tablag242 |>
  mutate(
    Pollutant = "NO2 + PM2.5 + SO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred742, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ug/m3 NO2 + PM2.5 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred742, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ug/m3 NO2 + PM2.5 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model75 <- glm(J95_J99 ~ cbPM2unc + cbSOunc + cbtempunc + fourier, data, family = quasipoisson)
pred75 <- crosspred(cbPM2unc, model75, at = 10, cumul  = TRUE)
summary(model75)

# ESTIMATED EFFECTS AT EACH LAG
tablag25 <- with(pred75,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag25) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag25 <- tablag25 |> 
  as.data.frame()

tablag25 <- tablag25 |>
  mutate(
    Pollutant = "PM2.5 + SO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred75, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb PM2.5 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred75, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb PM2.5 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model751 <- glm(J95_J99 ~ cbSOunc + cbPM2unc + cbtempunc + fourier, data, family = quasipoisson)
pred751 <- crosspred(cbSOunc, model751, at = 10, cumul  = TRUE)
summary(model751)

# ESTIMATED EFFECTS AT EACH LAG
tablag251 <- with(pred751,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag251) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag251 <- tablag251 |> 
  as.data.frame()

tablag251 <- tablag251 |>
  mutate(
    Pollutant = "SO2 + PM2.5",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred751, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb SO2 + PM2.5 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred751, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb SO2 + PM2.5 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model76 <- glm(J95_J99 ~ cbPM2unc +  cbNOunc + cbtempunc + fourier, data, family = quasipoisson)
pred76 <- crosspred(cbPM2unc, model76, at = 10, cumul  = TRUE)
summary(model76)

# ESTIMATED EFFECTS AT EACH LAG
tablag26 <- with(pred76,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag26) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag26 <- tablag26 |> 
  as.data.frame()

tablag26 <- tablag26 |>
  mutate(
    Pollutant = "PM2.5 + NO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred76, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb PM2.5 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred76, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb PM2.5 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model761 <- glm(J95_J99 ~ cbNOunc + cbPM2unc + cbtempunc + fourier, data, family = quasipoisson)
pred761 <- crosspred(cbNOunc, model761, at = 10, cumul  = TRUE)
summary(model761)

# ESTIMATED EFFECTS AT EACH LAG
tablag261 <- with(pred761,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag261) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag261 <- tablag261 |> 
  as.data.frame()

tablag261 <- tablag261 |>
  mutate(
    Pollutant = "NO2 + PM2.5",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred761, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb NO2 + PM2.5 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred761, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb NO2 + PM2.5 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model77 <- glm(J95_J99 ~  cbSOunc + cbNOunc + cbtempunc + fourier, data, family = quasipoisson)
pred77 <- crosspred(cbSOunc, model77, at = 10, cumul  = TRUE)
summary(model77)

# ESTIMATED EFFECTS AT EACH LAG
tablag27 <- with(pred77,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag27) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag27 <- tablag27 |> 
  as.data.frame()

tablag27 <- tablag27 |>
  mutate(
    Pollutant = "SO2 + NO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred77, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb NO2 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred77, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb NO2 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model771 <- glm(J95_J99 ~  cbNOunc + cbSOunc + cbtempunc + fourier, data, family = quasipoisson)
pred771 <- crosspred(cbNOunc, model771, at = 10, cumul  = TRUE)
summary(model771)

# ESTIMATED EFFECTS AT EACH LAG
tablag271 <- with(pred771,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag271) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag271 <- tablag271 |> 
  as.data.frame()

tablag271 <- tablag271 |>
  mutate(
    Pollutant = "NO2 + SO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred771, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb SO2 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred771, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb SO2 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model78 <- glm(J95_J99 ~ cbPM1unc + cbSOunc + cbtempunc + fourier, data, family = quasipoisson)
pred78 <- crosspred(cbPM1unc, model78, at = 10, cumul  = TRUE)
summary(model78)

# ESTIMATED EFFECTS AT EACH LAG
tablag28 <- with(pred78,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag28) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag28 <- tablag28 |> 
  as.data.frame()

tablag28 <- tablag28 |>
  mutate(
    Pollutant = "PM10 + SO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred78, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb PM10 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred78, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb PM10 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model781 <- glm(J95_J99 ~ cbSOunc + cbPM1unc + cbtempunc + fourier, data, family = quasipoisson)
pred781 <- crosspred(cbSOunc, model781, at = 10, cumul  = TRUE)
summary(model781)

# ESTIMATED EFFECTS AT EACH LAG
tablag281 <- with(pred781,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag281) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag281 <- tablag281 |> 
  as.data.frame()

tablag281 <- tablag281 |>
  mutate(
    Pollutant = "SO2 + PM10",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred781, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb SO2 + PM10 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred781, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb SO2 + PM10 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model79 <- glm(J95_J99 ~ cbPM1unc +  cbNOunc + cbtempunc + fourier, data, family = quasipoisson)
pred79 <- crosspred(cbPM1unc, model79, at = 10, cumul  = TRUE)
summary(model79)

# ESTIMATED EFFECTS AT EACH LAG
tablag29 <- with(pred79,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag29) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag29 <- tablag29 |> 
  as.data.frame()

tablag29 <- tablag29 |>
  mutate(
    Pollutant = "PM10 + NO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred79, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb PM10 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred79, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb PM10 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model791 <- glm(J95_J99 ~ cbNOunc + cbPM1unc + cbtempunc + fourier, data, family = quasipoisson)
pred791 <- crosspred(cbNOunc, model791, at = 10, cumul  = TRUE)
summary(model791)

# ESTIMATED EFFECTS AT EACH LAG
tablag291 <- with(pred791,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag291) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag291 <- tablag291 |> 
  as.data.frame()

tablag291 <- tablag291 |>
  mutate(
    Pollutant = "NO2 + PM10",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred791, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb NO2 + PM10 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred791, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ppb NO2 + PM10 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")


# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model70 <- glm(J95_J99 ~ cbPM1unc + cbSOunc + cbNOunc + cbtempunc + fourier, data, family = quasipoisson)
pred70 <- crosspred(cbPM1unc, model70, at = 10, cumul  = TRUE)
summary(model70)

# ESTIMATED EFFECTS AT EACH LAG
tablag20 <- with(pred70,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag20) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag20 <- tablag20 |> 
  as.data.frame()

tablag20 <- tablag20 |>
  mutate(
    Pollutant = "PM1 + SO2 + NO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred70, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ug/m3 PM10 + SO2 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred70, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ug/m3 PM10 + SO2 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model701 <- glm(J95_J99 ~ cbSOunc + cbPM1unc + cbNOunc +  cbtempunc + fourier, data, family = quasipoisson)
pred701 <- crosspred(cbSOunc, model701, at = 10, cumul  = TRUE)
summary(model701)

# ESTIMATED EFFECTS AT EACH LAG
tablag201 <- with(pred701,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag201) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag201 <- tablag201 |> 
  as.data.frame()

tablag201 <- tablag201 |>
  mutate(
    Pollutant = "SO2 + PM1 + NO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred701, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ug/m3 SO2 + PM10 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred701, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ug/m3 SO2 + PM10 + NO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model702 <- glm(J95_J99 ~ cbNOunc + cbPM1unc + cbSOunc + cbtempunc + fourier, data, family = quasipoisson)
pred702 <- crosspred(cbNOunc, model702, at = 10, cumul  = TRUE)
summary(model702)

# ESTIMATED EFFECTS AT EACH LAG
tablag202 <- with(pred702,t(rbind(matRRfit, matRRlow, matRRhigh, cumRRfit, cumRRlow, cumRRhigh)))
colnames(tablag202) <- c("RR","ci.low","ci.hi", "cumRR","cumci.low","cumci.hi")
tablag202 <- tablag202 |> 
  as.data.frame()

tablag202 <- tablag202 |>
  mutate(
    Pollutant = "NO2 + PM1 + SO2",
    RR.perc      = (RR    - 1) * 100,
    ci.low.perc  = (ci.low - 1) * 100,
    ci.hi.perc = (ci.hi - 1) * 100,
    cumRR.perc      = (cumRR - 1) * 100,
    cumci.low.perc  = (cumci.low - 1) * 100,
    cumci.hi.perc = (cumci.hi - 1) * 100)

# PLOT THE LAGGED EFFECTS
plot(pred702, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ug/m3 NO2 + PM10 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

plot(pred702, var = 10, cumul  = TRUE, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.90,1.10),
     main = "RR and 95%CI per 10 ug/m3 NO2 + PM10 + SO2 increase", xlab = "Lag (days)",
     ylab = "RR and 95%CI")

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
summary(cbpm2constr)


cbpm1constr <- crossbasis(data$pm10, lag = c(0,14), argvar = list(fun = "lin"),
                          arglag = list(fun="ns", df=3))
summary(cbpm1constr)

cbsoconstr <- crossbasis(data$so2, lag = c(0,14), argvar = list(fun = "lin"),
                         arglag = list(fun="ns", df=3))
summary(cbsoconstr)

cbnoconstr <- crossbasis(data$no2, lag = c(0,14), argvar = list(fun = "lin"),
                         arglag = list(fun="ns", df=3))
summary(cbnoconstr)

cutoffs <- quantile(data$temp, probs = 0:10/10)

cbtempunc <- crossbasis(data$temp, lag = c(0,14),
                        argvar = list(fun = "strata", breaks = cutoffs[2:10]),
                        arglag = list(fun = "integer"))
summary(cbtempunc)

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR PM2.5 LEVEL 10ug/m3
model8 <- glm(J95_J99 ~ cbpm2constr + cbtempunc + fourier, data, family = quasipoisson)
pred8 <- crosspred(cbpm2constr, model8, at = 10, cumul  = TRUE)
summary(model8)

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


# RUN THE MODEL AND OBTAIN PREDICTIONS FOR PM10 LEVEL 10ug/m3
model81 <- glm(J95_J99 ~ cbpm1constr + cbtempunc + fourier, data, family = quasipoisson)
pred81 <- crosspred(cbpm1constr, model81, at = 10, cumul  = TRUE)
summary(model81)

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

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model82 <- glm(J95_J99 ~ cbsoconstr + cbtempunc + fourier, data, family = quasipoisson)
pred82 <- crosspred(cbsoconstr, model82, at = 10, cumul  = TRUE)
summary(model82)

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

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model83 <- glm(J95_J99 ~ cbnoconstr + cbtempunc + fourier, data, family = quasipoisson)
pred83 <- crosspred(cbnoconstr, model83, at = 10, cumul  = TRUE)
summary(model83)

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

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model84 <- glm(J95_J99 ~ cbpm2constr + cbsoconstr + cbnoconstr + cbtempunc + fourier, data, family = quasipoisson)
pred84 <- crosspred(cbpm2constr, model84, at = 10, cumul  = TRUE)
summary(model84)

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

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model841 <- glm(J95_J99 ~ cbsoconstr + cbpm2constr + cbnoconstr + cbtempunc + fourier, data, family = quasipoisson)
pred841 <- crosspred(cbsoconstr, model841, at = 10, cumul  = TRUE)
summary(model841)

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

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model842 <- glm(J95_J99 ~ cbnoconstr +  cbpm2constr + cbsoconstr + cbtempunc + fourier, data, family = quasipoisson)
pred842 <- crosspred(cbnoconstr, model842, at = 10, cumul  = TRUE)
summary(model842)

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

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model85 <- glm(J95_J99 ~ cbpm2constr + cbsoconstr + cbtempunc + fourier, data, family = quasipoisson)
pred85 <- crosspred(cbpm2constr, model85, at = 10, cumul  = TRUE)
summary(model85)

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

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model851 <- glm(J95_J99 ~ cbsoconstr + cbpm2constr +  cbtempunc + fourier, data, family = quasipoisson)
pred851 <- crosspred(cbsoconstr, model851, at = 10, cumul  = TRUE)
summary(model851)

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

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model86 <- glm(J95_J99 ~ cbpm2constr + cbnoconstr +  cbtempunc + fourier, data, family = quasipoisson)
pred86 <- crosspred(cbpm2constr, model86, at = 10, cumul  = TRUE)
summary(model86)

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

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model861 <- glm(J95_J99 ~ cbnoconstr + cbpm2constr +  cbtempunc + fourier, data, family = quasipoisson)
pred861 <- crosspred(cbnoconstr, model861, at = 10, cumul  = TRUE)
summary(model861)

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

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model87 <- glm(J95_J99 ~ cbsoconstr + cbnoconstr + cbtempunc + fourier, data, family = quasipoisson)
pred87 <- crosspred(cbsoconstr, model87, at = 10, cumul  = TRUE)
summary(model87)

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

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model871 <- glm(J95_J99 ~ cbnoconstr + cbsoconstr + cbtempunc + fourier, data, family = quasipoisson)
pred871 <- crosspred(cbnoconstr, model871, at = 10, cumul  = TRUE)
summary(model871)

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

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model88 <- glm(J95_J99 ~ cbpm1constr + cbsoconstr + cbtempunc + fourier, data, family = quasipoisson)
pred88 <- crosspred(cbpm1constr, model88, at = 10, cumul  = TRUE)
summary(model88)

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

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model881 <- glm(J95_J99 ~ cbsoconstr + cbpm1constr +  cbtempunc + fourier, data, family = quasipoisson)
pred881 <- crosspred(cbsoconstr, model881, at = 10, cumul  = TRUE)
summary(model881)

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

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model89 <- glm(J95_J99 ~ cbpm1constr + cbnoconstr +  cbtempunc + fourier, data, family = quasipoisson)
pred89 <- crosspred(cbpm1constr, model89, at = 10, cumul  = TRUE)
summary(model89)

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

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model891 <- glm(J95_J99 ~ cbnoconstr + cbpm1constr +  cbtempunc + fourier, data, family = quasipoisson)
pred891 <- crosspred(cbnoconstr, model891, at = 10, cumul  = TRUE)
summary(model891)

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

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model80 <- glm(J95_J99 ~ cbpm1constr + cbsoconstr + cbnoconstr + cbtempunc + fourier, data, family = quasipoisson)
pred80 <- crosspred(cbpm1constr, model80, at = 10, cumul  = TRUE)
summary(model80)

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

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model801 <- glm(J95_J99 ~ cbsoconstr + cbpm1constr + cbnoconstr + cbtempunc + fourier, data, family = quasipoisson)
pred801 <- crosspred(cbsoconstr, model801, at = 10, cumul  = TRUE)
summary(model801)

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

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model802 <- glm(J95_J99 ~ cbnoconstr +  cbpm1constr + cbsoconstr + cbtempunc + fourier, data, family = quasipoisson)
pred802 <- crosspred(cbnoconstr, model802, at = 10, cumul  = TRUE)
summary(model802)

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

# SAVE THE RESULTS

NkaPollPulMortPM2J95_J99 <- rbind(tablag3, tablag35, tablag36, tablag34)
write.csv(NkaPollPulMortPM2J95_J99,"Data/NkaPollPulMortPM2J95_J99.csv")

NkaPollPulMortPM1J95_J99 <- rbind(tablag31, tablag38, tablag39, tablag30)
write.csv(NkaPollPulMortPM1J95_J99,"Data/NkaPollPulMortPM1J95_J99.csv")

NkaPollPulMortSOJ95_J99 <- rbind(tablag32, tablag351, tablag381, tablag37, tablag341, tablag301)
write.csv(NkaPollPulMortSOJ95_J99,"Data/NkaPollPulMortSOJ95_J99.csv")

NkaPollPulMortNOJ95_J99 <- rbind(tablag33, tablag361, tablag391, tablag371, tablag342, tablag302)
write.csv(NkaPollPulMortNOJ95_J99,"Data/NkatPollPulMortNOJ95_J99.csv")

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


#############################
# Sensitivity analysis
#############################


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
        cbP <- crossbasis(
          data$pm2.5,
          lag    = 14,
          argvar = list(fun = "lin"),
          arglag = list(fun = "ns", df = lag_df))
        
        # Fit model
        m <- glm(J95_J99 ~ cbP + spl_seas + tempdecile,
                 data = data, family = quasipoisson)
        
        # Estimate dispersion
        phi <- summary(m)$dispersion
        
        # Compute QAIC manually
        logL <- sum(stats::family(m)$dev.resids(m$y, m$fitted.values, m$prior.weights))
        k <- length(coef(m))
        qaic <- logL + 2 * k * phi
        
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



results2 <- expand.grid(
  lag_df    = 2:5) %>% 
  mutate(
    fit = pmap(
      list(lag_df),
      function(lag_df) {
        
        # Rebuild crossbasis with lag spline
        cbP <- crossbasis(
          data$pm2.5,
          lag    = 14,
          argvar = list(fun = "lin"),
          arglag = list(fun = "ns", df = lag_df))
        
        fourier <- harmonic(data$time, nfreq = 4, period = 365.25)
        
        cbtempunc <- crossbasis(data$temp, lag = c(0,14),
                                argvar = list(fun = "strata", breaks = cutoffs[2:10]),
                                arglag = list(fun = "integer"))
        
        # Fit model
        m <- glm(J95_J99 ~ cbP + fourier + cbtempunc,
                 data = data, family = quasipoisson)
        
        # Estimate dispersion
        phi <- summary(m)$dispersion
        
        # Compute QAIC manually
        logL <- sum(stats::family(m)$dev.resids(m$y, m$fitted.values, m$prior.weights))
        k <- length(coef(m))
        qaic <- logL + 2 * k * phi
        
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


