### load datasets
data = read.csv("puldata.csv", header = T, sep = ";")

## Dataframe should have a column name "Date".
names(data)[1] <- 'Date'

## The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01"), as.POSIXct("2018-12-31"), by = "24 hours", tz = 'UTC')

## Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
data$Date <- dateTime
summary(data)

## Repalce NAs with 0
data[is.na(data)] = 0

# SET THE PLOTTING PARAMETERS FOR THE PLOT
oldpar <- par(no.readonly=TRUE)
par(mex=0.8,mfrow=c(2,1))

# SUB-PLOT FOR DAILY DEATHS, WITH VERTICAL LINES DEFINING YEARS
plot(data$Date,data$Count,pch=".",main="Daily deaths over time",
     ylab="Daily number of deaths",xlab="Date")
abline(v=data$Date[grep("-01-01",data$Date)],col=grey(0.6),lty=2)

# THE SAME FOR PM LEVELS
plot(data$Date,data$PM2.5,pch=".",main="PM levels over time",
     ylab="Daily mean PM level (ug/m3)",xlab="Date")
abline(v=data$Date[grep("-01-01",data$Date)],col=grey(0.6),lty=2)
par(oldpar)
layout(1)

library(dplyr)
df <- data %>% mutate_at(c('Rain'), as.numeric)
df[is.na(df)] = 0
summary(df)
sum(df$Count)


# CORRELATIONS
cor(df[,2:17])

# MODELLING SEASONALITY AND LONG-TERM TREND
# GENERATE MONTH AND YEAR
data$month <- as.factor(months(data$Date,abbr=TRUE))
data$year <- as.factor(substr(data$Date,1,4))

# GENERATE FOURIER TERMS
#4 SINE-COSINE PAIRS REPRESENTING DIFFERENT HARMONICS WITH PERIOD 1 YEAR
library(tsModel)
data$time <- seq(nrow(data))
fourier <- harmonic(data$time,nfreq=4,period=365.25)

# SPLINE MODEL
# (FLEXIBLE SPLINE FUNCTIONS)

# GENERATE SPLINE TERMS
# (USE FUNCTION bs IN PACKAGE splines, TO BE LOADED)
library(splines)

# A CUBIC B-SPLINE WITH 32 EQUALLY-SPACED KNOTS + 2 BOUNDARY KNOTS
# (NOTE: THIS PARAMETERIZATION IS SLIGHTLY DIFFERENT THAN STATA'S)
# (THE 35 BASIS VARIABLES ARE SET AS df, WITH DEFAULT KNOTS PLACEMENT. SEE ?bs)
# (OTHER TYPES OF SPLINES CAN BE PRODUCED WITH THE FUNCTION ns. SEE ?ns)
spl <- bs(data$time,degree=3,df=35)

# FIT A POISSON MODEL FOURIER TERMS + LINEAR TERM FOR TREND
# (USE OF quasipoisson FAMILY FOR SCALING THE STANDARD ERRORS)
model1 <- glm(Count ~ spl,data,family=quasipoisson)
summary(model1)

# COMPUTE PREDICTED NUMBER OF DEATHS FROM THIS MODEL
pred1 <- predict(model1,type="response")

plot(data$Date,data$Count,ylim=c(0,25),pch=19,cex=0.2,col=grey(0.6),
     main="Flexible cubic spline model",ylab="Daily number of deaths",
     xlab="Date")
lines(data$Date,pred1,lwd=2)

# GENERATE RESIDUALS
res1 <- residuals(model1,type="response")

plot(data$Date,res1,ylim=c(-25,25),pch=19,cex=0.4,col=grey(0.6),
     main="Residuals over time",ylab="Residuals (observed-fitted)",xlab="Date")
abline(h=1,lty=2,lwd=2)

# ESTIMATING PM-MORTALITY ASSOCIATION
# (CONTROLLING FOR CONFOUNDERS)
# COMPARE THE RR (AND CI)
# (COMPUTED WITH THE FUNCTION ci.lin IN PACKAGE Epi, TO BE INSTALLED AND LOADED)

library(Epi)

# UNADJUSTED MODEL
model2 <- glm(Count ~ PM2.5,data,family=quasipoisson)
summary(model2)
(eff2 <- ci.lin(model2,subset="PM2.5",Exp=T))

# CONTROLLING FOR SEASONALITY (WITH SPLINE AS IN MODEL 1)
model3 <- update(model2,.~.+spl)
summary(model3)
(eff3 <- ci.lin(model3,subset="PM2.5",Exp=T))

# CONTROLLING FOR TEMPERATURE
# (TEMPERATURE MODELLED WITH CATEGORICAL VARIABLES FOR DECILES)
cutoffs <- quantile(data$Temperature,probs=0:10/10)
tempdecile <- cut(data$Temperature,breaks=cutoffs,include.lowest=TRUE)

model4 <- update(model3,.~.+tempdecile)
summary(model4)
(eff4 <- ci.lin(model4,subset="PM2.5",Exp=T))

# BUILD A SUMMARY TABLE
tabeff <- rbind(eff2,eff3,eff4)[,5:7]
dimnames(tabeff) <- list(c("Unadjusted","Plus season/trend","Plus temperature"),
                         c("RR","ci.low","ci.hi"))
round(tabeff,3)

# EXPLORING THE LAGGED (DELAYED) EFFECTS
# SINGLE-LAG MODELS
# PREPARE THE TABLE WITH ESTIMATES
tablag <- matrix(NA,7+1,3,dimnames=list(paste("Lag",0:7),
                                        c("RR","ci.low","ci.hi")))

