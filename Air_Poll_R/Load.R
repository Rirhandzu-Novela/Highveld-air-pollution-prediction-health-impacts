# Load packages -----------------------------------------------------------

library(tidyverse)
library(openair)
library(novaAQM)
library(slider)
library(openairmaps)
library(broom)
library(gridExtra)
library(corrplot)
library(Hmisc)
library(plotly)
library(ggpubr)
library(imputeTS)

# Read eMalahleni csv ----------------------------------------------------------

eMalahleni = read.csv("AirData/eMalahleni.csv", header = T, sep = ";")

eMalahleni <- eMalahleni %>%
  rename(so2 = SO2,
         co = CO,
         no = NO,
         no2 = NO2,
         nox = NOx,
         pm10 = PM10,
         pm2.5 = PM2.5,
         o3 = O3,
         ws = Amb.Wspeed,
         wd = Amb.WDirection,
         temp = Temperature,
         relHum = Amb.RelHum,
         pressure = Amb.Pressure,
         rain = Rain,
         date = Date.Time)


# Dataframe should have a column name "date". It is mandatory for OpenAir
names(eMalahleni)[1] <- 'date'

# The dates must be a "POSIXct" "POSIXt" object.
date <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')
date <- date[-length(date)]

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
eMalahleni$date <- date
summary(eMalahleni)

eMalahleni_clean <- eMalahleni %>%
  mutate(across(-date, ~ if_else(. <= 0 | is.infinite(.), NA_real_, .))) %>%
  mutate(pm10 = case_when(pm10 > 800 ~ NA, .default = pm10)) %>%
  mutate(pm2.5 = case_when(pm2.5 > 500 ~ NA, .default = pm2.5)) %>%
  mutate(so2 = case_when(so2 > 300 ~ NA, .default = so2)) %>%
  mutate(no2 = case_when(no2 > 150 ~ NA, .default = no2)) %>%
  mutate(no = case_when(no > 400 ~ NA, .default = no)) %>%
  mutate(nox = case_when(nox > 400 ~ NA, .default = nox)) %>%
  mutate(o3 = case_when(o3 > 100 ~ NA, .default = o3)) %>%
  mutate(co = case_when(co > 10 ~ NA, .default = co)) %>%
  mutate(ws = case_when(ws > 15 ~ NA, .default = ws)) %>%
  mutate(pressure = case_when(pressure < 800 ~ NA, .default = pressure)) %>%
  mutate(no = case_when(between(date, as_datetime("2013-01-01 00:00:00"), as_datetime("2013-06-30 23:00:00")) ~ NA, .default = no)) %>%
  mutate(no2 = case_when(between(date, as_datetime("2013-01-01 00:00:00"), as_datetime("2013-06-30 23:00:00")) ~ NA, .default = no2)) %>%
  mutate(nox = case_when(between(date, as_datetime("2013-01-01 00:00:00"), as_datetime("2013-06-30 23:00:00")) ~ NA, .default = nox)) %>%
  mutate(no2 = case_when(between(date, as_datetime("2015-08-01 00:00:00"), as_datetime("2015-08-30 23:00:00")) ~ NA, .default = no2)) %>%
  mutate(nox = case_when(between(date, as_datetime("2015-08-01 00:00:00"), as_datetime("2015-08-30 23:00:00")) ~ NA, .default = nox)) %>%
  mutate(station = all_of("eMalahleni"))



eMalahleni_clean$date <- format(eMalahleni_clean$date, "%Y-%m-%d %H:%M:%S")

summary(eMalahleni_clean)

eMalahleniIM <- na_kalman(eMalahleni_clean, model = "StructTS", smooth = TRUE, type = "trend")
summary(eMalahleniIM)

usermodel <- arima(eMalahleni_clean$temp, order = c(1, 0, 1))$model
eMalahleniIMT <- na_kalman(eMalahleni_clean$temp, model = usermodel)
eMalahleniIM$temp <- eMalahleniIMT


