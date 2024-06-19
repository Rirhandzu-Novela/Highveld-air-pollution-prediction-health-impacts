
library(imputeTS)
library(tidyverse)


df <- read.csv('Data/eMalahleni.csv', header = T, sep = ';')


data <- df %>%
  mutate(across(.cols = -Amb.Temp, ~ ifelse(. < 0, NA, .)))
summary(data)

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')


# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
data$Date <- dateTime


imputes <- na_kalman(data, model = "StructTS", smooth = TRUE, type = "trend")
summary(imputes)


impT <- arima(data$Amb.Temp, order = c(1, 0, 1))$model 
temp <- na_kalman(data, model = impT)


imputes$Amb.Temp <- temp$Amb.Temp


impR <- arima(data$Amb.RelHum, order = c(1, 0, 0))$model 
Relhum <- na_kalman(data, model = impR)

imputes$Amb.RelHum <- Relhum$Amb.RelHum

summary(imputes)

write.csv(imputes,"Data/eMalahleniIM.csv")
