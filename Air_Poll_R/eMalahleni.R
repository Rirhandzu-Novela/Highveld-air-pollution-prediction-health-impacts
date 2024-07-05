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

# Read dat files ----------------------------------------------------------

eMalahleni = read.csv("Data/eMalahleni.csv", header = T, sep = ";")

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

write_csv(eMalahleniIM, file = "Data/eMalahleniIM.csv")

# TIMESERIES --------------------------------------------------------------

plot_ly(data = eMalahleni, x = ~date, y = ~pm2.5, type = 'scatter', mode = 'lines+markers',
        marker = list(color = 'blue'), line = list(color = 'blue')) %>%
  layout(title = 'PM2.5 Levels Over Time',
         xaxis = list(title = 'Date'),
         yaxis = list(title = 'PM2.5'))



eMalahleniPTS <- timePlot(selectByDate(eMalahleni_clean),
                                   pollutant = c("pm2.5", "pm10", "co", "no", "no2", "nox", "so2"),
                                   y.relation = "free")


eMalahleniMTS  <- timePlot(selectByDate(eMalahleni_clean),
                                   pollutant = c("ws", "wd", "temp", "relHum", "pressure"),
                                   y.relation = "free")


save(eMalahleniPTS, eMalahleniMTS , file = "Data/eMalahleni_Timeseriesplot.Rda")


eMalahleni_clean <- eMalahleni_clean %>%
  datify()

PM2.5 <- timePlot(selectByDate(eMalahleni_clean, year = 2013),
                  pollutant = "pm2.5")

