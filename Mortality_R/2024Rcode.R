library(tidyverse)
library(corrplot)
library(Hmisc)
library(tsModel)
library(splines)
library(Epi)
library(dlnm)

# LOAD THE DATA INTO THE SESSION
data = read.csv("Data/GertPollPulMort.csv", header = T, sep = ";")

data$date <- as.Date(data$date, format = "%Y/%m/%d")

## Repalce NAs with 0
data[is.na(data)] = 0

# SET THE DEFAULT ACTION FOR MISSING DATA TO na.exclude
# (MISSING EXCLUDED IN ESTIMATION BUT RE-INSERTED IN PREDICTION/RESIDUALS)
options(na.action="na.exclude")

#################################################################
# PRELIMINARY ANALYSIS
#######################

#############
# FIGURE 1
#############

# SET THE PLOTTING PARAMETERS FOR THE PLOT (SEE ?par)
oldpar <- par(no.readonly=TRUE)
par(mex=0.8,mfrow=c(2,1))

# SUB-PLOT FOR DAILY DEATHS, WITH VERTICAL LINES DEFINING YEARS
plot(data$date,data$death_count,pch=".",main="Daily deaths over time",
     ylab="Daily number of deaths",xlab="Date")
abline(v=data$date[grep("-01-01",data$date)],col=grey(0.6),lty=2)

# THE SAME FOR PM LEVELS
plot(data$date,data$pm2.5,pch=".",main="PM levels over time",
     ylab="Daily mean PM level (ug/m3)",xlab="Date")
abline(v=data$date[grep("-01-01",data$date)],col=grey(0.6),lty=2)
par(oldpar)
layout(1)


#ggplot(data, aes(x = date, y = death_count)) +
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

################################################################################
# MODELLING SEASONALITY AND LONG-TERM TREND
# (LEAVING OUT MAIN EXPOSURE FOR NOW)
############################################

##################################
# OPTION 1: TIME-STRATIFIED MODEL
# (SIMPLE INDICATOR VARIABLES)
##################################

# GENERATE MONTH AND YEAR
data$month <- as.factor(months(data$date,abbr=TRUE))
data$year <- as.factor(substr(data$date,1,4))

# FIT A POISSON MODEL WITH A STRATUM FOR EACH MONTH NESTED IN YEAR
# (USE OF quasipoisson FAMILY FOR SCALING THE STANDARD ERRORS)
model1 <- glm(death_count ~ month/year,data,family=quasipoisson)
summary(model1)

# COMPUTE PREDICTED NUMBER OF DEATHS FROM THIS MODEL
pred1 <- predict(model1,type="response")

#############
# FIGURE 2A
#############

plot(data$date,data$death_count,ylim=c(0,30),pch=19,cex=0.2,col=grey(0.6),
     main="Time-stratified model (month strata)",ylab="Daily number of deaths",
     xlab="Date")
lines(data$date,pred1,lwd=2)

#Plot the predicted and observed values

plot(data$date, data$death_count, ylim = c(0, 30), pch = 19, cex = 0.2, col = grey(0.6),
     main = "Observed vs Predicted Daily Deaths", ylab = "Daily number of deaths",
     xlab = "Date")
lines(data$date, pred1, lwd = 2, col = "blue")  # Overlay predicted values
legend("topright", legend = c("Observed", "Predicted"), col = c(grey(0.6), "blue"), lty = 1, lwd = 2, cex = 0.8)



#####################################
# OPTION 2: PERIODIC FUNCTIONS MODEL
# (FOURIER TERMS)
#####################################


# GENERATE FOURIER TERMS
# (USE FUNCTION harmonic, IN PACKAGE tsModel TO BE INSTALLED AND THEN LOADED)


# 4 SINE-COSINE PAIRS REPRESENTING DIFFERENT HARMONICS WITH PERIOD 1 YEAR
data$time <- seq(nrow(data))
fourier <- harmonic(data$time,nfreq=4,period=365.25)

#FIT A POISSON MODEL FOURIER TERMS + LINEAR TERM FOR TREND
# (USE OF quasipoisson FAMILY FOR SCALING THE STANDARD ERRORS)
model2 <- glm(death_count ~ fourier + time,data,family=quasipoisson)
summary(model2)

# COMPUTE PREDICTED NUMBER OF DEATHS FROM THIS MODEL
pred2 <- predict(model2,type="response")

#############
# FIGURE 2B
#############

plot(data$date,data$death_count,ylim=c(0,30),pch=19,cex=0.2,col=grey(0.6),
     main="Sine-cosine functions (Fourier terms)",ylab="Daily number of deaths",
     xlab="Date")
lines(data$date,pred2,lwd=2)

