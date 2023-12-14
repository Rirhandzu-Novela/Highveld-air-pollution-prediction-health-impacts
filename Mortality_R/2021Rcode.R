# LOAD THE DATA INTO THE SESSION
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
plot(data$Date,data$Count,pch=".",main="Daily deaths over time",
     ylab="Daily number of deaths",xlab="Date")
abline(v=data$date[grep("-01-01",data$date)],col=grey(0.6),lty=2)

# THE SAME FOR PM LEVELS
plot(data$Date,data$PM2.5,pch=".",main="PM levels over time",
     ylab="Daily mean PM level (ug/m3)",xlab="Date")
abline(v=data$date[grep("-01-01",data$date)],col=grey(0.6),lty=2)
par(oldpar)
layout(1)

library(dplyr)
df <- data %>% mutate_at(c('Rain'), as.numeric)
df[is.na(df)] = 0
summary(df)
sum(df$Count)

########################
# DESCRIPTIVE STATISTICS
########################

# SUMMARY
summary(data)

# CORRELATIONS
cor(df[,2:17])


# GENERATE FOURIER TERMS
# (USE FUNCTION harmonic, IN PACKAGE tsModel TO BE INSTALLED AND THEN LOADED)
#install.packages("tsModel")
library(tsModel)

# 4 SINE-COSINE PAIRS REPRESENTING DIFFERENT HARMONICS WITH PERIOD 1 YEAR
data$time <- seq(nrow(data))
fourier <- harmonic(data$time,nfreq=4,period=365.25)

library("dlnm")
vignette("dlnmOverview")

# CHECK VERSION OF THE PACKAGE
if(packageVersion("dlnm")<"2.2.0")
  stop("update dlnm package to version >= 2.2.0")

####################################################################
# NON-LINEAR AND DELAYED EFFECTS
####################################################################

# NB: THE FUNCTIONS mkbasis and mklagbasis HAVE BEEN REPLACED BY onebasis
# NB: CENTERING MOVED TO PREDICTION STAGE
onebasis(1:5, fun="bs", df=4, degree=2)
onebasis(1:5, fun="strata", breaks=c(2,4))

####################################################################
# SPECIFYING A DLNM
####################################################################

basis.PM <- crossbasis(data$PM2.5, lag=10, 
  argvar=list(fun="thr",thr.value=40.3,side="h"),
  arglag=list(fun="strata",breaks=c(2,6)))

klag <- exp(((1+log(30))/4 * 1:3)-1)
basis.temp <- crossbasis(data$Temperature, lag=10,
  argvar=list(fun="bs",degree=3,df=6), arglag=list(knots=klag))

summary(basis.temp)

library("splines")
model <- glm(Count ~ basis.temp + basis.PM + ns(time,7*14) + weekday1,
  family=quasipoisson(), data)

####################################################################
# PREDICTING A DLNM
####################################################################

pred.PM <- crosspred(basis.PM, model, at=c(0:65,40.3,50.3))
pred.temp <- crosspred(basis.temp, model, by=2, cen=25)

pred.PM$allRRfit["50.3"]
cbind(pred.PM$allRRlow,pred.PM$allRRhigh)["50.3",]

####################################################################
# REPRESENTING A DLNM
####################################################################

plot(pred.PM, var=50.3, type="p", pch=19, cex=1.5, ci="bars", col=2,
  ylab="RR",main="Lag-specific effects")
plot(pred.PM, "overall", ci="lines", ylim=c(0.95,1.25), lwd=2, col=4,
  xlab="Ozone", ylab="RR", main="Overall effect")

plot(pred.temp, xlab="Temperature", theta=240, phi=40, ltheta=-185,
  zlab="RR", main="3D graph")
plot(pred.temp, "contour", plot.title=title(xlab="Temperature",
  ylab="Lag", main="Contour graph"), key.title=title("RR"))

plot(pred.temp, var=-20, ci="n",ylim=c(0.95,1.22), lwd=1.5, col=2)
for(i in 1:2) lines(pred.temp, "slices", var=c(0,32)[i], col=i+2, lwd=1.5)
legend("topright",paste("Temperature =",c(-20,0,32)), col=2:4, lwd=1.5)

plot(pred.temp,var=c(-20,0,32), lag=c(0,5,20), ci.level=0.99, col=2,
  xlab="Temperature",ci.arg=list(density=20,col=grey(0.7)))

####################################################################
# MODELING STRATEGIES
####################################################################

basis.temp2 <- crossbasis(data$Temperature, argvar=list(fun="poly",degree=6),
  arglag=list(knots=klag), lag=30)
model2 <- update(model, .~. - basis.temp + basis.temp2)
pred.temp2 <- crosspred(basis.temp2, model2, by=2, cen=25)

basis.temp3 <- crossbasis(data$Temperature, argvar=list(fun="thr",
  thr.value=25,side="d"), arglag=list(knots=klag), lag=30)
model3 <- update(model, .~. - basis.temp + basis.temp3)
pred.temp3 <- crosspred(basis.temp3, model3, by=2)

plot(pred.temp, "overall", ylim=c(0.5,2.5), ci="n", lwd=1.5, col=2,
  main="Overall effect")
lines(pred.temp2, "overall", col=3, lty=2, lwd=2)
lines(pred.temp3, "overall", col=4, lty=4, lwd=2)
legend("top", c("natural spline","polynomial","double threshold"), col=2:4,
  lty=c(1:2,4), lwd=1.5, inset=0.1, cex=0.8)

plot(pred.temp, "slices", var=32, ylim=c(0.95,1.22), ci="n", lwd=1.5, col=2,
  main="Lag-specific effect")
lines(pred.temp2, "slices", var=32, col=3, lty=2, lwd=2)
lines(pred.temp3, "slices", var=32, col=4, lty=4, lwd=2)
legend("top", c("natural spline","polynomial","double threshold"), col=2:4,
  lty=c(1:2,4), inset=0.1, cex=0.8)

#
