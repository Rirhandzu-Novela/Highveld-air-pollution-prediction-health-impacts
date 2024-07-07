library(tidyverse)


# LOAD THE DATA INTO THE SESSION
data = read.csv("MortData/GertPollCardMort.csv", header = T, sep = ";")

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

ggplot(data, aes(x = date, y = death_count)) +
  geom_point(size = 0.5) +
  geom_vline(xintercept = as.numeric(data$date[grep("-01-01", data$date)]), color = "grey60", linetype = "dashed") +
  labs(title = "Daily Deaths Over Time", y = "Daily Number of Deaths", x = "Date") +
  theme_minimal()


ggplot(data, aes(x = date, y = PM2.5)) +
  geom_point(size = 0.5) +
  geom_vline(xintercept = as.numeric(data$date[grep("-01-01", data$date)]), color = "grey60", linetype = "dashed") +
  labs(title = "Daily Deaths Over Time", y = "Daily Number of Deaths", x = "Date") +
  theme_minimal()



########################
# DESCRIPTIVE STATISTICS
########################


# CORRELATIONS

#cor_data <- data %>%
#  select(-date) %>%
#  cor(use = "complete.obs")


library(corrplot)
library(Hmisc)

cor_data  <- data %>%
  select(-date)


GertCardcor <- rcorr(as.matrix(cor_data ), type = "pearson")
GertCardcor.coeff = GertCardcor$r
GertCardcor.p = GertCardcor$P


GertCardcorplot <- corrplot.mixed(GertCardcor.coeff, mar = c(0,0,1,0), lower = 'number', upper = 'ellipse', title = "Air pollutant correlation")


# GENERATE FOURIER TERMS
# (USE FUNCTION harmonic, IN PACKAGE tsModel TO BE INSTALLED AND THEN LOADED)
library(tsModel)

# 4 SINE-COSINE PAIRS REPRESENTING DIFFERENT HARMONICS WITH PERIOD 1 YEAR
data$time <- seq(nrow(data))
fourier <- harmonic(data$time,nfreq=4,period=365.25)


# Convert fourier_terms to a data frame and add to the main data frame
fourier_df <- as.data.frame(fourier)
names(fourier_df) <- paste0("Fourier", seq(ncol(fourier_df)))

# Combine the data with Fourier terms
data_fourier <- bind_cols(data, fourier_df)



library("dlnm")
#vignette("dlnmOverview")

# CHECK VERSION OF THE PACKAGE
#if(packageVersion("dlnm")<"2.2.0")
#  stop("update dlnm package to version >= 2.2.0")

####################################################################
# NON-LINEAR AND DELAYED EFFECTS
####################################################################

# NB: THE FUNCTIONS mkbasis and mklagbasis HAVE BEEN REPLACED BY onebasis
# NB: CENTERING MOVED TO PREDICTION STAGE
b_splines_basis <- onebasis(1:5, fun="bs", df=4, degree=2)

strata_basis <- onebasis(1:5, fun="strata", breaks=c(25,50,75))

####################################################################
# SPECIFYING A DLNM
####################################################################

basis.pm <- crossbasis(data$pm2.5, lag=10, 
  argvar=list(fun="thr",thr.value=40.3,side="h"),
  arglag=list(fun="strata",breaks=c(2,6)))

klag <- exp(((1+log(30))/4 * 1:3)-1)
basis.temp <- crossbasis(data$temp, lag=10,
  argvar=list(fun="bs",degree=3,df=6), arglag=list(knots=klag))

summary(basis.temp)

library("splines")
model <- glm(death_count ~ basis.temp + basis.pm + ns(time,7*14),
  family=quasipoisson(), data)

####################################################################
# PREDICTING A DLNM
####################################################################

pred.pm <- crosspred(basis.pm, model, at=c(0:65,40.3,50.3))
pred.temp <- crosspred(basis.temp, model, by=2, cen=25)


plot(pred.pm, "overall", main="Effect of PM on Cardiovascular Deaths",
     xlab="PM concentration", ylab="Relative Risk", lwd=2, ci="area", col="blue")

pred.pm$allRRfit["50.3"]
cbind(pred.pm$allRRlow,pred.pm$allRRhigh)["50.3",]

####################################################################
# REPRESENTING A DLNM
####################################################################

plot(pred.pm, var=50.3, type="p", pch=19, cex=1.5, ci="bars", col=2,
  ylab="RR",main="Lag-specific effects")

plot(pred.pm, "contour", plot.title=title(xlab="Temperature",
  ylab="Lag", main="Contour graph"), key.title=title("RR"))

plot(pred.pm, "overall", ci="lines", ylim=c(0.95,1.25), lwd=2, col=4,
  xlab="PM", ylab="RR", main="Overall effect")

# Plot overall effect of NO2 across a range of concentrations and lags (contour plot)
plot(pred.pm, "contour", xlab = "Lag (days)", ylab = "PM concentration",
     key.title = title("Relative Risk"), main = "Contour plot of PM effects")

# Plot perspective plot of NO2 effects
plot(pred.pm, "persp", xlab = "Lag (days)", ylab = "PM concentration", zlab = "Relative Risk",
     main = "Perspective plot of PM effects", theta = 230, phi = 40, ltheta = 120, shade = 0.75)




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

basis.temp2 <- crossbasis(data$temp, argvar=list(fun="poly",degree=6),
  arglag=list(knots=klag), lag=30)
model2 <- update(model, .~. - basis.temp + basis.temp2)
pred.temp2 <- crosspred(basis.temp2, model2, by=2, cen=25)






basis.temp3 <- crossbasis(data$temp, argvar=list(fun="thr",
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
# Create predictions for a 10 ppb increase in NO2
# Define the increment of 10 ppb
increment <- 10

# Create a new prediction object for NO2 with the specified increment
pred.pm_increment <- crosspred(basis.pm, model, at = seq(0, 60, by = 1) + increment)

str(pred.pm_increment)

# Extract relative risk and confidence intervals
rr <- pred.pm_increment$allRRfit  # All relative risks
ci_lower <- pred.pm_increment$allRRlow  # Lower confidence interval
ci_upper <- pred.pm_increment$allRRhigh  # Upper confidence interval

# Find the index corresponding to the increment value (10 ppb)
increment <- 10
index_increment <- which.min(abs(as.numeric(names(rr)) - increment))

# Print relative risk and CI for a 10 ppb increase in NO2
cat(sprintf("Relative Risk (RR) for a %d ppb increase in NO2: %.3f\n", increment, rr[index_increment]))
cat(sprintf("95%% Confidence Interval (CI) for RR: [%.3f, %.3f]\n", ci_lower[index_increment], ci_upper[index_increment]))