plot(data$date, data$death_count, ylim = c(0, 30), pch = 19, cex = 0.2, col = grey(0.6),
     main = "Observed vs Predicted Daily Deaths", ylab = "Daily number of deaths",
     xlab = "Date")
lines(data$date, pred2, lwd = 2, col = "blue")  # Overlay predicted values
legend("topright", legend = c("Observed", "Predicted"), col = c(grey(0.6), "blue"), lty = 1, lwd = 2, cex = 0.8)

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
spl <- bs(data$time,degree=3,df=35)

# FIT A POISSON MODEL FOURIER TERMS + LINEAR TERM FOR TREND
# (USE OF quasipoisson FAMILY FOR SCALING THE STANDARD ERRORS)
model3 <- glm(death_count ~ spl,data,family=quasipoisson)
summary(model3)

# COMPUTE PREDICTED NUMBER OF DEATHS FROM THIS MODEL
pred3 <- predict(model3,type="response")

#############
# FIGURE 2C
#############

plot(data$date,data$death_count,ylim=c(0,30),pch=19,cex=0.2,col=grey(0.6),
     main="Flexible cubic spline model",ylab="Daily number of deaths",
     xlab="Date")
lines(data$date,pred3,lwd=2)

#####################################
# PLOT RESPONSE RESIDUALS OVER TIME
# FROM MODEL 3
#####################################

# GENERATE RESIDUALS
res3 <- residuals(model3,type="response")

############
# FIGURE 3
############

plot(data$date,res3,ylim=c(-20,20),pch=19,cex=0.4,col=grey(0.6),
     main="Residuals over time",ylab="Residuals (observed-fitted)",xlab="Date")
abline(h=1,lty=2,lwd=2)

################################################################################
# ESTIMATING PM-MORTALITY ASSOCIATION
# (CONTROLLING FOR CONFOUNDERS)
############################################

# COMPARE THE RR (AND CI)
# (COMPUTED WITH THE FUNCTION ci.lin IN PACKAGE Epi


# UNADJUSTED MODEL
model4 <- glm(death_count ~ pm2.5,data,family=quasipoisson)
summary(model4)
(eff4 <- ci.lin(model4,subset="pm2.5",Exp=T))


# CONTROLLING FOR SEASONALITY (WITH SPLINE AS IN MODEL 3)
model5 <- update(model4,.~.+spl)
summary(model5)
(eff5 <- ci.lin(model5,subset="pm2.5",Exp=T))

#mode120 <- glm(Count ~ PM2.5 + PM10,data,family=quasipoisson)
#summary(mode120)

# CONTROLLING FOR TEMPERATURE
# (TEMPERATURE MODELLED WITH CATEGORICAL VARIABLES FOR DECILES)
# (MORE SOPHISTICATED APPROACHES ARE AVAILABLE - SEE ARMSTRONG EPIDEMIOLOGY 2006)
cutoffs <- quantile(data$temp,probs=0:10/10)
tempdecile <- cut(data$temp,breaks=cutoffs,include.lowest=TRUE)
model6 <- update(model5,.~.+tempdecile)
summary(model6)
(eff6 <- ci.lin(model6,subset="pm2.5",Exp=T))

# BUILD A SUMMARY TABLE
tabeff <- rbind(eff4,eff5,eff6)[,5:7]
dimnames(tabeff) <- list(c("Unadjusted","Plus season/trend","Plus temperature"),
                         c("RR","ci.low","ci.hi"))
round(tabeff,3)

################################################################################
# EXPLORING THE LAGGED (DELAYED) EFFECTS
############################################

#####################
# SINGLE-LAG MODELS
#####################

# PREPARE THE TABLE WITH ESTIMATES
tablag <- matrix(NA,7+1,3,dimnames=list(paste("Lag",0:7),
                                        c("RR","ci.low","ci.hi")))

# RUN THE LOOP
for(i in 0:7) {
  # LAG PM AND TEMPERATURE VARIABLES
  pm2.5lag <- Lag(data$pm2.5,i)
  tempdecilelag <- cut(Lag(data$temp,i),breaks=cutoffs,
                       include.lowest=TRUE)
  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(death_count ~ pm2.5lag + tempdecilelag + spl,data,
             family=quasipoisson)
  tablag[i+1,] <- ci.lin(mod,subset="pm2.5",Exp=T)[5:7]
}
tablag

#############
# FIGURE 4A
#############

plot(0:7,0:7,type="n",ylim=c(0.99,1.03),main="Lag terms modelled one at a time",
     xlab="Lag (days)",ylab="RR and 95%CI per 10ug/m3 PM increase")