usermodel <- arima(eMalahleni_clean$relHum, order = c(0, 0, 0))$model
eMalahleniIMRH <- na_kalman(eMalahleni_clean$relHum, model = usermodel)
eMalahleniIM$relHum <- eMalahleniIMRH


summary(eMalahleniIM)

write_csv(eMalahleniIM, file = "AirData/eMalahleniIM.csv")

# Read Ermelo csv ----------------------------------------------------------

Ermelo = read.csv("AirData/Ermelo.csv", header = T, sep = ";")

Ermelo <- Ermelo %>%
  rename(so2 = SO2,
         co = CO,
         no = NO,
         no2 = NO2,
         nox = NOx,
         pm10 = PM10,
         pm2.5 = PM2.5,
         o3 = O3,
         ws = Amb.Wspeed,
         wd = Amb.WDirection,
         temp = Temperature,
         relHum = Amb.RelHum,
         pressure = Amb.Pressure,
         rain = Rain,
         date = Date.Time)

# Dataframe should have a column name "date". It is mandatory for OpenAir
names(Ermelo)[1] <- 'date'

# The dates must be a "POSIXct" "POSIXt" object.
date <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
Ermelo$date <- date

summary(Ermelo)

Ermelo_clean <- Ermelo %>%
  mutate(across(-c(date, temp), ~ if_else(. <= 0 | is.infinite(.), NA_real_, .))) %>%
  mutate(pm10 = case_when(pm10 > 800 ~ NA, .default = pm10)) %>%
  mutate(pm2.5 = case_when(pm2.5 > 500 ~ NA, .default = pm2.5)) %>%
  mutate(so2 = case_when(so2 > 200 ~ NA, .default = so2)) %>%
  mutate(no2 = case_when(no2 > 150 ~ NA, .default = no2)) %>%
  mutate(no = case_when(no > 200 ~ NA, .default = no)) %>%
  mutate(nox = case_when(nox > 400 ~ NA, .default = nox)) %>%
  mutate(o3 = case_when(o3 > 100 ~ NA, .default = o3)) %>%
  mutate(co = case_when(co > 10 ~ NA, .default = co)) %>%
  mutate(ws = case_when(ws > 15 ~ NA, .default = ws)) %>%
  mutate(pressure = case_when(pressure < 800 ~ NA, .default = pressure)) %>%
  mutate(pressure = case_when(pressure > 840 ~ NA, .default = pressure)) %>%
  mutate(nox = ifelse(year(date) == 2010 & nox > 150, NA, nox)) %>%
  mutate(no = case_when(between(date, as_datetime("2011-10-01 00:00:00"), as_datetime("2011-12-30 23:00:00")) ~ NA, .default = no)) %>%
  mutate(no2 = case_when(between(date, as_datetime("2011-10-01 00:00:00"), as_datetime("2011-12-30 23:00:00")) ~ NA, .default = no2)) %>%
  mutate(nox = case_when(between(date, as_datetime("2011-10-01 00:00:00"), as_datetime("2011-12-30 23:00:00")) ~ NA, .default = nox)) %>%
  mutate(pm2.5 = case_when(between(date, as_datetime("2018-05-01 00:00:00"), as_datetime("2018-06-30 23:00:00")) ~ NA, .default = pm2.5)) %>%
  mutate(pm10 = case_when(between(date, as_datetime("2018-05-01 00:00:00"), as_datetime("2018-06-30 23:00:00")) ~ NA, .default = pm10)) %>%
  mutate(co = case_when(between(date, as_datetime("2012-05-01 00:00:00"), as_datetime("2012-06-30 23:00:00")) ~ NA, .default = co)) %>%
  mutate(temp = case_when(between(date, as_datetime("2009-06-01 00:00:00"), as_datetime("2009-08-31 23:00:00")) ~ NA, .default = temp)) %>%
  mutate(relHum = case_when(between(date, as_datetime("2013-01-15 00:00:00"), as_datetime("2013-04-15 23:00:00")) ~ NA, .default = relHum))

Ermelo_clean$date <- format(Ermelo_clean$date, "%Y-%m-%d %H:%M:%S")


summary(Ermelo_clean)

