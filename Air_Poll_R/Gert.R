library(imputeTS)
library(tidyverse)
library("openair")


df <- read.csv('AirData/Gerts.csv', header = T, sep = ';')


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

write.csv(imputes,"AirData/GertsIM.csv")


# Daily Ave ---------------------------------------------------------------



Gerts = read.csv("AirData/Gerts.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Gerts$date <- dateTime



daily <- timeAverage(Gerts, avg.time = "day")
write.csv(daily,"AirData/GertsDaily.csv")



# Time series -------------------------------------------------------------

Gerts = read.csv("AirData/GertsDaily.csv", header = T, sep = ";")

Gerts$date <- as.Date(Gerts$date, format = "%Y/%m/%d")

GertsYearSum <-  Gerts %>%
  pivot_longer(cols = pm2.5:pressure, names_to = "variable") %>%
  novaAQM::datify() %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(year, variable)
  ) 
write.csv(GertsYearSum,"RDA/GertsYearSum.csv")

GertsSum <-  Gerts %>%
  pivot_longer(cols = pm2.5:pressure, names_to = "variable") %>%
  novaAQM::datify() %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(variable)
  ) 
write.csv(GertsSum,"RDA/GertsSum.csv")


timeVariation(Gerts, pollutant = "O3", main = "Gert Sibande O3 Temporal variation", ylab = "O3 (ppb)")
timeVariation(Gerts, pollutant = "CO", main = "Gert Sibande CO Temporal variation", ylab = "CO (ppm)")
timeVariation(Gerts, pollutant = "PM10", main = "Gert Sibande PM10 Temporal variation", ylab = "PM10 (ug/m3)")
timeVariation(Gerts, pollutant = "PM2.5",main = "Gert Sibande PM2.5 Temporal variation", ylab = "PM2.5 (ug/m3)")
timeVariation(Gerts, pollutant = "SO2", main = "Gert Sibande SO2 Temporal variation", ylab = "SO2 (ppb)")
timeVariation(Gerts, pollutant = "NO2", main = "Gert Sibande N02 Temporal variation", ylab = "NO2 (ppb)")


timePlot(Gerts, pollutant = "NO2", main = "Gert Sibande NO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "NO2 (ppb)")
timePlot(Gerts, pollutant = "SO2", main = "Gert Sibande SO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day",  ylab = "SO2 (ppb)")
timePlot(Gerts, pollutant = "PM10", main = "Gert Sibande PM10 daily concentrations", xlab = "Time (Daily)", avg.time = "day",  ylab = "PM10 (ug/m3)")
timePlot(a, pollutant = "PM2.5", main = "Gert Sibande PM2.5 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "PM2.5 (ug/m3)")

timePlot(Gerts, pollutant = "NO2", main = "Gert Sibande NO2 monthly concentrations", xlab = "Time", avg.time = "month")
timePlot(Gerts, pollutant = "NO2",main = "Gert Sibande NO2 annual concentrations",xlab = "Time", avg.time = "year")


plot(Gerts$date,Gerts$PM10, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM10 (ug/m3)",  main = "Gert Sibande PM10 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(Gerts$date,Gerts$PM2.5, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM2.5 (ug/m3)",  main = "Gert Sibande PM2.5 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(Gerts$date,Gerts$NO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "NO2 (PPb)",  main = "Gert Sibande NO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(Gerts$date,Gerts$SO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "SO2 (ug/m3)",  main = "Gert Sibande SO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)


model = TheilSen(Gerts, "O3", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Gert Sibande O3 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Gerts, "CO", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppm)",
                 main = "Gert Sibande CO Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Gerts, "NO2", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Gert Sibande NO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Gerts, "SO2", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Gert Sibande SO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Gerts, "PM2.5", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Gert Sibande PM2.5 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Gerts, "PM10", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Gert Sibande PM10 Deseasonalised Trends", data.col = "black", text.col = "black")