WPM10Tempplot09 <- timeVariation(eMalahleni_clean %>% filter(year == "2009"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2009")
WPM10Tempplot10 <- timeVariation(eMalahleni_clean %>% filter(year == "2010"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2010")
WPM10Tempplot11 <- timeVariation(eMalahleni_clean %>% filter(year == "2011"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2011")
WPM10Tempplot12 <- timeVariation(eMalahleni_clean %>% filter(year == "2012"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2012")
WPM10Tempplot13 <- timeVariation(eMalahleni_clean %>% filter(year == "2013"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2013")
WPM10Tempplot14 <- timeVariation(eMalahleni_clean %>% filter(year == "2014"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2014")
WPM10Tempplot15 <- timeVariation(eMalahleni_clean %>% filter(year == "2015"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2015")
WPM10Tempplot16 <- timeVariation(eMalahleni_clean %>% filter(year == "2016"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2016")
WPM10Tempplot17 <- timeVariation(eMalahleni_clean %>% filter(year == "2017"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2017")
WPM10Tempplot18 <- timeVariation(eMalahleni_clean %>% filter(year == "2018"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2018")

WPM10Tempplot <- timeVariation(eMalahleni_clean, stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni")

WtrendPM10 <- TheilSen(eMalahleni_clean, pollutant = "pm10",
         ylab = "PM10 (µg.m-3)",
         deseason = TRUE,
         main = "PM10 trends at eMalahleni")

save(WPM10Tempplot09, WPM10Tempplot10,
     WPM10Tempplot11,WPM10Tempplot12,
     WPM10Tempplot13,WPM10Tempplot14,
     WPM10Tempplot15,WPM10Tempplot16,
     WPM10Tempplot17,WPM10Tempplot18,
     WtrendPM10,WPM10Tempplot,
     file = "Graph/WTempoaral_plotPM10.Rda")


WPM2.5Tempplot09 <- timeVariation(eMalahleni_clean %>% filter(year == "2009"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2009")
WPM2.5Tempplot10 <- timeVariation(eMalahleni_clean %>% filter(year == "2010"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2010")
WPM2.5Tempplot11 <- timeVariation(eMalahleni_clean %>% filter(year == "2011"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2011")
WPM2.5Tempplot12 <- timeVariation(eMalahleni_clean %>% filter(year == "2012"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2012")
WPM2.5Tempplot13 <- timeVariation(eMalahleni_clean %>% filter(year == "2013"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2013")
WPM2.5Tempplot14 <- timeVariation(eMalahleni_clean %>% filter(year == "2014"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2014")
WPM2.5Tempplot15 <- timeVariation(eMalahleni_clean %>% filter(year == "2015"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2015")
WPM2.5Tempplot16 <- timeVariation(eMalahleni_clean %>% filter(year == "2016"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2016")
WPM2.5Tempplot17 <- timeVariation(eMalahleni_clean %>% filter(year == "2017"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2017")
WPM2.5Tempplot18 <- timeVariation(eMalahleni_clean %>% filter(year == "2018"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2018")

WPM2.5Tempplot <- timeVariation(eMalahleni_clean, stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at eMalahleni")
WtrendPM2.5 <- TheilSen(eMalahleni_clean, pollutant = "pm2.5",
                   ylab = "PM2.5 (µg.m-3)",
                   deseason = TRUE,
                   main = "PM2.5 trends at eMalahleni")

save(WPM2.5Tempplot09, WPM2.5Tempplot10,
     WPM2.5Tempplot11,WPM2.5Tempplot12,
     WPM2.5Tempplot13,WPM2.5Tempplot14,
     WPM2.5Tempplot15,WPM2.5Tempplot16,
     WPM2.5Tempplot17,WPM2.5Tempplot18,
     WtrendPM2.5,WPM2.5Tempplot,
     file = "Graph/WTempoaral_plotPM2.5.Rda")

WSO2Tempplot09 <- timeVariation(eMalahleni_clean %>% filter(year == "2009"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2009")
WSO2Tempplot10 <- timeVariation(eMalahleni_clean %>% filter(year == "2010"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2010")
WSO2Tempplot11 <- timeVariation(eMalahleni_clean %>% filter(year == "2011"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2011")
WSO2Tempplot12 <- timeVariation(eMalahleni_clean %>% filter(year == "2012"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2012")
WSO2Tempplot13 <- timeVariation(eMalahleni_clean %>% filter(year == "2013"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2013")
WSO2Tempplot14 <- timeVariation(eMalahleni_clean %>% filter(year == "2014"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2014")
WSO2Tempplot15 <- timeVariation(eMalahleni_clean %>% filter(year == "2015"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2015")
WSO2Tempplot16 <- timeVariation(eMalahleni_clean %>% filter(year == "2016"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2016")
WSO2Tempplot17 <- timeVariation(eMalahleni_clean %>% filter(year == "2017"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2017")
WSO2Tempplot18 <- timeVariation(eMalahleni_clean %>% filter(year == "2018"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2018")

WSO2Tempplot <- timeVariation(eMalahleni_clean, stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at eMalahleni")

WtrendSO2 <- TheilSen(eMalahleni_clean, pollutant = "so2",
                        ylab = "SO2 (µg.m-3)",
                        deseason = TRUE,
                        main = "SO2 trends at eMalahleni")

save(WSO2Tempplot09, WSO2Tempplot10,
     WSO2Tempplot11,WSO2Tempplot12,
     WSO2Tempplot13,WSO2Tempplot14,
     WSO2Tempplot15,WSO2Tempplot16,
     WSO2Tempplot17,WSO2Tempplot18,
     WtrendSO2,WSO2Tempplot,
     file = "Graph/WTempoaral_plotSO2.Rda")

WNO2Tempplot09 <- timeVariation(eMalahleni_clean %>% filter(year == "2009"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2009")
WNO2Tempplot10 <- timeVariation(eMalahleni_clean %>% filter(year == "2010"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2010")
WNO2Tempplot11 <- timeVariation(eMalahleni_clean %>% filter(year == "2011"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2011")
WNO2Tempplot12 <- timeVariation(eMalahleni_clean %>% filter(year == "2012"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2012")
WNO2Tempplot13 <- timeVariation(eMalahleni_clean %>% filter(year == "2013"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2013")
WNO2Tempplot14 <- timeVariation(eMalahleni_clean %>% filter(year == "2014"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2014")
WNO2Tempplot15 <- timeVariation(eMalahleni_clean %>% filter(year == "2015"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2015")
WNO2Tempplot16 <- timeVariation(eMalahleni_clean %>% filter(year == "2016"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2016")
WNO2Tempplot17 <- timeVariation(eMalahleni_clean %>% filter(year == "2017"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2017")
WNO2Tempplot18 <- timeVariation(eMalahleni_clean %>% filter(year == "2018"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2018")

WNO2Tempplot <- timeVariation(eMalahleni_clean, stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at eMalahleni")


WtrendNO2 <- TheilSen(eMalahleni_clean, pollutant = "no2",
                        ylab = "NO2 (µg.m-3)",
                        deseason = TRUE,
                        main = "NO2 trends at eMalahleni")

save(WNO2Tempplot09, WNO2Tempplot10,
     WNO2Tempplot11,WNO2Tempplot12,
     WNO2Tempplot13,WNO2Tempplot14,
     WNO2Tempplot15,WNO2Tempplot16,
     WNO2Tempplot17,WNO2Tempplot18,
     WtrendNO2,WNO2Tempplot,
     file = "Graph/WTempoaral_plotNO2.Rda")


WNOTempplot09 <- timeVariation(eMalahleni_clean %>% filter(year == "2009"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO temporal variation at eMalahleni in 2009")
WNOTempplot10 <- timeVariation(eMalahleni_clean %>% filter(year == "2010"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO temporal variation at eMalahleni in 2010")
WNOTempplot11 <- timeVariation(eMalahleni_clean %>% filter(year == "2011"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO temporal variation at eMalahleni in 2011")
WNOTempplot12 <- timeVariation(eMalahleni_clean %>% filter(year == "2012"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO temporal variation at eMalahleni in 2012")
WNOTempplot13 <- timeVariation(eMalahleni_clean %>% filter(year == "2013"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO temporal variation at eMalahleni in 2013")
WNOTempplot14 <- timeVariation(eMalahleni_clean %>% filter(year == "2014"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO temporal variation at eMalahleni in 2014")
WNOTempplot15 <- timeVariation(eMalahleni_clean %>% filter(year == "2015"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO temporal variation at eMalahleni in 2015")
WNOTempplot16 <- timeVariation(eMalahleni_clean %>% filter(year == "2016"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO temporal variation at eMalahleni in 2016")
WNOTempplot17 <- timeVariation(eMalahleni_clean %>% filter(year == "2017"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO temporal variation at eMalahleni in 2017")
WNOTempplot18 <- timeVariation(eMalahleni_clean %>% filter(year == "2018"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NO temporal variation at eMalahleni in 2018")

WNOTempplot <- timeVariation(eMalahleni_clean, stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at eMalahleni")

WtrendNO <- TheilSen(eMalahleni_clean, pollutant = "no",
                        ylab = "NO (µg.m-3)",
                        deseason = TRUE,
                        main = "NO trends at eMalahleni")

save(WNOTempplot09, WNOTempplot10,
     WNOTempplot11,WNOTempplot12,
     WNOTempplot13,WNOTempplot14,
     WNOTempplot15,WNOTempplot16,
     WNOTempplot17,WNOTempplot18,
     WtrendNO,WNOTempplot,
     file = "Graph/WTempoaral_plotNO.Rda")

WNOXTempplot09 <- timeVariation(eMalahleni_clean %>% filter(year == "2009"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NOX temporal variation at eMalahleni in 2009")
WNOXTempplot10 <- timeVariation(eMalahleni_clean %>% filter(year == "2010"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NOX temporal variation at eMalahleni in 2010")
WNOXTempplot11 <- timeVariation(eMalahleni_clean %>% filter(year == "2011"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NOX temporal variation at eMalahleni in 2011")
WNOXTempplot12 <- timeVariation(eMalahleni_clean %>% filter(year == "2012"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NOX temporal variation at eMalahleni in 2012")
WNOXTempplot13 <- timeVariation(eMalahleni_clean %>% filter(year == "2013"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NOX temporal variation at eMalahleni in 2013")
WNOXTempplot14 <- timeVariation(eMalahleni_clean %>% filter(year == "2014"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NOX temporal variation at eMalahleni in 2014")
WNOXTempplot15 <- timeVariation(eMalahleni_clean %>% filter(year == "2015"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NOX temporal variation at eMalahleni in 2015")
WNOXTempplot16 <- timeVariation(eMalahleni_clean %>% filter(year == "2016"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NOX temporal variation at eMalahleni in 2016")
WNOXTempplot17 <- timeVariation(eMalahleni_clean %>% filter(year == "2017"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "NOX temporal variation at eMalahleni in 2017")

WNOXTempplot <- timeVariation(eMalahleni_clean, stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at eMalahleni")

WtrendNOX <- TheilSen(eMalahleni_clean, pollutant = "nox",
                        ylab = "NOX (µg.m-3)",
                        deseason = TRUE,
                        main = "NOX trends at eMalahleni")

save(WNOXTempplot09, WNOXTempplot10,
     WNOXTempplot11,WNOXTempplot12,
     WNOXTempplot13,WNOXTempplot14,
     WNOXTempplot15,WNOXTempplot16,
     WNOXTempplot17,WNOXTempplot18,
     WtrendNOX,WNOXTempplot,
     file = "Graph/WTempoaral_plotNOX.Rda")

WCOTempplot09 <- timeVariation(eMalahleni_clean %>% filter(year == "2009"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "CO temporal variation at eMalahleni in 2009")
WCOTempplot10 <- timeVariation(eMalahleni_clean %>% filter(year == "2010"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "CO temporal variation at eMalahleni in 2010")
WCOTempplot11 <- timeVariation(eMalahleni_clean %>% filter(year == "2011"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "CO temporal variation at eMalahleni in 2011")
WCOTempplot12 <- timeVariation(eMalahleni_clean %>% filter(year == "2012"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "CO temporal variation at eMalahleni in 2012")
WCOTempplot13 <- timeVariation(eMalahleni_clean %>% filter(year == "2013"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "CO temporal variation at eMalahleni in 2013")
WCOTempplot14 <- timeVariation(eMalahleni_clean %>% filter(year == "2014"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "CO temporal variation at eMalahleni in 2014")
WCOTempplot15 <- timeVariation(eMalahleni_clean %>% filter(year == "2015"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "CO temporal variation at eMalahleni in 2015")
WCOTempplot16 <- timeVariation(eMalahleni_clean %>% filter(year == "2016"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "CO temporal variation at eMalahleni in 2016")
WCOTempplot17 <- timeVariation(eMalahleni_clean %>% filter(year == "2017"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "CO temporal variation at eMalahleni in 2017")
WCOTempplot18 <- timeVariation(eMalahleni_clean %>% filter(year == "2018"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "CO temporal variation at eMalahleni in 2018")

WCOTempplot <- timeVariation(eMalahleni_clean, stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at eMalahleni")

WtrendCO <- TheilSen(eMalahleni_clean, pollutant = "co",
                        ylab = "CO (µg.m-3)",
                        deseason = TRUE,
                        main = "CO trends at eMalahleni")

save(WCOTempplot09, WCOTempplot10,
     WCOTempplot11,WCOTempplot12,
     WCOTempplot13,WCOTempplot14,
     WCOTempplot15,WCOTempplot16,
     WCOTempplot17,WCOTempplot18,
     WtrendCO,WCOTempplot,
     file = "Graph/WTempoaral_plotCO.Rda")

WO3Tempplot09 <- timeVariation(eMalahleni_clean %>% filter(year == "2009"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "O3 temporal variation at eMalahleni in 2009")
WO3Tempplot10 <- timeVariation(eMalahleni_clean %>% filter(year == "2010"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "O3 temporal variation at eMalahleni in 2010")
WO3Tempplot11 <- timeVariation(eMalahleni_clean %>% filter(year == "2011"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "O3 temporal variation at eMalahleni in 2011")
WO3Tempplot12 <- timeVariation(eMalahleni_clean %>% filter(year == "2012"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "O3 temporal variation at eMalahleni in 2012")
WO3Tempplot13 <- timeVariation(eMalahleni_clean %>% filter(year == "2013"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "O3 temporal variation at eMalahleni in 2013")
WO3Tempplot14 <- timeVariation(eMalahleni_clean %>% filter(year == "2014"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "O3 temporal variation at eMalahleni in 2014")
WO3Tempplot15 <- timeVariation(eMalahleni_clean %>% filter(year == "2015"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "O3 temporal variation at eMalahleni in 2015")
WO3Tempplot16 <- timeVariation(eMalahleni_clean %>% filter(year == "2016"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "O3 temporal variation at eMalahleni in 2016")
WO3Tempplot17 <- timeVariation(eMalahleni_clean %>% filter(year == "2017"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "O3 temporal variation at eMalahleni in 2017")
WO3Tempplot18 <- timeVariation(eMalahleni_clean %>% filter(year == "2018"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "O3 temporal variation at eMalahleni in 2018")
WO3Tempplot <- timeVariation(eMalahleni_clean, stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at eMalahleni")

WtrendO3 <- TheilSen(eMalahleni_clean, pollutant = "o3",
                        ylab = "O3 (µg.m-3)",
                        deseason = TRUE,
                        main = "O3 trends at eMalahleni")

save(WO3Tempplot09, WO3Tempplot10,
     WO3Tempplot11,WO3Tempplot12,
     WO3Tempplot13,WO3Tempplot14,
     WO3Tempplot15,WO3Tempplot16,
     WO3Tempplot17,WO3Tempplot18,
     WtrendO3,WO3Tempplot,
     file = "Graph/WTempoaral_plotO3.Rda")


# AMS Averages and exceedances --------------------------------------------

eMalahleni_date <- eMalahleni_clean %>%
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

eMalahleni_monthly_hour_ex <- novaAQM::compareAQS(df = eMalahleni_date %>%
                                              ungroup() %>%
                                              datify() %>%
                                              mutate(place = station,
                                                     instrument = "SAAQIS"),
                                            period = "hour",
                                            by_period = quos(month, year)) %>%
  ungroup() %>%
  arrange(pollutant, month) %>%
  relocate(pollutant, .after = place)

eMalahleni_season_hour_ex <- novaAQM::compareAQS(df = eMalahleni_date %>%
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
eMalahleni_season_hour_ex <- eMalahleni_season_hour_ex %>% left_join(season_order) %>% arrange(pollutant, season_nr)

eMalahleni_annual_hour_ex <- novaAQM::compareAQS(df = eMalahleni_date %>%
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

eMalahleni_Daily <- timeAverage(eMalahleni_clean, avg.time = "day") %>%
  mutate(station = all_of("eMalahleni"))


eMalahleni_Day  <- eMalahleni_Daily %>%
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


eMalahleni_month_daily_ex <- novaAQM::compareAQS(df = eMalahleni_Day %>%
                                             ungroup() %>%
                                             datify() %>%
                                             mutate(place = station,
                                                    instrument = "SAAQIS"),
                                           period = "day",
                                           by_period = quos(month, year)) %>%
  #ungroup() %>%
  arrange(pollutant, month)



eMalahleni_season_daily_ex <- novaAQM::compareAQS(df = eMalahleni_Day %>%
                                              ungroup() %>%
                                              datify() %>%
                                              mutate(place = station,
                                                     instrument = "SAAQIS"),
                                            period = "day",
                                            by_period = quos(year, season)) %>%
  #ungroup() %>%
  arrange(pollutant, season)
season_order = tibble(season = c("autum", "winter", "spring", "summer"), season_nr = c(1, 2, 3, 4))
eMalahleni_season_daily_ex <- eMalahleni_season_daily_ex %>% left_join(season_order) %>% arrange(pollutant, season_nr)




eMalahleni_annual_daily_ex <- novaAQM::compareAQS(df = eMalahleni_Day %>%
                                              ungroup() %>%
                                              datify() %>%
                                              mutate(place = station,
                                                     instrument = "SAAQIS"),
                                            period = "day",
                                            by_period = quos(year)) %>%
  #ungroup() %>%
  arrange(pollutant, year)

save(eMalahleni_monthly_hour_ex, eMalahleni_season_hour_ex, eMalahleni_month_daily_ex, eMalahleni_season_daily_ex,
     eMalahleni_annual_daily_ex, eMalahleni_annual_hour_ex,  file = "Graph/eMalahleni_Exceedances.Rda")

# Box plots ---------------------------------------------------------------

WBoxPM2.5Compare <- ggplot(data = eMalahleni_Daily %>%
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
    title = "Annual statistical summary of PM2.5 at eMalahleni",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

WBoxPM2.5Compare


WBoxPM10Compare <- ggplot(data = eMalahleni_Daily %>%
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
    title = "Annual statistical summary of PM10 at eMalahleni",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 240)

WBoxPM10Compare

WBoxso2Compare <- ggplot(data = eMalahleni_Daily %>%
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
    title = "Annual statistical summary of SO2 at eMalahleni",
    caption = "Data from AMS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

WBoxso2Compare

WBoxno2Compare <- ggplot(data = eMalahleni_Daily %>%
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
    title = "Annual statistical summary of NO2 at eMalahleni",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 100)

WBoxno2Compare

WBoxnoCompare <- ggplot(data = eMalahleni_Daily %>%
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
    title = "Annual statistical summary of NO at eMalahleni",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 140)

WBoxnoCompare

WBoxnoxCompare <- ggplot(data = eMalahleni_Daily %>%
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
    title = "Annual statistical summary of NOX at eMalahleni",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

WBoxnoxCompare

WBoxo3Compare <- ggplot(data = eMalahleni_Daily %>%
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
    title = "Annual statistical summary of O3 at eMalahleni",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 120)

WBoxnoCompare

WBoxcoCompare <- ggplot(data = eMalahleni_Daily %>%
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
    title = "Annual statistical summary of CO at eMalahleni",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 6)

WBoxcoCompare

save(WBoxPM2.5Compare,
     WBoxPM10Compare,
     WBoxso2Compare,
     WBoxno2Compare,
     WBoxnoCompare,
     WBoxcoCompare,
     WBoxnoxCompare,
     WBoxo3Compare,
     file = "Graph/WBox_plot.Rda")

# Correlation -------------------------------------------------------------


eMalahleni_COR <- eMalahleni_clean %>%
  select(pm2.5, pm10, so2, no2, nox, no, co, o3, ws, wd, relHum, temp, pressure, rain)


eMalahleni_hourlycor <- rcorr(as.matrix(eMalahleni_COR), type = "pearson")
eMalahleni_hourlycor.coeff = eMalahleni_hourlycor$r
eMalahleni_hourlycor.p = eMalahleni_hourlycor$P
eMalahleni_hourlycor.coeff

eMalahlenihourlycorplot <- corrplot.mixed(eMalahleni_hourlycor.coeff, mar = c(0,0,1,0), lower = 'number', upper = 'ellipse', title = "eMalahleni air pollutant correlation")

