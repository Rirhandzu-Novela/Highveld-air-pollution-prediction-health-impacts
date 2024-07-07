library(tidyverse)
library(corrplot)
library(Hmisc)
library(tsModel)
library(splines)
library(Epi)
library(dlnm)

# LOAD THE DATA INTO THE SESSION
data = read.csv("MortData/GertPollPulMort.csv", header = T, sep = ";")

data$date <- as.Date(data$date, format = "%Y/%m/%d")

## Repalce NAs with 0
data[is.na(data)] = 0

# SET THE DEFAULT ACTION FOR MISSING DATA TO na.exclude
# (MISSING EXCLUDED IN ESTIMATION BUT RE-INSERTED IN PREDICTION/RESIDUALS)
options(na.action = "na.exclude")

sumYear <- data %>% 
  novaAQM::datify() %>%
  select(date, year, death_count, Male, Female, TenToSixtyFour, SixtyFivePlus) %>%
  group_by(year) %>%
  summarise(death_count = sum(death_count, na.rm = T),
            Male = sum(Male, na.rm = T),
            Female = sum(Female, na.rm = T),
            TenToSixtyFour = sum(TenToSixtyFour, na.rm = T),
            SixtyFivePlus = sum(SixtyFivePlus, na.rm = T)) %>%
  pivot_longer(cols = c(death_count, Male, Female, TenToSixtyFour, SixtyFivePlus), 
               names_to = "variable", 
               values_to = "value")