ErmeloIM <- na_kalman(Ermelo_clean, model = "StructTS", smooth = TRUE, type = "trend")
summary(ErmeloIM)

usermodel <- arima(Ermelo_clean$temp, order = c(1, 0, 1))$model
ErmeloIMT <- na_kalman(Ermelo_clean$temp, model = usermodel)
ErmeloIM$temp <- ErmeloIMT


usermodel <- arima(Ermelo_clean$relHum, order = c(0, 0, 0))$model
ErmeloIMRH <- na_kalman(Ermelo_clean$relHum, model = usermodel)
ErmeloIM$relHum <- ErmeloIMRH

summary(ErmeloIM)

write_csv(ErmeloIM, file = "AirData/ErmeloIM.csv")

# Read Hendrina csv ----------------------------------------------------------

Hendrina = read.csv("AirData/Hendrina.csv", header = T, sep = ";")

Hendrina <- Hendrina %>%
  rename(so2 = SO2,
         co = CO,
         no = NO,
         no2 = NO2,
         nox = NOx,
         pm10 = PM10,
         pm2.5 = PM2.5,
         o3 = O3,
         ws = Amb.Wspeed,
         wd = Amb.WDirection,
         temp = Temperature,
         relHum = Amb.RelHum,
         pressure = Amb.Pressure,
         rain = Rain,
         date = Date.Time)

# Dataframe should have a column name "date". It is mandatory for OpenAir
names(Hendrina)[1] <- 'date'

# The dates must be a "POSIXct" "POSIXt" object.
date <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')
#date <- date[-length(date)]
# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
Hendrina$date <- date


summary(Hendrina)

Hendrina_clean <- Hendrina %>%
  mutate(across(-date, ~ if_else(. <= 0 | is.infinite(.), NA_real_, .))) %>%
  mutate(pm10 = case_when(pm10 > 800 ~ NA, .default = pm10)) %>%
  mutate(pm2.5 = case_when(pm2.5 > 300 ~ NA, .default = pm2.5)) %>%
  mutate(so2 = case_when(so2 > 400 ~ NA, .default = so2)) %>%
  mutate(no2 = case_when(no2 > 100 ~ NA, .default = no2)) %>%
  mutate(no = case_when(no > 250 ~ NA, .default = no)) %>%
  mutate(nox = case_when(nox > 300 ~ NA, .default = nox)) %>%
  mutate(o3 = case_when(o3 > 150 ~ NA, .default = o3)) %>%
  mutate(co = case_when(co > 4 ~ NA, .default = co)) %>%
  mutate(ws = case_when(ws > 15 ~ NA, .default = ws)) %>%
  mutate(pressure = case_when(pressure < 825 ~ NA, .default = pressure)) %>%
  mutate(pressure = case_when(pressure > 850 ~ NA, .default = pressure)) %>%
  mutate(nox = ifelse(year(date) == 2009 & nox > 250, NA, nox)) %>%
  mutate(nox = ifelse(year(date) ==  2010 & nox > 250, NA, nox)) %>%
  mutate(so2 = ifelse(year(date) == 2013 & so2 > 200, NA, so2)) %>%
  mutate(so2 = ifelse(year(date) == 2014 & so2 > 200, NA, so2)) %>%
  mutate(so2 = ifelse(year(date) == 2015 & so2 > 200, NA, so2))

Hendrina_clean$date <- format(Hendrina_clean$date, "%Y-%m-%d %H:%M:%S")

summary(Hendrina_clean)

HendrinaIM <- na_kalman(Hendrina_clean, model = "StructTS", smooth = TRUE, type = "trend")
summary(HendrinaIM)

usermodel <- arima(Hendrina_clean$temp, order = c(1, 0, 1))$model
HendrinaIMT <- na_kalman(Hendrina_clean$temp, model = usermodel)
HendrinaIM$temp <- HendrinaIMT


usermodel <- arima(Hendrina_clean$relHum, order = c(0, 0, 0))$model
HendrinaIMRH <- na_kalman(Hendrina_clean$relHum, model = usermodel)
HendrinaIM$relHum <- HendrinaIMRH

