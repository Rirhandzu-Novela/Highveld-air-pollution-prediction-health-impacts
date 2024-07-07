library(imputeTS)
library(tidyverse)
library("openair")


# Imputation --------------------------------------------------------------

df <- read.csv('AirData/Nkangala.csv', header = T, sep = ';')


data <- df %>%
  mutate(across(.cols = -Amb.Temp, ~ ifelse(. < 0, NA, .)))
summary(data)

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')


# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
data$date <- dateTime


imputes <- na_kalman(data, model = "StructTS", smooth = TRUE, type = "trend")
summary(imputes)


impT <- arima(data$Amb.Temp, order = c(1, 0, 1))$model 
temp <- na_kalman(data, model = impT)


imputes$Amb.Temp <- temp$Amb.Temp


impR <- arima(data$Amb.RelHum, order = c(1, 0, 0))$model 
Relhum <- na_kalman(data, model = impR)

imputes$Amb.RelHum <- Relhum$Amb.RelHum

summary(imputes)

write.csv(imputes,"AirData/NkangalaIM.csv")

# Daily Ave ---------------------------------------------------------------



Nka = read.csv("AirData/Nkangala.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Nka$date <- dateTime



daily <- timeAverage(Nka, avg.time = "day")
write.csv(daily,"AirData/NkaDaily.csv")


# Time series -------------------------------------------------------------

Nka = read.csv("AirData/NkangalaDaily.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Nka$date <- dateTime

timeVariation(Nka, pollutant = "O3", main = "Nkangala O3 Temporal variation", ylab = "O3 (ppb)")
timeVariation(Nka, pollutant = "CO", main = "Nkangala CO Temporal variation", ylab = "CO (ppm)")
timeVariation(Nka, pollutant = "PM10", main = "Nkangala PM10 Temporal variation", ylab = "PM10 (ug/m3)")
timeVariation(Nka, pollutant = "PM2.5",main = "Nkangala PM2.5 Temporal variation", ylab = "PM2.5 (ug/m3)")
timeVariation(Nka, pollutant = "SO2", main = "Nkangala SO2 Temporal variation", ylab = "SO2 (ppb)")
timeVariation(Nka, pollutant = "NO2", main = "Nkangala N02 Temporal variation", ylab = "NO2 (ppb)")


timePlot(Nka, pollutant = "NO2", main = "Nkangala NO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "NO2 (ppb)")
timePlot(Nka, pollutant = "SO2", main = "Nkangala SO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "SO2 (ppb)")
timePlot(Nka, pollutant = "PM10", main = "Nkangala PM10 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "PM10 (ug/m3)" )
timePlot(Nka, pollutant = "PM2.5", main = "Nkangala PM2.5 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "PM2.5 (ug/m3)")

timePlot(Nka, pollutant = "NO2", main = "Nkangala NO2 monthly concentrations", xlab = "Time", avg.time = "month")
timePlot(Nka, pollutant = "NO2",main = "Nkangala NO2 annual concentrations",xlab = "Time", avg.time = "year")


plot(Nka$Day,Nka$PM10, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM10 (ug/m3)",  main = "Nkangala PM10 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(Nka$Day,Nka$PM2.5, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM2.5 (ug/m3)",  main = "Nkangala PM2.5 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(Nka$Day,Nka$NO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "NO2 (PPb)",  main = "Nkangala NO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(Nka$Day,Nka$SO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "SO2 (ug/m3)",  main = "Nkangala SO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

model = TheilSen(Nka, "O3", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Nkangala O3 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Nka, "CO", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppm)",
                 main = "Nkangala CO Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Nka, "NO2", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Nkangala NO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Nka, "SO2", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Nkangala SO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Nka, "PM2.5", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Nkangala PM2.5 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Nka, "PM10", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Nkangala PM10 Deseasonalised Trends", data.col = "black", text.col = "black")




# DOW ---------------------------------------------------------------------


###DOW
start = as.POSIXct("2009-01-01")
end = as.POSIXct("2018-12-31")

dat = data.frame(Date = seq.POSIXt(from = start,
                                   to = end,
                                   by = "DSTday"))

# see ?strptime for details of formats you can extract

# day of the week as numeric (Monday is 1)
dat$weekday1 = as.numeric(format(dat$Date, format = "%u"))

# abbreviated weekday name
dat$weekday2 = format(dat$Date, format = "%a")

# full weekday name
dat$weekday3 = format(dat$Date, format = "%A")

dat
write.csv(dat,"AirData/dow.csv")