abline(h=1)
arrows(0:7,tablag[,2],0:7,tablag[,3],length=0.05,angle=90,code=3)
points(0:7,tablag[,1],pch=19)

#####################
# UNCONSTRAINED DLM
#####################

# FACILITATED BY THE FUNCTIONS IN PACKAGE dlnm
# IN PARTICULAR, THE FUNCTION crossbasis PRODUCES THE TRANSFORMATION FOR 
#   SPECIFIC LAG STRUCTURES AND OPTIONALLY FOR NON-LINEARITY
# THE FUNCTION crosspred INSTEAD PREDICTS ESTIMATED EFFECTS

# PRODUCE THE CROSS-BASIS FOR OZONE (SCALING NOT NEEDED)
# A SIMPLE UNSTRANSFORMED LINEAR TERM AND THE UNCONSTRAINED LAG STRUCTURE
cbPMunc <- crossbasis(data$pm2.5,lag=c(0,7),argvar=list(fun="lin"),
                      arglag=list(fun="integer"))
summary(cbPMunc)

# PRODUCE THE CROSS-BASIS FOR TEMPERATURE
# AS ABOVE, BUT WITH STRATA DEFINED BY INTERNAL CUT-OFFS
cbtempunc <- crossbasis(data$temp,lag=c(0,7),
                        argvar=list(fun="strata",breaks=cutoffs[2:10]),
                        arglag=list(fun="integer"))
summary(cbtempunc)

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR OZONE LEVEL 10ug/m3
model7 <- glm(death_count ~ cbPMunc + cbtempunc + spl,data,family=quasipoisson)
pred7 <- crosspred(cbPMunc,model7,at=10)
summary(model7)

# ESTIMATED EFFECTS AT EACH LAG
tablag2 <- with(pred7,t(rbind(matRRfit,matRRlow,matRRhigh)))
colnames(tablag2) <- c("RR","ci.low","ci.hi")
tablag2

# OVERALL CUMULATIVE (NET) EFFECT
pred7$allRRfit ; pred7$allRRlow ; pred7$allRRhigh

#############
# FIGURE 4B
#############

plot(pred7,var=10,type="p",ci="bars",col=1,pch=19,ylim=c(0.60,1.40),
     main="All lag terms modelled together (unconstrained)",xlab="Lag (days)",
     ylab="RR and 95%CI per 10ug/m3 PM2.5 increase")

####################################
# CONSTRAINED (LAG-STRATIFIED) DLM
####################################

# PRODUCE A DIFFERENT CROSS-BASIS FOR PM2.5
# USE STRATA FOR LAG STRUCTURE, WITH CUT-OFFS DEFINING RIGHT-OPEN INTERVALS 
cbpmconstr <- crossbasis(data$pm2.5,lag=c(0,7),argvar=list(fun="lin"),
                         arglag=list(fun="strata",breaks=c(1,3)))
summary(cbpmconstr)

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR PM2.5 LEVEL 10ug/m3
model8 <- glm(death_count ~ cbpmconstr + cbtempunc + spl,data,family=quasipoisson)
pred8 <- crosspred(cbpmconstr,model8,at=10)
summary(model8)

# ESTIMATED EFFECTS AT EACH LAG
tablag3 <- with(pred8,t(rbind(matRRfit,matRRlow,matRRhigh)))
colnames(tablag3) <- c("RR","ci.low","ci.hi")
tablag3

# OVERALL CUMULATIVE (NET) EFFECT
pred8$allRRfit ; pred8$allRRlow ; pred8$allRRhigh

#############
# FIGURE 4C
#############

plot(pred8,var=10,type="p",ci="bars",col=1,pch=19,ylim=c(0.89,1.33),
     main="All lag terms modelled together (with costraints)",xlab="Lag (days)",
     ylab="RR and 95%CI per 10ug/m3 PM increase")

################################################################################
# MODEL CHECKING
##################

# GENERATE DEVIANCE RESIDUALS FROM UNCONSTRAINED DISTRIBUTED LAG MODEL
res7 <- residuals(model7,type="deviance")

#############
# FIGURE A1
#############

plot(data$date,res7,ylim=c(-5,10),pch=19,cex=0.7,col=grey(0.6),
     main="Residuals over time",ylab="Deviance residuals",xlab="Date")
abline(h=0,lty=2,lwd=2)

#############################
# FIGURE A2a
#############################

pacf(res7,na.action=na.omit,main="From original model")


# INCLUDE THE 1-DAY LAGGED RESIDUAL IN THE MODEL
model9 <- update(model7,.~.+Lag(res7,1))

#############################
# FIGURE A2b
#############################

pacf(residuals(model9,type="deviance"),na.action=na.omit,
     main="From model adjusted for residual autocorrelation")