# RUN THE LOOP
for(i in 0:7) {
  # LAG PM AND TEMPERATURE VARIABLES
  PMlag <- Lag(data$PM2.5,i)
  tempdecilelag <- cut(Lag(data$Temperature,i),breaks=cutoffs,
                       include.lowest=TRUE)

  # DEFINE THE TRANSFORMATION FOR TEMPERATURE
  # LAG SAME AS ABOVE, BUT WITH STRATA TERMS INSTEAD THAN LINEAR
  mod <- glm(Count ~ PMlag + tempdecilelag + spl,data,
             family=quasipoisson)
  tablag[i+1,] <- ci.lin(mod,subset="PMlag",Exp=T)[5:7]
}
tablag

plot(0:7,0:7,type="n",ylim=c(0.99,1.03),main="Lag terms modelled one at a time",
     xlab="Lag (days)",ylab="RR and 95%CI per 10ug/m3 PM increase")
abline(h=1)
arrows(0:7,tablag[,2],0:7,tablag[,3],length=0.05,angle=90,code=3)
points(0:7,tablag[,1],pch=19)

# FACILITATED BY THE FUNCTIONS IN PACKAGE dlnm
library(dlnm)


# UNCONSTRAINED DLM
# IN PARTICULAR, THE FUNCTION crossbasis PRODUCES THE TRANSFORMATION FOR 
#   SPECIFIC LAG STRUCTURES AND OPTIONALLY FOR NON-LINEARITY
# THE FUNCTION crosspred INSTEAD PREDICTS ESTIMATED EFFECTS

# PRODUCE THE CROSS-BASIS FOR OZONE (SCALING NOT NEEDED)
# A SIMPLE UNSTRANSFORMED LINEAR TERM AND THE UNCONSTRAINED LAG STRUCTURE
cbpmunc <- crossbasis(data$PM2.5,lag=c(0,7),argvar=list(fun="lin"),
                      arglag=list(fun="integer"))
summary(cbpmunc)

# PRODUCE THE CROSS-BASIS FOR TEMPERATURE
# AS ABOVE, BUT WITH STRATA DEFINED BY INTERNAL CUT-OFFS
cbtempunc <- crossbasis(data$Temperature,lag=c(0,7),
                        argvar=list(fun="strata",breaks=cutoffs[2:10]),
                        arglag=list(fun="integer"))
summary(cbtempunc)

sum(is.na(data$Count))
sum(is.na(cbpmunc))
sum(is.na(cbtempunc))
sum(is.na(spl))

# Impute missing values in cbpmunc with mean
mean_cbpmunc <- mean(cbpmunc, na.rm = TRUE)
cbpmunc[is.na(cbpmunc)] <- mean_cbpmunc

# Impute missing values in cbtempunc with mean
mean_cbtempunc <- mean(cbtempunc, na.rm = TRUE)
cbtempunc[is.na(cbtempunc)] <- mean_cbtempunc

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR PM LEVEL 10ug/m3
model5 <- glm(Count ~ cbpmunc + cbtempunc + spl,data,family=quasipoisson)
pred5 <- crosspred(cbpmunc,model5,at=10)

# ESTIMATED EFFECTS AT EACH LAG
tablag2 <- with(pred5,t(rbind(matRRfit,matRRlow,matRRhigh)))
colnames(tablag2) <- c("RR","ci.low","ci.hi")
tablag2

# OVERALL CUMULATIVE (NET) EFFECT
pred5$allRRfit ; pred5$allRRlow ; pred5$allRRhigh

plot(pred5,var=10,type="p",ci="bars",col=1,pch=19,ylim=c(0.99,1.03),
     main="All lag terms modelled together (unconstrained)",xlab="Lag (days)",
     ylab="RR and 95%CI per 10ug/m3 PM increase")

# CONSTRAINED (LAG-STRATIFIED) DLM
# PRODUCE A DIFFERENT CROSS-BASIS FOR PM
# USE STRATA FOR LAG STRUCTURE, WITH CUT-OFFS DEFINING RIGHT-OPEN INTERVALS 
cbpmconstr <- crossbasis(data$PM2.5,lag=c(0,7),argvar=list(fun="lin"),
                         arglag=list(fun="strata",breaks=c(1,3)))
summary(cbpmconstr)

# RUN THE MODEL AND OBTAIN PREDICTIONS FOR PM LEVEL 10ug/m3
model6 <- glm(Count ~ cbpmconstr + cbtempunc + spl,data,family=quasipoisson)
pred6 <- crosspred(cbpmconstr,model6,at=10)


# ESTIMATED EFFECTS AT EACH LAG
tablag3 <- with(pred6,t(rbind(matRRfit,matRRlow,matRRhigh)))
colnames(tablag3) <- c("RR","ci.low","ci.hi")
tablag3

# OVERALL CUMULATIVE (NET) EFFECT
pred6$allRRfit ; pred6$allRRlow ; pred6$allRRhigh

plot(pred6,var=10,type="p",ci="bars",col=1,pch=19,ylim=c(0.99,1.03),
     main="All lag terms modelled together (RD)",xlab="Lag (days)",
     ylab="RR and 95%CI per 10ug/m3 PM increase")

# MODEL CHECKING
# GENERATE DEVIANCE RESIDUALS FROM UNCONSTRAINED DISTRIBUTED LAG MODEL

res5 <- residuals(model5,type="deviance")

plot(data$Date,res5,ylim=c(-25,25),pch=19,cex=0.7,col=grey(0.6),
     main="Residuals over time",ylab="Deviance residuals",xlab="Date")
abline(h=0,lty=2,lwd=2)

pacf(res5,na.action=na.omit,main="From original model")

# INCLUDE THE 1-DAY LAGGED RESIDUAL IN THE MODEL
model7 <- update(model5,.~.+Lag(res5,1))

pacf(residuals(model7,type="deviance"),na.action=na.omit,
     main="From model adjusted for residual autocorrelation")


