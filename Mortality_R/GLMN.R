### load datasets
data = read.csv("carddata.csv", header = T, sep = ";")

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

library("dlnm")

# NON-LINEAR AND DELAYED EFFECTS
# NB: THE FUNCTIONS mkbasis and mklagbasis HAVE BEEN REPLACED BY onebasis
# NB: CENTERING MOVED TO PREDICTION STAGE
onebasis(1:5, fun="bs", df=4, degree=2)
onebasis(1:5, fun="strata", breaks=c(2,4))

# SPECIFYING A DLNM
basis.PM <- crossbasis(data$PM2.5, lag=10, 
                       argvar=list(fun="thr",thr.value=40.3,side="h"),
                       arglag=list(fun="strata",breaks=c(2,6)))

klag <- exp(((1+log(30))/4 * 1:3)-1)
basis.temp <- crossbasis(data$Temperature, lag=30,
                         argvar=list(fun="bs",degree=3,df=6), arglag=list(knots=klag))

summary(basis.temp)


library(tsModel)
data$time <- seq(nrow(data))
fourier <- harmonic(data$time,nfreq=4,period=365.25)

library("splines")
model <- glm(Count ~ basis.temp + basis.PM + ns(time,7*14),
             family=quasipoisson(), data)

# PREDICTING A DLNM
pred.PM <- crosspred(basis.PM, model, at=c(0:65,40.3,50.3))
pred.temp <- crosspred(basis.temp, model, by=2, cen=25)

pred.PM$allRRfit["50.3"]
cbind(pred.PM$allRRlow,pred.PM$allRRhigh)["50.3",]

# REPRESENTING A DLNM
plot(pred.PM, var=50.3, type="p", pch=19, cex=1.5, ci="bars", col=2,
     ylab="RR",main="Lag-specific effects")
plot(pred.PM, "overall", ci="lines", ylim=c(0.95,1.25), lwd=2, col=4,
     xlab="PM", ylab="RR", main="Overall effect")

plot(pred.temp, xlab="Temperature", theta=240, phi=40, ltheta=-185,
     zlab="RR", main="3D graph")
plot(pred.temp, "contour", plot.title=title(xlab="Temperature",
                                            ylab="Lag", main="Contour graph"), key.title=title("RR"))

plot(pred.temp, var=-20, ci="n",ylim=c(0.95,1.22), lwd=1.5, col=2)
for(i in 1:2) lines(pred.temp, "slices", var=c(0,32)[i], col=i+2, lwd=1.5)
legend("topright",paste("Temperature =",c(-20,0,32)), col=2:4, lwd=1.5)

plot(pred.temp,var=c(-20,0,32), lag=c(0,5,20), ci.level=0.99, col=2,
     xlab="Temperature",ci.arg=list(density=20,col=grey(0.7)))