summary(HendrinaIM)


write_csv(HendrinaIM, file = "AirData/HendrinaIM.csv")

# Read Middelburg csv ----------------------------------------------------------

Middelburg = read.csv("AirData/Middelburg.csv", header = T, sep = ";")

Middelburg <- Middelburg %>%
  rename(so2 = SO2,
         co = CO,
         no = NO,
         no2 = NO2,
         nox = NOx,
         pm10 = PM10,
         pm2.5 = PM2.5,
         o3 = O3,
         ws = Amb.Wspeed,
         wd = Amb.WDirection,
         temp = Temperature,
         relHum = Amb.RelHum,
         pressure = Amb.Pressure,
         rain = Rain,
         date = Date.Time)

# Dataframe should have a column name "date". It is mandatory for OpenAir
names(Middelburg)[1] <- 'date'

# The dates must be a "POSIXct" "POSIXt" object.
date <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')
# date <- date[-length(date)]
# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
Middelburg$date <- date



summary(Middelburg)

Middelburg_clean <- Middelburg %>%
  mutate(across(-date, ~ if_else(. <= 0 | is.infinite(.), NA_real_, .))) %>%
  mutate(pm10 = case_when(pm10 > 600 ~ NA, .default = pm10)) %>%
  mutate(pm2.5 = case_when(pm2.5 > 300 ~ NA, .default = pm2.5)) %>%
  mutate(so2 = case_when(so2 > 200 ~ NA, .default = so2)) %>%
  mutate(no2 = case_when(no2 > 60 ~ NA, .default = no2)) %>%
  mutate(no = case_when(no > 300 ~ NA, .default = no)) %>%
  mutate(nox = case_when(nox > 300 ~ NA, .default = nox)) %>%
  mutate(o3 = case_when(o3 > 150 ~ NA, .default = o3)) %>%
  mutate(co = case_when(co > 4 ~ NA, .default = co)) %>%
  mutate(ws = case_when(ws > 15 ~ NA, .default = ws)) %>%
  mutate(pressure = case_when(pressure < 840 ~ NA, .default = pressure)) %>%
  mutate(pressure = case_when(pressure > 870 ~ NA, .default = pressure)) %>%
  mutate(no = ifelse(year(date) == 2010 & no > 150, NA, no)) %>%
  mutate(nox = ifelse(year(date) ==  2011 & nox > 100, NA, nox)) %>%
  mutate(so2 = ifelse(year(date) == 2012 & so2 > 80, NA, so2)) %>%
  mutate(so2 = ifelse(year(date) == 2014 & so2 > 150, NA, so2)) %>%
  mutate(pm10 = ifelse(year(date) == 2014 & pm10 > 300, NA, pm10)) %>%
  mutate(pm10 = ifelse(year(date) == 2016 & pm10 > 300, NA, pm10)) %>%
  mutate(o3 = case_when(between(date, as_datetime("2013-06-01 00:00:00"), as_datetime("2013-06-30 23:00:00")) ~ NA, .default = o3)) %>%
  mutate(o3 = case_when(between(date, as_datetime("2012-06-01 00:00:00"), as_datetime("2012-06-30 23:00:00")) ~ NA, .default = o3)) %>%
  mutate(o3 = case_when(between(date, as_datetime("2013-04-01 00:00:00"), as_datetime("2013-04-30 23:00:00")) ~ NA, .default = o3))

Middelburg_clean$date <- format(Middelburg_clean$date, "%Y-%m-%d %H:%M:%S")

summary(Middelburg_clean)

MiddelburgIM <- na_kalman(Middelburg_clean, model = "StructTS", smooth = TRUE, type = "trend")
summary(MiddelburgIM)

usermodel <- arima(Middelburg_clean$temp, order = c(1, 0, 1))$model
MiddelburgIMT <- na_kalman(Middelburg_clean$temp, model = usermodel)
MiddelburgIM$temp <- MiddelburgIMT


usermodel <- arima(Middelburg_clean$relHum, order = c(0, 0, 0))$model
MiddelburgIMRH <- na_kalman(Middelburg_clean$relHum, model = usermodel)
MiddelburgIM$relHum <- MiddelburgIMRH