dfYear <-  data  %>%
  pivot_longer(cols = pm2.5:SixtyFivePlus, names_to = "variable") %>%
  novaAQM::datify() %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(year, variable)
  ) %>% 
  left_join(sumYear, by = c("year", "variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(year, variable) 

write.csv(dfYear,"RDA/GertPollPulMortYearSum.csv")

sum <- data %>% 
  select(date, death_count, Male, Female, TenToSixtyFour, SixtyFivePlus) %>%
  summarise(death_count = sum(death_count, na.rm = T),
            Male = sum(Male, na.rm = T),
            Female = sum(Female, na.rm = T),
            TenToSixtyFour = sum(TenToSixtyFour, na.rm = T),
            SixtyFivePlus = sum(SixtyFivePlus, na.rm = T)) %>%
  pivot_longer(cols = c(death_count, Male, Female, TenToSixtyFour, SixtyFivePlus), 
               names_to = "variable", 
               values_to = "value")


df <-  data  %>%
  pivot_longer(cols = pm2.5:SixtyFivePlus, names_to = "variable") %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(variable)
  ) %>% 
  left_join(sum, by = c("variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(variable)

write.csv(df,"RDA/GertPollPulMortSum.csv")

#################################################################
# PRELIMINARY ANALYSIS
#######################

#############
# FIGURE 1
#############

# SET THE PLOTTING PARAMETERS FOR THE PLOT (SEE ?par)
oldpar <- par(no.readonly = TRUE)
par(mex = 0.8, mfrow = c(2,1))

# SUB-PLOT FOR DAILY DEATHS, WITH VERTICAL LINES DEFINING YEARS
plot(data$date, data$TenToSixtyFour, pch = ".", main = "Daily deaths over time",
     ylab = "Daily number of deaths", xlab = "Date")
abline(v = data$date[grep("-01-01", data$date)], col = grey(0.6), lty = 2)

# THE SAME FOR PM LEVELS
plot(data$date, data$pm2.5, pch= ".", main = "PM levels over time",
     ylab = "Daily mean PM level (ug/m3)", xlab = "Date")
abline(v = data$date[grep("-01-01", data$date)], col = grey(0.6), lty = 2)
par(oldpar)
layout(1)


#ggplot(data, aes(x = date, y = TenToSixtyFour)) +
#  geom_point(size = 0.5) +
#  geom_vline(xintercept = as.numeric(data$date[grep("-01-01", data$date)]), color = "grey60", linetype = "dashed") +
#  labs(title = "Daily Deaths Over Time", y = "Daily Number of Deaths", x = "Date") +
#  theme_minimal()


#ggplot(data, aes(x = date, y = PM2.5)) +
#  geom_point(size = 0.5) +
#  geom_vline(xintercept = as.numeric(data$date[grep("-01-01", data$date)]), color = "grey60", linetype = "dashed") +
#  labs(title = "Daily Deaths Over Time", y = "Daily Number of Deaths", x = "Date") +
#  theme_minimal()



########################
# DESCRIPTIVE STATISTICS
########################


# CORRELATIONS

#cor_data <- data %>%
#  select(-date) %>%
#  cor(use = "complete.obs")


cor_data  <- data %>%
  select(-date)


GertCardcor <- rcorr(as.matrix(cor_data ), type = "pearson")
GertCardcor.coeff = GertCardcor$r
GertCardcor.p = GertCardcor$P


GertCardcorplot <- corrplot.mixed(GertCardcor.coeff, mar = c(0,0,1,0), lower = 'number', upper = 'ellipse', title = "Air pollutant correlation")

#write.csv(GertCardcor.coeff, file = "Data/ALLNKAPULLCOEFF.csv")


################################################################################
# MODELLING SEASONALITY AND LONG-TERM TREND
# (LEAVING OUT MAIN EXPOSURE FOR NOW)
############################################

##################################
# OPTION 1: TIME-STRATIFIED MODEL
# (SIMPLE INDICATOR VARIABLES)
##################################

# GENERATE MONTH AND YEAR
data$month <- as.factor(months(data$date, abbr = TRUE))
data$year <- as.factor(substr(data$date, 1, 4))

# FIT A POISSON MODEL WITH A STRATUM FOR EACH MONTH NESTED IN YEAR
# (USE OF quasipoisson FAMILY FOR SCALING THE STANDARD ERRORS)
model1 <- glm(TenToSixtyFour ~ month/year, data, family = quasipoisson)
summary(model1)

# COMPUTE PREDICTED NUMBER OF DEATHS FROM THIS MODEL
pred1 <- predict(model1, type = "response")

#############
# FIGURE 2A
#############

plot(data$date,data$TenToSixtyFour, ylim = c(0,30), pch = 19, cex = 0.2, col = grey(0.6),
     main = "Time-stratified model (month strata)", ylab = "Daily number of deaths",
     xlab = "Date")
lines(data$date, pred1, lwd = 2)



#####################################
# OPTION 2: PERIODIC FUNCTIONS MODEL
# (FOURIER TERMS)
#####################################


# GENERATE FOURIER TERMS
# (USE FUNCTION harmonic, IN PACKAGE tsModel TO BE INSTALLED AND THEN LOADED)


# 4 SINE-COSINE PAIRS REPRESENTING DIFFERENT HARMONICS WITH PERIOD 1 YEAR
data$time <- seq(nrow(data))
fourier <- harmonic(data$time, nfreq = 4, period = 365.25)

#FIT A POISSON MODEL FOURIER TERMS + LINEAR TERM FOR TREND
# (USE OF quasipoisson FAMILY FOR SCALING THE STANDARD ERRORS)
model2 <- glm(TenToSixtyFour ~ fourier + time, data, family = quasipoisson)
summary(model2)

# COMPUTE PREDICTED NUMBER OF DEATHS FROM THIS MODEL
pred2 <- predict(model2, type = "response")

#############
# FIGURE 2B
#############

plot(data$date, data$TenToSixtyFour, ylim = c(0,30), pch = 19, cex = 0.2, col = grey(0.6),
     main = "Sine-cosine functions (Fourier terms)", ylab = "Daily number of deaths",
     xlab = "Date")
lines(data$date, pred2, lwd = 2)


#####################################
# OPTION 3: SPLINE MODEL
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
model3 <- glm(TenToSixtyFour ~ spl, data, family = quasipoisson)
summary(model3)

# COMPUTE PREDICTED NUMBER OF DEATHS FROM THIS MODEL
pred3 <- predict(model3, type = "response")

#############
# FIGURE 2C
#############

plot(data$date, data$TenToSixtyFour, ylim = c(0,30), pch = 19, cex = 0.2, col = grey(0.6),
     main = "Flexible cubic spline model", ylab = "Daily number of deaths",
     xlab = "Date")
lines(data$date, pred3, lwd=2)

#####################################
# PLOT RESPONSE RESIDUALS OVER TIME
# FROM MODEL 3
#####################################

# GENERATE RESIDUALS
res3 <- residuals(model3, type = "response")

############
# FIGURE 3
############

plot(data$date, res3, ylim = c(-20,20), pch = 19, cex = 0.4, col = grey(0.6),
     main = "Residuals over time", ylab = "Residuals (observed-fitted)", xlab = "Date")
abline(h = 1, lty = 2, lwd = 2)

################################################################################
# ESTIMATING PM-MORTALITY ASSOCIATION
# (CONTROLLING FOR CONFOUNDERS)
############################################

# COMPARE THE RR (AND CI)
# (COMPUTED WITH THE FUNCTION ci.lin IN PACKAGE Epi


# UNADJUSTED MODEL
model4 <- glm(TenToSixtyFour ~ pm2.5, data, family = quasipoisson)
summary(model4)
(eff4 <- ci.lin(model4, subset = "pm2.5", Exp = T))

model41 <- glm(TenToSixtyFour ~ so2, data, family = quasipoisson)
summary(model41)
(eff41 <- ci.lin(model41, subset = "so2", Exp = T))

model42 <- glm(TenToSixtyFour ~ no2, data, family = quasipoisson)
summary(model42)
(eff42 <- ci.lin(model42, subset = "no2", Exp = T))

model43 <- glm(TenToSixtyFour ~ pm2.5  + so2 + no2, data, family = quasipoisson)
summary(model43)
(eff43 <- ci.lin(model43, subset = "pm2.5", Exp = T))
(eff431 <- ci.lin(model43, subset = "so2", Exp = T))
(eff432 <- ci.lin(model43, subset = "no2", Exp = T))

# CONTROLLING FOR SEASONALITY (WITH SPLINE AS IN MODEL 3)
model5 <- update(model4, .~. + spl)
summary(model5)
(eff5 <- ci.lin(model5, subset = "pm2.5", Exp = T))

model51 <- update(model41, .~. + spl)
summary(model51)
(eff51 <- ci.lin(model51, subset = "so2", Exp = T))

model52 <- update(model42, .~. + spl)
summary(model52)
(eff52 <- ci.lin(model52, subset = "no2", Exp = T))

model53 <- update(model43, .~. + spl)
summary(model53)
(eff53 <- ci.lin(model53, subset = "pm2.5", Exp = T))
(eff531 <- ci.lin(model53, subset = "so2", Exp = T))
(eff532 <- ci.lin(model53, subset = "no2", Exp = T))


model00 <- update(model4, .~. + fourier)
summary(model00)
(eff00 <- ci.lin(model00, subset = "pm2.5", Exp = T))

model01 <- update(model41, .~. + fourier)
summary(model01)
(eff01 <- ci.lin(model01, subset = "so2", Exp = T))

model02 <- update(model42, .~. + fourier)
summary(model02)
(eff02 <- ci.lin(model02, subset = "no2", Exp = T))

model03 <- update(model43, .~. + fourier)
summary(model53)
(eff03 <- ci.lin(model03, subset = "pm2.5", Exp = T))
(eff031 <- ci.lin(model03, subset = "so2", Exp = T))
(eff032 <- ci.lin(model03, subset = "no2", Exp = T))

# CONTROLLING FOR TEMPERATURE
# (TEMPERATURE MODELLED WITH CATEGORICAL VARIABLES FOR DECILES)
# (MORE SOPHISTICATED APPROACHES ARE AVAILABLE - SEE ARMSTRONG EPIDEMIOLOGY 2006)
cutoffs <- quantile(data$temp, probs = 0:10/10)
tempdecile <- cut(data$temp, breaks = cutoffs, include.lowest = TRUE)

model6 <- update(model4, .~. + tempdecile)
summary(model6)
(eff6 <- ci.lin(model6, subset = "pm2.5", Exp = T))

model61 <- update(model41, .~. + tempdecile)
summary(model61)
(eff61 <- ci.lin(model61, subset = "so2", Exp = T))

model62 <- update(model42, .~. + tempdecile)
summary(model62)
(eff62 <- ci.lin(model62, subset = "no2", Exp = T))

model63 <- update(model43, .~. + tempdecile)
summary(model63)
(eff63 <- ci.lin(model63, subset = "pm2.5", Exp = T))
(eff631 <- ci.lin(model63, subset = "so2", Exp = T))
(eff632 <- ci.lin(model63, subset = "no2", Exp = T))


model9 <- update(model00, .~. + tempdecile)
summary(model9)
(eff9 <- ci.lin(model9, subset = "pm2.5", Exp = T))

model91 <- update(model01, .~. + tempdecile)
summary(model91)
(eff91 <- ci.lin(model91, subset = "so2", Exp = T))

model92 <- update(model02, .~. + tempdecile)
summary(model92)
(eff92 <- ci.lin(model92, subset = "no2", Exp = T))

model93 <- update(model03, .~. + tempdecile)
summary(model93)
(eff93 <- ci.lin(model93, subset = "pm2.5", Exp = T))
(eff931 <- ci.lin(model93, subset = "so2", Exp = T))
(eff932 <- ci.lin(model93, subset = "no2", Exp = T))


## BUILD A SUMMARY TABLE

#tabeff <- rbind(eff4,eff41,eff40,eff42,eff421,eff42,eff51,eff510,eff5100,eff6,eff60,eff600,eff61,eff610,eff6100)[,5:7]
#dimnames(tabeff) <- list(c("Unadjusted PM2.5","Unadjusted SO2","Unadjusted NO2","Unadjusted All PollPM", "Unadjusted All PollSO","Unadjusted All PollNO",
#                             "PM2.5 Plus season/trend", "SO2 Plus season/trend","NO2 Plus season/trend",
#                           "PM2.5 Plus temperature ", "SO2 Plus temperature ", "NO2 Plus temperature ", 
#                           "PM2.5 Plus season/trend/temperature ", "Plus season/trend/temperature SO2", "Plus season/trend/temperature NO2"),
#                         c("RR","ci.low","ci.hi"))
#round(tabeff,3)

################################################################################
# EXPLORING THE LAGGED (DELAYED) EFFECTS
############################################

#####################
# SINGLE-LAG MODELS
#####################

# PREPARE THE TABLE WITH ESTIMATES
tablagPM <- matrix(NA, 7 + 1, 3, dimnames = list(paste("Lag", 0:7),
                                                 c("RR","ci.low","ci.hi")))

# RUN THE LOOP
for(i in 0:7) {
  # LAG PM AND TEMPERATURE VARIABLES
  PMlag <- Lag(data$pm2.5,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(TenToSixtyFour ~ PMlag + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagPM[i+1,] <- ci.lin(mod, subset = "PMlag", Exp = T)[5:7]
}
tablagPM


# PREPARE THE TABLE WITH ESTIMATES
tablagSO <- matrix(NA, 7 + 1, 3, dimnames = list(paste("Lag", 0:7),
                                        c("RR","ci.low","ci.hi")))

# RUN THE LOOP
for(i in 0:7) {
  # LAG PM AND TEMPERATURE VARIABLES
  so2lag <- Lag(data$so2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(TenToSixtyFour ~ so2lag + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagSO[i+1,] <- ci.lin(mod, subset = "so2lag", Exp = T)[5:7]
}
tablagSO


# PREPARE THE TABLE WITH ESTIMATES
tablagNO <- matrix(NA, 7 + 1, 3, dimnames = list(paste("Lag", 0:7),
                                                 c("RR","ci.low","ci.hi")))

# RUN THE LOOP
for(i in 0:7) {
  # LAG PM AND TEMPERATURE VARIABLES
  no2lag <- Lag(data$no2,i)
  tempdecilelag <- cut(Lag(data$temp,i), breaks = cutoffs,
                       include.lowest = TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(TenToSixtyFour ~ no2lag + tempdecilelag + fourier, data,
             family = quasipoisson)
  tablagNO[i+1,] <- ci.lin(mod, subset = "no2lag", Exp = T)[5:7]
}
tablagNO

#############
# FIGURE 4A
#############

plot(0:7, 0:7, type = "n", ylim = c(0.99,1.02), main = "Lag terms modelled one at a time",
     xlab = "Lag (days)", ylab = "PM2.5 RR and 95% CI")
abline(h = 1)
arrows(0:7, tablagPM[,2], 0:7, tablagPM[,3], length = 0.05, angle = 90, code = 3)
points(0:7, tablagPM[,1], pch = 19)


plot(0:7, 0:7, type = "n", ylim = c(0.99,1.03), main = "Lag terms modelled one at a time",
     xlab = "Lag (days)", ylab = "SO2 RR and 95% CI")
abline(h = 1)
arrows(0:7, tablagSO[,2], 0:7, tablagSO[,3], length = 0.05, angle = 90, code = 3)
points(0:7, tablagSO[,1], pch = 19)


plot(0:7, 0:7, type = "n", ylim = c(0.99,1.03), main = "Lag terms modelled one at a time",
     xlab = "Lag (days)", ylab = "NO2 RR and 95% CI")
abline(h = 1)
arrows(0:7, tablagNO[,2], 0:7, tablagNO[,3], length = 0.05, angle = 90, code = 3)
points(0:7, tablagNO[,1], pch = 19)

#####################
# UNCONSTRAINED DLM
#####################

# FACILITATED BY THE FUNCTIONS IN PACKAGE dlnm
# IN PARTICULAR, THE FUNCTION crossbasis PRODUCES THE TRANSFORMATION FOR 
#   SPECIFIC LAG STRUCTURES AND OPTIONALLY FOR NON-LINEARITY
# THE FUNCTION crosspred INSTEAD PREDICTS ESTIMATED EFFECTS

# PRODUCE THE CROSS-BASIS FOR POLL(SCALING NOT NEEDED)
# A SIMPLE UNSTRANSFORMED LINEAR TERM AND THE UNCONSTRAINED LAG STRUCTURE
cbPMunc <- crossbasis(data$pm2.5, lag = c(0,7), argvar = list(fun = "lin"),
                      arglag = list(fun = "integer"))
summary(cbPMunc)

cbSOunc <- crossbasis(data$so2, lag = c(0,7), argvar = list(fun = "lin"),
                      arglag = list(fun = "integer"))
summary(cbSOunc)

cbNOunc <- crossbasis(data$no2, lag = c(0,7), argvar = list(fun = "lin"),
                      arglag = list(fun = "integer"))
summary(cbNOunc)


# PRODUCE THE CROSS-BASIS FOR TEMPERATURE
# AS ABOVE, BUT WITH STRATA DEFINED BY INTERNAL CUT-OFFS
cbtempunc <- crossbasis(data$temp, lag = c(0,7),
                        argvar = list(fun = "strata", breaks = cutoffs[2:10]),
                        arglag = list(fun = "integer"))
summary(cbtempunc)

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR POLL LEVEL 10ug/m3
model7 <- glm(TenToSixtyFour ~ cbPMunc + cbtempunc + fourier, data, family = quasipoisson)
pred7 <- crosspred(cbPMunc, model7, at = 10)
summary(model7)

model71 <- glm(TenToSixtyFour ~ cbSOunc + cbtempunc + fourier, data, family = quasipoisson)
pred71 <- crosspred(cbSOunc, model71, at = 10)
summary(model71)

model72 <- glm(TenToSixtyFour ~ cbNOunc + cbtempunc + fourier, data, family = quasipoisson)
pred72 <- crosspred(cbNOunc, model72, at = 10)
summary(model72)

# ESTIMATED EFFECTS AT EACH LAG
tablag2 <- with(pred7,t(rbind(matRRfit, matRRlow, matRRhigh)))
colnames(tablag2) <- c("RR","ci.low","ci.hi")
tablag2

tablag21 <- with(pred71,t(rbind(matRRfit, matRRlow, matRRhigh)))
colnames(tablag21) <- c("RR","ci.low","ci.hi")
tablag21


tablag22 <- with(pred72,t(rbind(matRRfit, matRRlow, matRRhigh)))
colnames(tablag22) <- c("RR","ci.low","ci.hi")
tablag22

# OVERALL CUMULATIVE (NET) EFFECT
pred7$allRRfit ; pred7$allRRlow ; pred7$allRRhigh

pred71$allRRfit ; pred71$allRRlow ; pred71$allRRhigh

pred72$allRRfit ; pred72$allRRlow ; pred72$allRRhigh

#############
# FIGURE 4B
#############

plot(pred7, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.80,1.30),
     main = "All lag terms modelled together (unconstrained)", xlab = "Lag (days)",
     ylab = "RR and 95%CI per 10 ug/m3 PM2.5 increase")

plot(pred71, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.80,1.30),
     main = "All lag terms modelled together (unconstrained)", xlab = "Lag (days)",
     ylab = "RR and 95%CI per 10 ppb SO2 increase")

plot(pred72, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.80,1.30),
     main = "All lag terms modelled together (unconstrained)", xlab = "Lag (days)",
     ylab = "RR and 95%CI per 10 ppb NO2 increase")

####################################
# CONSTRAINED (LAG-STRATIFIED) DLM
####################################

# PRODUCE A DIFFERENT CROSS-BASIS FOR PM2.5
# USE STRATA FOR LAG STRUCTURE, WITH CUT-OFFS DEFINING RIGHT-OPEN INTERVALS 
cbpmconstr <- crossbasis(data$pm2.5, lag = c(0,7), argvar = list(fun = "lin"),
                         arglag = list(fun = "strata", breaks = c(1,3)))
summary(cbpmconstr)

cbsoconstr <- crossbasis(data$so2, lag = c(0,7), argvar = list(fun = "lin"),
                         arglag = list(fun = "strata", breaks = c(1,3)))
summary(cbsoconstr)

cbnoconstr <- crossbasis(data$no2, lag = c(0,7), argvar = list(fun = "lin"),
                         arglag = list(fun = "strata", breaks = c(1,3)))
summary(cbnoconstr)

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR PM2.5 LEVEL 10ug/m3
model8 <- glm(TenToSixtyFour ~ cbpmconstr + cbtempunc + fourier, data, family = quasipoisson)
pred8 <- crosspred(cbpmconstr, model8, at = 10)
summary(model8)

model81 <- glm(TenToSixtyFour ~ cbsoconstr + cbtempunc + fourier, data, family = quasipoisson)
pred81 <- crosspred(cbsoconstr, model81, at = 10)
summary(model81)

model82 <- glm(TenToSixtyFour ~ cbnoconstr + cbtempunc + fourier, data, family = quasipoisson)
pred82 <- crosspred(cbnoconstr, model82, at = 10)
summary(model82)

# ESTIMATED EFFECTS AT EACH LAG
tablag3 <- with(pred8,t(rbind(matRRfit, matRRlow, matRRhigh)))
colnames(tablag3) <- c("RR","ci.low","ci.hi")
tablag3

tablag31 <- with(pred81,t(rbind(matRRfit, matRRlow, matRRhigh)))
colnames(tablag31) <- c("RR","ci.low","ci.hi")
tablag31

tablag32 <- with(pred82,t(rbind(matRRfit, matRRlow, matRRhigh)))
colnames(tablag32) <- c("RR","ci.low","ci.hi")
tablag32

# OVERALL CUMULATIVE (NET) EFFECT
pred8$allRRfit ; pred8$allRRlow ; pred8$allRRhigh

pred81$allRRfit ; pred81$allRRlow ; pred81$allRRhigh

pred82$allRRfit ; pred82$allRRlow ; pred82$allRRhigh

#############
# FIGURE 4C
#############

plot(pred8, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.2),
     main = "All lag terms modelled together", xlab = "Lag (days)",
     ylab = "RR and 95% CI per 10 ug/m3 PM2.5 increase")

plot(pred80, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.2),
     main = "All lag terms modelled together", xlab = "Lag (days)",
     ylab = "RR and 95% CI per 10 ppb SO2 increase")

plot(pred800, var = 10, type = "p", ci = "bars", col = 1, pch = 19, ylim = c(0.9,1.2),
     main = "All lag terms modelled together", xlab = "Lag (days)",
     ylab = "RR and 95% CI per 10 ppb NO2 increase")

################################################################################
# MODEL CHECKING
##################

# GENERATE DEVIANCE RESIDUALS FROM UNCONSTRAINED DISTRIBUTED LAG MODEL
res7 <- residuals(model7, type = "deviance")

#############
# FIGURE A1
#############

plot(data$date, res7, ylim = c(-5,10), pch = 19, cex = 0.7, col = grey(0.6),
     main = "Residuals over time", ylab = "Deviance residuals", xlab = "Date")
abline(h = 0, lty = 2, lwd = 2)

#############################
# FIGURE A2a
#############################

pacf(res7, na.action = na.omit, main = "From original model")


# INCLUDE THE 1-DAY LAGGED RESIDUAL IN THE MODEL
model10 <- update(model7, .~. + Lag(res7,1))

#############################
# FIGURE A2b
#############################

pacf(residuals(model10, type = "deviance"), na.action = na.omit,
     main = "From model adjusted for residual autocorrelation")


