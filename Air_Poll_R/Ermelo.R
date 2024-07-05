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

# Read dat files ----------------------------------------------------------

Ermelo = read.csv("Data/Ermelo.csv", header = T, sep = ";")

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

write_csv(ErmeloIM, file = "Data/ErmeloIM.csv")



# Time series -------------------------------------------------------------


plot_ly(data = Ermelo, x = ~date, y = ~pm2.5, type = 'scatter', mode = 'lines+markers',
        marker = list(color = 'blue'), line = list(color = 'blue')) %>%
  layout(title = 'PM2.5 Levels Over Time',
         xaxis = list(title = 'Date'),
         yaxis = list(title = 'PM2.5'))


ErmeloPTS <- timePlot(selectByDate(Ermelo_clean),
                          pollutant = c("pm2.5", "pm10", "co", "no", "no2", "nox", "so2"),
                          y.relation = "free")

ErmeloMTS  <- timePlot(selectByDate(Ermelo_clean),
                           pollutant = c("ws", "wd", "temp", "relHum", "pressure"),
                           y.relation = "free")

save(Ermelo, ErmeloMTS , file = "Data/Ermelo_Timeseriesplot.Rda")


Ermelo_clean <-Ermelo_clean %>%
  datify

PM2.5 <- timePlot(selectByDate(Ermelo_clean, year = 2013),
                  pollutant = "pm2.5")