summary(MiddelburgIM)

write_csv(MiddelburgIM, file = "AirData/MiddelburgIM.csv")

# Read Secunda csv ----------------------------------------------------------

Secunda = read.csv("AirData/Secunda.csv", header = T, sep = ";")

Secunda <- Secunda %>%
  rename(so2 = SO2,
         co = CO,
         no = NO,
         no2 = NO2,
         nox = NOx,
         pm10 = PM10,
         pm2.5 = PM2.5,
         o3 = O3,
         ws = Amb.Wspeed,
         wd = Amb.WDirection,
         temp = Temperature,
         relHum = Amb.RelHum,
         pressure = Amb.Pressure,
         rain = Rain,
         date = Date.Time)

# Dataframe should have a column name "date". It is mandatory for OpenAir
names(Secunda)[1] <- 'date'

# The dates must be a "POSIXct" "POSIXt" object.
date <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')
# date <- date[-length(date)]
# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
Secunda$date <- date


summary(Secunda)

Secunda_clean <- Secunda %>%
  mutate(across(-date, ~ if_else(. <= 0 | is.infinite(.), NA_real_, .))) %>%
  mutate(pm10 = case_when(pm10 > 2000 ~ NA, .default = pm10)) %>%
  mutate(pm2.5 = case_when(pm2.5 > 800 ~ NA, .default = pm2.5)) %>%
  mutate(so2 = case_when(so2 > 150 ~ NA, .default = so2)) %>%
  mutate(no2 = case_when(no2 > 200 ~ NA, .default = no2)) %>%
  mutate(no = case_when(no > 300 ~ NA, .default = no)) %>%
  mutate(nox = case_when(nox > 300 ~ NA, .default = nox)) %>%
  mutate(o3 = case_when(o3 > 250 ~ NA, .default = o3)) %>%
  mutate(co = case_when(co > 20 ~ NA, .default = co)) %>%
  mutate(ws = case_when(ws > 15 ~ NA, .default = ws)) %>%
  mutate(temp = case_when(temp > 37 ~ NA, .default = temp)) %>%
  mutate(pressure = case_when(pressure < 830 ~ NA, .default = pressure)) %>%
  mutate(pressure = case_when(pressure > 870 ~ NA, .default = pressure)) %>%
  mutate(pm10 = ifelse(year(date) == 2015 & pm10 > 300, NA, pm10)) %>%
  mutate(co = case_when(between(date, as_datetime("2012-04-01 00:00:00"), as_datetime("2012-07-31 23:00:00")) ~ NA, .default = co)) %>%
  mutate(co = ifelse(year(date) == 2017 & co > 10, NA, co)) %>%
  mutate(no2 = ifelse(year(date) ==  2011 & no2 > 100, NA, no2)) %>%
  mutate(nox = ifelse(year(date) == 2011 & nox > 200, NA, nox)) %>%
  mutate(temp = case_when(between(date, as_datetime("2012-04-10 00:00:00"), as_datetime("2012-06-30 23:00:00")) ~ NA, .default = temp)) %>%
  mutate(temp = case_when(between(date, as_datetime("2013-08-15 00:00:00"), as_datetime("2013-09-30 23:00:00")) ~ NA, .default = temp))


Secunda_clean$date <- format(Secunda_clean$date, "%Y-%m-%d %H:%M:%S")

SecundaIM <- na_kalman(Secunda_clean, model = "StructTS", smooth = TRUE, type = "trend")
summary(SecundaIM)

usermodel <- arima(Secunda_clean$temp, order = c(1, 0, 1))$model
SecundaIMT <- na_kalman(Secunda_clean$temp, model = usermodel)
SecundaIM$temp <- SecundaIMT


usermodel <- arima(Secunda_clean$relHum, order = c(0, 0, 0))$model
SecundaIMRH <- na_kalman(Secunda_clean$relHum, model = usermodel)
SecundaIM$relHum <- SecundaIMRH

write_csv(SecundaIM, file = "AirData/SecundaIM.csv")