EPM10Tempplot09 <- timeVariation(Ermelo_clean %>% filter(year == "2009"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot10 <- timeVariation(Ermelo_clean %>% filter(year == "2010"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot11 <- timeVariation(Ermelo_clean %>% filter(year == "2011"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot12 <- timeVariation(Ermelo_clean %>% filter(year == "2012"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot13 <- timeVariation(Ermelo_clean %>% filter(year == "2013"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot14 <- timeVariation(Ermelo_clean %>% filter(year == "2014"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot15 <- timeVariation(Ermelo_clean %>% filter(year == "2015"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot16 <- timeVariation(Ermelo_clean %>% filter(year == "2016"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot17 <- timeVariation(Ermelo_clean %>% filter(year == "2017"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot18 <- timeVariation(Ermelo_clean %>% filter(year == "2018"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot <- timeVariation(Ermelo_clean, stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")

EtrendPM10 <- TheilSen(Ermelo_clean, pollutant = "pm10",
         ylab = "PM10 (µg.m-3)",
         deseason = TRUE)

save(EPM10Tempplot09, EPM10Tempplot10,
     EPM10Tempplot11,EPM10Tempplot12,
     WPM10Tempplot13,EPM10Tempplot14,
     EPM10Tempplot15,EPM10Tempplot16,
     EPM10Tempplot17,EPM10Tempplot18,
     EPM10Tempplot,EtrendPM10,
     file = "Graph/ETempoaral_plotPM10.Rda")

EPM2.5Tempplot09 <- timeVariation(Ermelo_clean %>% filter(year == "2009"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2009")
EPM2.5Tempplot10 <- timeVariation(Ermelo_clean %>% filter(year == "2010"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2010")
EPM2.5Tempplot11 <- timeVariation(Ermelo_clean %>% filter(year == "2011"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2011")
EPM2.5Tempplot12 <- timeVariation(Ermelo_clean %>% filter(year == "2012"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2012")
EPM2.5Tempplot13 <- timeVariation(Ermelo_clean %>% filter(year == "2013"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2013")
EPM2.5Tempplot14 <- timeVariation(Ermelo_clean %>% filter(year == "2014"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2014")
EPM2.5Tempplot15 <- timeVariation(Ermelo_clean %>% filter(year == "2015"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2015")
EPM2.5Tempplot16 <- timeVariation(Ermelo_clean %>% filter(year == "2016"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2016")
EPM2.5Tempplot17 <- timeVariation(Ermelo_clean %>% filter(year == "2017"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2017")
EPM2.5Tempplot18 <- timeVariation(Ermelo_clean %>% filter(year == "2018"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2018")

EPM2.5Tempplot <- timeVariation(Ermelo_clean, stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "PM2.5 temporal variation at Ermelo")

EtrendPM2.5 <- TheilSen(Ermelo_clean, pollutant = "pm2.5",
                        ylab = "PM2.5 (µg.m-3)",
                        deseason = TRUE,
                        main = "PM2.5 trends at Ermelo")

save(EPM2.5Tempplot09, EPM2.5Tempplot10,
     EPM2.5Tempplot11,EPM2.5Tempplot12,
     EPM2.5Tempplot13,EPM2.5Tempplot14,
     EPM2.5Tempplot15,EPM2.5Tempplot16,
     EPM2.5Tempplot17,EPM2.5Tempplot18,
     EtrendPM2.5,WPM2.5Tempplot,
     file = "Graph/ETempoaral_plotPM2.5.Rda")

ESO2Tempplot09 <- timeVariation(Ermelo_clean %>% filter(year == "2009"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2009")
ESO2Tempplot10 <- timeVariation(Ermelo_clean %>% filter(year == "2010"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2010")
ESO2Tempplot11 <- timeVariation(Ermelo_clean %>% filter(year == "2011"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2011")
ESO2Tempplot12 <- timeVariation(Ermelo_clean %>% filter(year == "2012"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2012")
ESO2Tempplot13 <- timeVariation(Ermelo_clean %>% filter(year == "2013"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2013")
ESO2Tempplot14 <- timeVariation(Ermelo_clean %>% filter(year == "2014"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2014")
ESO2Tempplot15 <- timeVariation(Ermelo_clean %>% filter(year == "2015"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2015")
ESO2Tempplot16 <- timeVariation(Ermelo_clean %>% filter(year == "2016"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2016")
ESO2Tempplot17 <- timeVariation(Ermelo_clean %>% filter(year == "2017"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2017")
ESO2Tempplot18 <- timeVariation(Ermelo_clean %>% filter(year == "2018"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2018")

ESO2Tempplot <- timeVariation(Ermelo_clean, stati="median", poll="so2", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "SO2 temporal variation at Ermelo")

EtrendSO2 <- TheilSen(Ermelo_clean, pollutant = "so2",
                      ylab = "SO2 (µg.m-3)",
                      deseason = TRUE,
                      main = "SO2 trends at Ermelo")

save(ESO2Tempplot09, ESO2Tempplot10,
     ESO2Tempplot11,ESO2Tempplot12,
     ESO2Tempplot13,ESO2Tempplot14,
     ESO2Tempplot15,ESO2Tempplot16,
     ESO2Tempplot17,ESO2Tempplot18,
     EtrendSO2,ESO2Tempplot,
     file = "Graph/ETempoaral_plotSO2.Rda")

ENO2Tempplot09 <- timeVariation(Ermelo_clean %>% filter(year == "2009"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2009")
ENO2Tempplot10 <- timeVariation(Ermelo_clean %>% filter(year == "2010"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2010")
ENO2Tempplot11 <- timeVariation(Ermelo_clean %>% filter(year == "2011"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2011")
ENO2Tempplot12 <- timeVariation(Ermelo_clean %>% filter(year == "2012"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2012")
ENO2Tempplot13 <- timeVariation(Ermelo_clean %>% filter(year == "2013"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2013")
ENO2Tempplot14 <- timeVariation(Ermelo_clean %>% filter(year == "2014"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2014")
ENO2Tempplot15 <- timeVariation(Ermelo_clean %>% filter(year == "2015"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2015")
ENO2Tempplot16 <- timeVariation(Ermelo_clean %>% filter(year == "2016"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2016")
ENO2Tempplot17 <- timeVariation(Ermelo_clean %>% filter(year == "2017"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2017")
ENO2Tempplot18 <- timeVariation(Ermelo_clean %>% filter(year == "2018"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2018")

ENO2Tempplot <- timeVariation(Ermelo_clean, stati="median", poll="no2", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "NO2 temporal variation at Ermelo")


EtrendNO2 <- TheilSen(Ermelo_clean, pollutant = "no2",
                      ylab = "NO2 (µg.m-3)",
                      deseason = TRUE,
                      main = "NO2 trends at Ermelo")

save(ENO2Tempplot09, ENO2Tempplot10,
     ENO2Tempplot11,ENO2Tempplot12,
     ENO2Tempplot13,ENO2Tempplot14,
     ENO2Tempplot15,ENO2Tempplot16,
     ENO2Tempplot17,ENO2Tempplot18,
     EtrendNO2,ENO2Tempplot,
     file = "Graph/ETempoaral_plotNO2.Rda")


ENOTempplot09 <- timeVariation(Ermelo_clean %>% filter(year == "2009"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2009")
ENOTempplot10 <- timeVariation(Ermelo_clean %>% filter(year == "2010"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2010")
ENOTempplot11 <- timeVariation(Ermelo_clean %>% filter(year == "2011"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2011")
ENOTempplot12 <- timeVariation(Ermelo_clean %>% filter(year == "2012"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2012")
ENOTempplot13 <- timeVariation(Ermelo_clean %>% filter(year == "2013"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2013")
ENOTempplot14 <- timeVariation(Ermelo_clean %>% filter(year == "2014"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2014")
ENOTempplot15 <- timeVariation(Ermelo_clean %>% filter(year == "2015"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2015")
ENOTempplot16 <- timeVariation(Ermelo_clean %>% filter(year == "2016"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2016")
ENOTempplot17 <- timeVariation(Ermelo_clean %>% filter(year == "2017"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2017")
ENOTempplot18 <- timeVariation(Ermelo_clean %>% filter(year == "2018"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2018")

ENOTempplot <- timeVariation(Ermelo_clean, stati="median", poll="no", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "NO temporal variation at Ermelo")

EtrendNO <- TheilSen(Ermelo_clean, pollutant = "no",
                     ylab = "NO (µg.m-3)",
                     deseason = TRUE,
                     main = "NO trends at Ermelo")

save(ENOTempplot09, ENOTempplot10,
     ENOTempplot11,ENOTempplot12,
     ENOTempplot13,ENOTempplot14,
     ENOTempplot15,ENOTempplot16,
     ENOTempplot17,ENOTempplot18,
     EtrendNO,ENOTempplot,
     file = "Graph/ETempoaral_plotNO.Rda")

ENOXTempplot09 <- timeVariation(Ermelo_clean %>% filter(year == "2009"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Ermelo in 2009")
ENOXTempplot10 <- timeVariation(Ermelo_clean %>% filter(year == "2010"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Ermelo in 2010")
ENOXTempplot11 <- timeVariation(Ermelo_clean %>% filter(year == "2011"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Ermelo in 2011")
ENOXTempplot12 <- timeVariation(Ermelo_clean %>% filter(year == "2012"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Ermelo in 2012")
ENOXTempplot13 <- timeVariation(Ermelo_clean %>% filter(year == "2013"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Ermelo in 2013")
ENOXTempplot14 <- timeVariation(Ermelo_clean %>% filter(year == "2014"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Ermelo in 2014")
ENOXTempplot15 <- timeVariation(Ermelo_clean %>% filter(year == "2015"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Ermelo in 2015")
ENOXTempplot16 <- timeVariation(Ermelo_clean %>% filter(year == "2016"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Ermelo in 2016")
ENOXTempplot17 <- timeVariation(Ermelo_clean %>% filter(year == "2017"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Ermelo in 2017")

ENOXTempplot <- timeVariation(Ermelo_clean, stati="median", poll="nox", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "NOX temporal variation at Ermelo")

EtrendNOX <- TheilSen(Ermelo_clean, pollutant = "nox",
                      ylab = "NOX (µg.m-3)",
                      deseason = TRUE,
                      main = "NOX trends at Ermelo")

save(ENOXTempplot09, ENOXTempplot10,
     ENOXTempplot11,ENOXTempplot12,
     ENOXTempplot13,ENOXTempplot14,
     ENOXTempplot15,ENOXTempplot16,
     ENOXTempplot17,ENOXTempplot18,
     EtrendNOX,ENOXTempplot,
     file = "Graph/ETempoaral_plotNOX.Rda")

ECOTempplot09 <- timeVariation(Ermelo_clean %>% filter(year == "2009"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2009")
ECOTempplot10 <- timeVariation(Ermelo_clean %>% filter(year == "2010"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2010")
ECOTempplot11 <- timeVariation(Ermelo_clean %>% filter(year == "2011"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2011")
ECOTempplot12 <- timeVariation(Ermelo_clean %>% filter(year == "2012"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2012")
ECOTempplot13 <- timeVariation(Ermelo_clean %>% filter(year == "2013"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2013")
ECOTempplot14 <- timeVariation(Ermelo_clean %>% filter(year == "2014"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2014")
ECOTempplot15 <- timeVariation(Ermelo_clean %>% filter(year == "2015"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2015")
ECOTempplot16 <- timeVariation(Ermelo_clean %>% filter(year == "2016"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2016")
ECOTempplot17 <- timeVariation(Ermelo_clean %>% filter(year == "2017"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2017")
ECOTempplot18 <- timeVariation(Ermelo_clean %>% filter(year == "2018"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2018")

ECOTempplot <- timeVariation(Ermelo_clean, stati="median", poll="co", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "CO temporal variation at Ermelo")

EtrendCO <- TheilSen(Ermelo_clean, pollutant = "co",
                     ylab = "CO (µg.m-3)",
                     deseason = TRUE,
                     main = "CO trends at Ermelo")

save(ECOTempplot09, ECOTempplot10,
     ECOTempplot11,ECOTempplot12,
     ECOTempplot13,ECOTempplot14,
     ECOTempplot15,ECOTempplot16,
     ECOTempplot17,ECOTempplot18,
     EtrendCO,ECOTempplot,
     file = "Graph/ETempoaral_plotCO.Rda")

EO3Tempplot09 <- timeVariation(Ermelo_clean %>% filter(year == "2009"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2009")
EO3Tempplot10 <- timeVariation(Ermelo_clean %>% filter(year == "2010"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2010")
EO3Tempplot11 <- timeVariation(Ermelo_clean %>% filter(year == "2011"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2011")
EO3Tempplot12 <- timeVariation(Ermelo_clean %>% filter(year == "2012"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2012")
EO3Tempplot13 <- timeVariation(Ermelo_clean %>% filter(year == "2013"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2013")
EO3Tempplot14 <- timeVariation(Ermelo_clean %>% filter(year == "2014"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2014")
EO3Tempplot15 <- timeVariation(Ermelo_clean %>% filter(year == "2015"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2015")
EO3Tempplot16 <- timeVariation(Ermelo_clean %>% filter(year == "2016"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2016")
EO3Tempplot17 <- timeVariation(Ermelo_clean %>% filter(year == "2017"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2017")
EO3Tempplot18 <- timeVariation(Ermelo_clean %>% filter(year == "2018"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2018")
EO3Tempplot <- timeVariation(Ermelo_clean, stati="median", poll="o3", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "O3 temporal variation at Ermelo")

EtrendO3 <- TheilSen(Ermelo_clean, pollutant = "o3",
                     ylab = "O3 (µg.m-3)",
                     deseason = TRUE,
                     main = "O3 trends at Ermelo")

save(EO3Tempplot09, EO3Tempplot10,
     EO3Tempplot11,EO3Tempplot12,
     EO3Tempplot13,EO3Tempplot14,
     EO3Tempplot15,EO3Tempplot16,
     EO3Tempplot17,EO3Tempplot18,
     EtrendO3,EO3Tempplot,
     file = "Graph/ETempoaral_plotO3.Rda")


# AMS Averages and exceedances --------------------------------------------

Ermelo_date <- Ermelo_clean %>%
  select(date, station, pm2.5, o3, co, no2, nox, no, so2, pm10) %>%
  pivot_longer(cols = c(pm2.5, o3, no2, no, nox, so2, co, pm10), names_to = "variable") %>%
  mutate(unit = case_when(
    variable == "pm2.5" ~ "Âµg.m-3",
    variable == "o3" ~ "ppb",
    variable == "no" ~ "ppb",
    variable == "nox" ~ "ppb",
    variable == "no2" ~ "ppb",
    variable == "no" ~ "ppb",
    variable == "co" ~ "ppm",
    variable == "pm10" ~ "Âµg.m-3",
    variable == "so2" ~ "ppb",
    TRUE ~ NA_character_
  ))

Ermelo_monthly_hour_ex <- novaAQM::compareAQS(df = Ermelo_date %>%
                                                    ungroup() %>%
                                                    datify() %>%
                                                    mutate(place = station,
                                                           instrument = "SAAQIS"),
                                                  period = "hour",
                                                  by_period = quos(month, year)) %>%
  ungroup() %>%
  arrange(pollutant, month) %>%
  relocate(pollutant, .after = place)

Ermelo_season_hour_ex <- novaAQM::compareAQS(df = Ermelo_date %>%
                                                   ungroup() %>%
                                                   datify() %>%
                                                   mutate(place = station,
                                                          instrument = "SAAQIS"),
                                                 period = "hour",
                                                 by_period = quos(season, year)) %>%
  ungroup() %>%
  arrange(pollutant) %>%
  relocate(pollutant, .after = place)
season_order = tibble(season = c("autum", "winter", "spring", "summer"), season_nr = c(1, 2, 3, 4))
Ermelo_season_hour_ex <- Ermelo_season_hour_ex %>% left_join(season_order) %>% arrange(pollutant, season_nr)

Ermelo_annual_hour_ex <- novaAQM::compareAQS(df = Ermelo_date %>%
                                                   ungroup() %>%
                                                   datify() %>%
                                                   mutate(place = station,
                                                          instrument = "SAAQIS"),
                                                 period = "hour",
                                                 by_period = quos(year)) %>%
  ungroup() %>%
  arrange(pollutant, year) %>%
  relocate(pollutant, .after = place)

# Daily averages

Ermelo_Daily <- timeAverage(Ermelo_clean, avg.time = "day") %>%
  mutate(station = all_of("Ermelo"))


Ermelo_Day  <- Ermelo_Daily %>%
  select(date, station, pm2.5, o3, no2, no, nox, so2, co, pm10) %>%
  pivot_longer(cols = c(pm2.5, o3,  no2, no, nox, so2, co, pm10), names_to = "variable") %>%
  mutate(unit = case_when(
    variable == "pm10" ~ "Âµg.m-3",
    variable == "pm2.5" ~ "Âµg.m-3",
    variable == "o3" ~ "ppb",
    variable == "so2" ~ "ppb",
    variable == "no" ~ "ppb",
    variable == "no2" ~ "ppb",
    variable == "nox" ~ "ppb",
    variable == "co" ~ "ppm",
    TRUE ~ NA_character_
  ))


Ermelo_month_daily_ex <- novaAQM::compareAQS(df = Ermelo_Day %>%
                                                   ungroup() %>%
                                                   datify() %>%
                                                   mutate(place = station,
                                                          instrument = "SAAQIS"),
                                                 period = "day",
                                                 by_period = quos(month, year)) %>%
  #ungroup() %>%
  arrange(pollutant, month)



Ermelo_season_daily_ex <- novaAQM::compareAQS(df = Ermelo_Day %>%
                                                    ungroup() %>%
                                                    datify() %>%
                                                    mutate(place = station,
                                                           instrument = "SAAQIS"),
                                                  period = "day",
                                                  by_period = quos(year, season)) %>%
  #ungroup() %>%
  arrange(pollutant, season)
season_order = tibble(season = c("autum", "winter", "spring", "summer"), season_nr = c(1, 2, 3, 4))
Ermelo_season_daily_ex <- Ermelo_season_daily_ex %>% left_join(season_order) %>% arrange(pollutant, season_nr)




Ermelo_annual_daily_ex <- novaAQM::compareAQS(df = Ermelo_Day %>%
                                                    ungroup() %>%
                                                    datify() %>%
                                                    mutate(place = station,
                                                           instrument = "SAAQIS"),
                                                  period = "day",
                                                  by_period = quos(year)) %>%
  #ungroup() %>%
  arrange(pollutant, year)

save(Ermelo_monthly_hour_ex, Ermelo_season_hour_ex, Ermelo_month_daily_ex, Ermelo_season_daily_ex,
     Ermelo_annual_daily_ex, Ermelo_annual_hour_ex,  file = "Graph/Ermelo_Exceedances.Rda")

# Box plots ---------------------------------------------------------------

EBoxPM2.5Compare <- ggplot(data = Ermelo_Daily %>%
                             datify() %>%
                             select(pm2.5, year) %>%
                             mutate(perc.obs = length(which(!is.na(pm2.5))) / n(), .by = year),
                           aes(x = year, y = pm2.5 )) +
  geom_boxplot(aes(fill = perc.obs)) +
  geom_hline(yintercept = 40, linetype = "dashed", color = "red") +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "PM2.5",
    title = "Annual statistical summary of PM2.5 at Ermelo",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

EBoxPM2.5Compare


EBoxPM10Compare <- ggplot(data = Ermelo_Daily %>%
                            datify() %>%
                            select(pm10, year) %>%
                            mutate(perc.obs = length(which(!is.na(pm10))) / n(), .by = year),
                          aes(x = year, y = pm10 )) +
  geom_boxplot(aes(fill = perc.obs)) +
  geom_hline(yintercept = 75, linetype = "dashed", color = "red") +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "PM10",
    title = "Annual statistical summary of PM10 at Ermelo",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 240)

EBoxPM10Compare

EBoxso2Compare <- ggplot(data = Ermelo_Daily %>%
                           datify() %>%
                           select(so2, year) %>%
                           mutate(perc.obs = length(which(!is.na(so2))) / n(), .by = year),
                         aes(x = year, y = so2 )) +
  geom_boxplot(aes(fill = perc.obs)) +
  geom_hline(yintercept = 48, linetype = "dashed", color = "red") +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "SO2",
    title = "Annual statistical summary of SO2 at Ermelo",
    caption = "Data from AMS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

EBoxso2Compare

EBoxno2Compare <- ggplot(data = Ermelo_Daily %>%
                           datify() %>%
                           select(no2, year) %>%
                           mutate(perc.obs = length(which(!is.na(no2))) / n(), .by = year),
                         aes(x = year, y = no2 )) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "NO2",
    title = "Annual statistical summary of NO2 at Ermelo",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 100)

EBoxno2Compare

EBoxnoCompare <- ggplot(data = Ermelo_Daily %>%
                          datify() %>%
                          select(no, year) %>%
                          mutate(perc.obs = length(which(!is.na(no))) / n(), .by = year),
                        aes(x = year, y = no)) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "NO",
    title = "Annual statistical summary of NO at Ermelo",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 140)

EBoxnoCompare

EBoxnoxCompare <- ggplot(data = Ermelo_Daily %>%
                           datify() %>%
                           select(nox, year) %>%
                           mutate(perc.obs = length(which(!is.na(nox))) / n(), .by = year),
                         aes(x = year, y = nox)) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "NOX",
    title = "Annual statistical summary of NOX at Ermelo",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

EBoxnoxCompare

EBoxo3Compare <- ggplot(data = Ermelo_Daily %>%
                          datify() %>%
                          select(o3, year) %>%
                          mutate(perc.obs = length(which(!is.na(o3))) / n(), .by = year),
                        aes(x = year, y = no )) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "O3",
    title = "Annual statistical summary of O3 at Ermelo",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 120)

EBoxnoCompare

EBoxcoCompare <- ggplot(data = Ermelo_Daily %>%
                          datify() %>%
                          select(co, year) %>%
                          mutate(perc.obs = length(which(!is.na(co))) / n(), .by = year),
                        aes(x = year, y = co )) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "CO",
    title = "Annual statistical summary of CO at Ermelo",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 6)

EBoxcoCompare

save(EBoxPM2.5Compare,
     EBoxPM10Compare,
     EBoxso2Compare,
     EBoxno2Compare,
     EBoxnoCompare,
     EBoxcoCompare,
     EBoxnoxCompare,
     EBoxo3Compare,
     file = "Graph/EBox_plot.Rda")

# Correlation -------------------------------------------------------------


Ermelo_COR <- Ermelo_clean %>%
  select(pm2.5, pm10, so2, no2, nox, no, co, o3, ws, wd, relHum, temp, pressure, rain)


Ermelo_hourlycor <- rcorr(as.matrix(Ermelo_COR), type = "pearson")
Ermelo_hourlycor.coeff = Ermelo_hourlycor$r
Ermelo_hourlycor.p = Ermelo_hourlycor$P
Ermelo_hourlycor.coeff

Ermelohourlycorplot <- corrplot.mixed(Ermelo_hourlycor.coeff, mar = c(0,0,1,0), lower = 'number', upper = 'ellipse', title = "Ermelo air pollutant correlation")



Ermelo09 <- Ermelo %>%
  filter(year(date) == "2009")

  # Dataframe should have a column name "date". It is mandatory for OpenAir
names(Ermelo)[1] <- 'date'

# The dates must be a "POSIXct" "POSIXt" object.
date <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
Ermelo$date <- date
